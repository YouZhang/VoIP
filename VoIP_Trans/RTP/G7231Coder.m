function ByteChar = G7231Coder (FNameI,FNameO,handles,LastTime)
% ITU-T G.723.1 speech coder
% FNameI: Input audio file (.wav, .au, ... )
% FNameO: Output bit stream file (.bit) or output data file (.dat)

% P. Kabal, www.TSP.ECE.McGill.CA

% $Id: G7231Coder.m,v 1.15 2010/02/10 20:14:55 pkabal Exp $

G7231Dir = fileparts (which ('G7231Coder.m'));
addpath (fullfile (G7231Dir, 'ACB'), fullfile (G7231Dir, 'Audio'), ...
         fullfile (G7231Dir, 'BitStream'), ...
         fullfile (G7231Dir, 'Filter'), fullfile (G7231Dir, 'LP'), ...
         fullfile (G7231Dir, 'Misc'), ...
         fullfile (G7231Dir, 'MultiPulse'), ...
         fullfile (G7231Dir, 'Tables'), fullfile (G7231Dir, 'Target'));

% Set up the output file name
if (nargin <= 1)
%   [pathstr name] = fileparts (FNameI);
  FNameO = fullfile ('', [name, '.bit']);
end
[pathstr name ext] = fileparts (FNameO);
isBitStream = strcmpi (ext, '.bit');

% Coder parameters
Np = 10;
LSubframe = [60 60 60 60];
CoderPar = SetCoderPar (Np, LSubframe);

HPFilt = CoderPar.HPFilt;
LPpar = CoderPar.LPpar;
LSFpar = CoderPar.LSFpar;
Pitchpar = CoderPar.Pitchpar;
TVpar = CoderPar.TVpar;
SineDetpar = CoderPar.SineDetpar;
MPpar = CoderPar.MPpar;

% Initialize the coder memory
CoderMem = InitCoderMem (CoderPar);

% Initialize the weighted synthesis filter memories
WSynMem0 = WSynInit (length (TVpar.HNWpar.xp));
WSynMem = WSynMem0;

LFrame = sum (LSubframe);

% Open the input file
% AFPar = OpenAudioFile (FNameI);
% if (AFPar.Sfreq ~= 8000)
%   error ('G7231Coder: Sampling rate must be 8 kHz');
% end

% Initialize the previous frame data
% The frame consists of 3 parts, [lookback Frame lookahead]
% The lookback and lookahead are each half a window long. The total memory
% of the system is lookback+lookahead. New data is read into the end of the
% array.
offs = 0;
xpMem = zeros (LPpar.LMem, 1);

FSt = LPpar.FStart+1;
FEn = FSt + LFrame - 1;
FMode = 1;        % Multipulse
fs = 8000;
% TickTock (LFrame / AFPar.Sfreq, 1, '< Data Time: %d s >\n');
TickTock (LFrame / fs, 1, '< Data Time: %d s >\n');
IFr = 0;
%%
%������
% [sound,fs,nbit] = wavread('test_8k.wav');
sound = record_data(handles,LastTime);
index_sound = 0;
len = length(sound);
while (1)
    
  % Read a frame of audio data
%   [x, Nv, AFPar] = ReadAudioData (AFPar, offs, LFrame);
    if(240*index_sound+240 > len )
        break;
    else
        x = sound(240*index_sound+1:240*index_sound+240);
        index_sound = index_sound + 1;
    end
%     Nv = length(x);
%   if (Nv < LFrame)
%     break
%   end
  
  TickTock;
  IFr = IFr + 1;

  % Highpass filter
  [xf, HPFilt.Mem] = filter (HPFilt.b, HPFilt.a, x, HPFilt.Mem);

  % Form the extended data buffer of high-passed signal
  % Concatenate the new values (1 frame) onto the saved values
  xe = [xpMem; xf]; %����ǰǰһ֡�����������֡Ҳ����120�����㣻

  % LP analysis  ��LPC����
  a = LPanalFrame (xe, LPpar);  %�ص���360���ݽ��з������ó�4����֡��Ԥ��ϵ����

  %  % Find the open loop pitch estimate
  % Perceptual weighting filter coefficients
   xc = xe(FSt:FEn);	% Current frame samples %%����һ֡����ȥͷȥβ��ֻ���м��240����
   [xt, LOL, WSynCof, TVpar] = GenTarget (xc, a, TVpar);%���������ɵ���%1.��ϵ��a�͸�ͨ��������źŽ��й�����֪��Ȩ�˲�2.��ɻ������ƺͻ��������ƣ�3.���г�������γ�

  % Set up the data memory for the next frame (save LMem values)
  xpMem = xe(end-LPpar.LMem+1:end);%�洢��һ֡�����120����������ݣ�Ϊ��һ֡�ļ�����׼��

  % Sine detector (from LP parameters)%sine���
  [SineDet, SineDetpar.rc] = SineDetector (a, SineDetpar);

  % Quantize the LP parameters (as LSFs)
  % LSFC:  Codes to index the LSF codebooks (one set per frame)
  LSFC = LPxLSFQ (a(:,LPpar.SFRef), CoderMem.lsfQ, LSFpar);%�����lsfQ������ʼΪPn�ľ�ֵmean;
  
  % Inverse quantization of the LSFs��תԤ��ǰ��֡��lsp����
  % Interpolation of the LSFs��ֵ
  % Convert LSFs to LP coefficientslsp->lpc����
  % aQI:   Quantized interpolated LP parameters (one per subframe)��ÿ����֡���в�ֵ
  % lsfQ:  Quantized LSF's (saved for differential coding) ��ֵʸ������
  [aQI, CoderMem.lsfQ] = LSFCxLPI (LSFC, CoderMem.lsfQ, LSFpar);%���Lsfϵ����->aiϵ��ת��

  NSubframe = length (LSubframe);
  LPrev = NaN;
  j = 0;
  for (i = 1:NSubframe)

    N = LSubframe(i);

    % Set up the weighted synthesis filter
    % coefficients���������࣬��������˲����Ĳ�������һ��Ҫ��
    % The weighted synthesis filter has three parts
    % 1. Quantized all-pole filter (aQ). These are added here.
    % 2. Formant weighting filter (set up earlier), derived from
    %    the unquantized LP parameters
    % 3. Harmonic weighting filter (set up earlier)
    % Calculate the weighted synthesis filter impulse response������Ӧ����
    WSynCof(i).aQ = aQI(:,i);%lsp->���������Ai(z)
    wIR = WSyn (eye(N,1), WSynCof(i), WSynMem0);%���������ۺ�ϵͳ�ĳ����Ӧ

    % Subtract the zero-input response from the
    % target��������������Ӧ��������������s(n)�м�ȥ����һ֡��󼸸����ݵ���β
    % This uses the state from the previous subframe
    zIR = WSyn (zeros(N,1), WSynCof(i), WSynMem);%��������ӦWSyn��ʾ�ۺ��˲���
    xtz = xt(j+1:j+N) - zIR;%�������

    % Adaptive codebook contribution%����Ӧ�뱾ACB����
    % The ACB searches around the open loop lag for the first and
    % third subframes and around the previous closed loop lag for
    % the second and fourth subframes
    % ACBLC: Lag code for the pitch lag (lag relative to the minimum lag
    %      or relative to the previous lag)
    % ACBbIB: Gain indices, index and codebook index.
    PMode = Pitchpar.PMode(i);
    if (PMode == 1)
      Lx = LOL(i);
    else
      Lx = LPrev;
    end   %��������������Ӧ�뱾���������������1.t(n)2.h(n)3.L 4.codermem�����뱾��lspQmea������ǣ�1.���زв�;2.L,beta��
    [ACBLC(i), ACBbIB(:,i), Pitchpar.Tamepar.E] = ...
                                GetACB (xtz, CoderMem.eMem, wIR, PMode, ...
                                        Lx, SineDet, Pitchpar);

    % Update the target vector with the pitch% contribution%��û���Ԥ������ںͼ�Ȩ���������ļ�Ȩϵ����
    [L(i), b(:,i)] = DecodeACBSF (ACBLC(i), ACBbIB(:,i), PMode, LPrev, ...
                                  Pitchpar); % Excitation contribution
    ep = PitchContrib (N, L(i), b(:,i), CoderMem.eMem, Pitchpar);%������Щ������û����ź�
    xp = filter (wIR, 1, ep);    %�ջ�����Ԥ�⹱�׼�ȥĿ�����������źţ���ö��βв� Weighted signal contribution���ٽ���������ź�ͨ���ۺ��˲���
    xtpz = xtz - xp;    %�����˻����Ĺ��ײ��֣�������βв��൱�ڣ��źŽ��������ǿ���ǲ��ָ���ȥ�ˣ�ʣ�µ�������Ĳ���

    % Fixed codebook pulse positions �����뱾�ĳ弤λ�ã�
    if (PMode == 1)
      Lx = L(i); % The lags used are: L(1), L(1), L(3), L(3)
    else
      Lx = LPrev;
    end
    Pulseval(i) = MultiPulse (xtpz, wIR, Lx, i, MPpar);   %���Ƴ����������λ�ú�������棬��������
    LPrev = L(i);

    % Fixed codebook contribution %�̶��뱾�Ĺ��ף�
    em(:,i) = MPContrib (N, Pulseval(i));
    es = ep + em(:,i);

    % Update the filter memories, ignoring the output �����˲��˲����Ĳ����ͼ���
    [temp, WSynMem] = WSyn (es, WSynCof(i), WSynMem);%��ͨ����������õ��ļ���Դes = ����+����� �����ۺ��˲������ϳ�����temp
    
    % Update the excitation memory ���¼�����ʷ��¼
    CoderMem.eMem = ShiftVector (CoderMem.eMem, ...
                                 ClipSignal (es, CoderPar.Clippar));
    j = j + N;%������һ����֡�Ĳ���

  end

  % Create the coded data %���������ݣ�����bit��
  if (isBitStream)%ACBbIB��1.�ֱ����ĸ���֡�������������ֵ��2.����һ���뱾����
    QC(IFr) = CodeStream (FMode, LSFC, ACBLC, ACBbIB, Pulseval, ...
                          Pitchpar, MPpar); %QC��������Ϣ�������֮����뱾
  else
    VC(IFr) = CodeValue (FMode, aQI, L, b, em);
  end

  % Move ahead in the speech�����һ֡�����ݴ��
  offs = offs + LFrame;

end
%���������ݶ��������֮��
% Write the bitstream or data file
if (isBitStream)  %��֮ǰ����õĸ�֡�Ĳ���ת����bit��
  ByteChar = WriteG7231Stream (FNameO, QC);
else
  save (FNameO, 'VC', '-mat');
  fprintf ('G723.1 data file: %s\n', FullName (FNameO));
end
%%
% %ÿ8024��bytes��Ϊһ�飬��ÿ�鶼�浽һ��������ȥ��Ȼ��ֱ��ͣ�ȷ�϶Է��յ��ٷ���һ��
% Byte_len = length(ByteChar);
% block_mat = [];
% block_len = 8024;
% i = 0;
% if(Byte_len > block_len )
%     block_temp = ByteChar(block_len*i+1,block_len*i+block_len);
%     
% end
return

%--------------------
function QC = CodeStream (FMode, LSFC, ACBLC, ACBbIB, Pulseval, ...
                          Pitchpar, MPpar)
% Create the coded bit stream data

% Code the gains for the pitch and the multipulse
% contributions%�Բ�ͬ��֡�Ļ������棨����Ӧ�ģ����д�������ݲ�ͬ�����淶Χѡ��ͬ�ı�׼��
CGC = CodeGain (ACBbIB, Pulseval, Pitchpar);
    
% Multipulse grid codes, sign codes, positions codes%���ڶ��������1.gird����bit����ż��2.λ�ã�3����
[MPGridC, MPPosC, MPSignC] = MPCode (Pulseval, MPpar);

% Save the codes for transmission
QC.FType = FMode - 1;
QC.LSFC = LSFC;%lsf�����������뱾����ֵ��
QC.ACBLC = ACBLC;%
QC.CGC = CGC;
QC.MPGridC = MPGridC;%1.gird����bit����ż��
QC.MPPosC = MPPosC;%2.λ��
QC.MPSignC = MPSignC;%3����

return

%--------------------
function VC = CodeValue (FMode, a, L, b, em) %�����д����ֱ�Ӵ���ֵ�����Ӧ�����ڴ���£��洢��һ֡���ݵĸ��ֲ�������������һ֡�����ݹ�
% Save the coded values
% FType: Type (MP / ACELP)
% a:   LP coefficients for each subframe
% L:   Pitch lag for each subframe
% b:   Pitch coefficient vectors for each subframe
% em:  Fixed codebook contribution for each subframe

VC.FType = FMode - 1;
VC.a = a;
VC.L = L;
VC.b = b;
VC.em = em;

return

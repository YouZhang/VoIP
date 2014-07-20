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
%读数据
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
  xe = [xpMem; xf]; %补足前前一帧的最后两个子帧也就是120个样点；

  % LP analysis  做LPC分析
  a = LPanalFrame (xe, LPpar);  %重叠的360数据进行分析，得出4个子帧的预测系数；

  %  % Find the open loop pitch estimate
  % Perceptual weighting filter coefficients
   xc = xe(FSt:FEn);	% Current frame samples %%对着一帧数据去头去尾，只用中间的240个点
   [xt, LOL, WSynCof, TVpar] = GenTarget (xc, a, TVpar);%这个函数完成的是%1.对系数a和高通后的语音信号进行共振峰感知加权滤波2.完成基音估计和基音精估计，3.完成谐波噪声形成

  % Set up the data memory for the next frame (save LMem values)
  xpMem = xe(end-LPpar.LMem+1:end);%存储这一帧的最后120个样点的数据，为下一帧的计算做准备

  % Sine detector (from LP parameters)%sine检测
  [SineDet, SineDetpar.rc] = SineDetector (a, SineDetpar);

  % Quantize the LP parameters (as LSFs)
  % LSFC:  Codes to index the LSF codebooks (one set per frame)
  LSFC = LPxLSFQ (a(:,LPpar.SFRef), CoderMem.lsfQ, LSFpar);%这里的lsfQ参数初始为Pn的均值mean;
  
  % Inverse quantization of the LSFs反转预测前三帧的lsp参数
  % Interpolation of the LSFs插值
  % Convert LSFs to LP coefficientslsp->lpc参数
  % aQI:   Quantized interpolated LP parameters (one per subframe)对每个子帧进行插值
  % lsfQ:  Quantized LSF's (saved for differential coding) 插值矢量量化
  [aQI, CoderMem.lsfQ] = LSFCxLPI (LSFC, CoderMem.lsfQ, LSFpar);%完成Lsf系数到->ai系数转换

  NSubframe = length (LSubframe);
  LPrev = NaN;
  j = 0;
  for (i = 1:NSubframe)

    N = LSubframe(i);

    % Set up the weighted synthesis filter
    % coefficients激励编码相，保存相关滤波器的参数，下一次要用
    % The weighted synthesis filter has three parts
    % 1. Quantized all-pole filter (aQ). These are added here.
    % 2. Formant weighting filter (set up earlier), derived from
    %    the unquantized LP parameters
    % 3. Harmonic weighting filter (set up earlier)
    % Calculate the weighted synthesis filter impulse response脉冲响应计算
    WSynCof(i).aQ = aQI(:,i);%lsp->反解出来的Ai(z)
    wIR = WSyn (eye(N,1), WSynCof(i), WSynMem0);%算出了这个综合系统的冲击响应

    % Subtract the zero-input response from the
    % target，计算零输入响应，并将其从整体的s(n)中减去，上一帧最后几个数据的拖尾
    % This uses the state from the previous subframe
    zIR = WSyn (zeros(N,1), WSynCof(i), WSynMem);%零输入响应WSyn表示综合滤波；
    xtz = xt(j+1:j+N) - zIR;%振铃减法

    % Adaptive codebook contribution%自适应码本ACB搜索
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
    end   %基音搜索，自适应码本搜索的输入包括：1.t(n)2.h(n)3.L 4.codermem激励码本，lspQmea；输出是：1.二重残差;2.L,beta；
    [ACBLC(i), ACBbIB(:,i), Pitchpar.Tamepar.E] = ...
                                GetACB (xtz, CoderMem.eMem, wIR, PMode, ...
                                        Lx, SineDet, Pitchpar);

    % Update the target vector with the pitch% contribution%获得基音预测的周期和加权各个激励的加权系数，
    [L(i), b(:,i)] = DecodeACBSF (ACBLC(i), ACBbIB(:,i), PMode, LPrev, ...
                                  Pitchpar); % Excitation contribution
    ep = PitchContrib (N, L(i), b(:,i), CoderMem.eMem, Pitchpar);%利用这些参数求得基音信号
    xp = filter (wIR, 1, ep);    %闭环基音预测贡献减去目标向量余量信号，获得二次残差 Weighted signal contribution，再将这个激励信号通过综合滤波器
    xtpz = xtz - xp;    %减掉了基音的贡献部分，这个二次残差相当于，信号将其相关性强的那部分给减去了；剩下的是随机的部分

    % Fixed codebook pulse positions 修正码本的冲激位置；
    if (PMode == 1)
      Lx = L(i); % The lags used are: L(1), L(1), L(3), L(3)
    else
      Lx = LPrev;
    end
    Pulseval(i) = MultiPulse (xtpz, wIR, Lx, i, MPpar);   %估计出了最佳脉冲位置和最佳增益，保存起来
    LPrev = L(i);

    % Fixed codebook contribution %固定码本的贡献；
    em(:,i) = MPContrib (N, Pulseval(i));
    es = ep + em(:,i);

    % Update the filter memories, ignoring the output 更新滤波滤波器的参数和记忆
    [temp, WSynMem] = WSyn (es, WSynCof(i), WSynMem);%将通过上面分析得到的激励源es = 基音+随机音 送入综合滤波器，合成语音temp
    
    % Update the excitation memory 更新激励历史记录
    CoderMem.eMem = ShiftVector (CoderMem.eMem, ...
                                 ClipSignal (es, CoderPar.Clippar));
    j = j + N;%进行下一个子帧的操作

  end

  % Create the coded data %创建码数据，编码bit流
  if (isBitStream)%ACBbIB是1.分别是四个子帧的最佳增益索引值，2.用哪一个码本索引
    QC(IFr) = CodeStream (FMode, LSFC, ACBLC, ACBbIB, Pulseval, ...
                          Pitchpar, MPpar); %QC将各种信息都打包好之后的码本
  else
    VC(IFr) = CodeValue (FMode, aQI, L, b, em);
  end

  % Move ahead in the speech完成了一帧的数据打包
  offs = offs + LFrame;

end
%当所有数据都被打包好之后
% Write the bitstream or data file
if (isBitStream)  %将之前打包好的各帧的参数转换成bit流
  ByteChar = WriteG7231Stream (FNameO, QC);
else
  save (FNameO, 'VC', '-mat');
  fprintf ('G723.1 data file: %s\n', FullName (FNameO));
end
%%
% %每8024个bytes分为一组，将每组都存到一个矩阵中去，然后分别发送，确认对方收到再发下一个
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
% contributions%对不同子帧的基音增益（自适应的）进行打包，根据不同的增益范围选择不同的标准；
CGC = CodeGain (ACBbIB, Pulseval, Pitchpar);
    
% Multipulse grid codes, sign codes, positions codes%对于多脉冲编码1.gird编码bit（奇偶）2.位置，3符号
[MPGridC, MPPosC, MPSignC] = MPCode (Pulseval, MPpar);

% Save the codes for transmission
QC.FType = FMode - 1;
QC.LSFC = LSFC;%lsf参数的最优码本搜索值；
QC.ACBLC = ACBLC;%
QC.CGC = CGC;
QC.MPGridC = MPGridC;%1.gird编码bit（奇偶）
QC.MPPosC = MPPosC;%2.位置
QC.MPSignC = MPSignC;%3符号

return

%--------------------
function VC = CodeValue (FMode, a, L, b, em) %不进行打包，直接存数值，这个应该是内存更新，存储上一帧数据的各种参数，用来做下一帧的数据估
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

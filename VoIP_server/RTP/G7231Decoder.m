function [xh,Sfreq] =G7231Decoder (ByteChar,FNameI, FNameO, FNameErr)
% ITU-T G.723.1 speech decoder
%   G7231Coder (FNameI)
%   G7231Coder (FNameI, FNameO)
%   G7231Coder (FNameI, FNameO, FNameErr)
% FNameI: Input bit stream file or input Matlab file
% FNameO: Output audio file (WAVE file)
% FNameErr: Input frame error file (0 / 1 in each little-endian 16-bit word)

% P. Kabal, www.TSP.ECE.McGill.CA/MMSP

% $Id: G7231Decoder.m,v 1.23 2009/07/15 16:27:54 pkabal Exp $
%%
%��������byte����
% load('ByteChar.mat');
%%
G7231Dir = fileparts (which ('G7231Decoder.m'));
addpath (fullfile (G7231Dir, 'ACB'), fullfile (G7231Dir, 'ACELP'), ...
         fullfile (G7231Dir, 'Audio'), ...
         fullfile (G7231Dir, 'BitStream'), fullfile (G7231Dir, 'CNG'), ...
         fullfile (G7231Dir, 'DataFile'), ...
         fullfile (G7231Dir, 'Filter'), fullfile (G7231Dir, 'Misc'), ...
         fullfile (G7231Dir, 'MultiPulse'), fullfile (G7231Dir, 'PLC'), ...
         fullfile (G7231Dir, 'PostFilter'), ...
         fullfile (G7231Dir, 'Tables'));

% Decoder parameters
LSubframe = [60 60 60 60];
DecoderPar = SetDecoderPar (LSubframe);

% Read from the bitstream file or data file
if (nargin < 4)
  FNameErr = [];
end%��������bit�ļ��лָ�����%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%���������д��������ݺͷ������ݣ�
% [QC, isBitStream] = ReadG7231Data (FNameI);
[QC, isBitStream] = Read_Data (ByteChar);
% Set frame errors
if (isBitStream)

  % Declare errors as set by the frame error file (set QC(.).FType = 4)
  if (~ isempty (FNameErr))
    QC = ApplyErrorFile (FNameErr, QC);
  end

  % Check for "forbidden" codes - these are also error
  % frames����ֹ�룬��Щ�Ǵ���֡����������֡��λ�ò���
  QC = FixForbiddenCodes (QC, DecoderPar.Pitchpar);

elseif (~ isempty (FNameErr))
  warning ('G7231Decoder - Error file ignored for data file input');

end

% Initialize the decoder memory values ��ʼ���������ڴ棻
DecoderMem = InitDecoderMem (DecoderPar);%CNG��VAD

LFrame = sum (LSubframe);
NFrame = length (QC);
xh = repmat (NaN, NFrame * LFrame, 1);    % Allocate memory%����bit�ڴ�
Sfreq = 8000;
TickTock (LFrame / Sfreq, 1, '< Data Time: %d s >\n');
j = 0;
NErr = 0;

for (IFr = 1:NFrame)

  TickTock;

  if (~ isBitStream)
    FMode = 0;     % Used by LPFilt
    % Process a frame from a data file��QC����ȡ��es
    [es, DecoderMem] = GenExcDAT (QC(IFr), DecoderMem, DecoderPar);
    LSFC = QC(IFr).a;    % LPFilt detects that these are LP parameters

  else
    % Treat packet losses after a non-transmitted frame as a null CNG
    % packet�����������֡��һ���յ�CNG
    FMode = QC(IFr).FType + 1;
    if (FMode == 5)
      NErr = NErr + 1;
      FModeP = DecoderMem.CNG.FModeP;
      if (FModeP == 3 || FModeP == 4)
        FMode = 4;
      end
    end
    LSFC = QC(IFr).LSFC;%��ȡ��lsf����������ֵ���ֱ��Ӧ�����뱾��
    if (FMode == 1)      % Multipulse mode��es = epitch + erandom �Ǿ������������˲�����һ֡����
      [es, DecoderMem] = GenExcMP (QC(IFr), DecoderMem, DecoderPar);%�����弤��������,��

    elseif (FMode == 2)  % ACELP mode
      [es, DecoderMem] = GenExcACELP (QC(IFr), DecoderMem, DecoderPar);

    elseif (FMode == 3)  % SID mode
      [es, DecoderMem] = GenExcSID (QC(IFr), DecoderMem, DecoderPar);

    elseif (FMode == 4)  % Null CNG frame
      [es, DecoderMem] = GenExcNull (DecoderMem, DecoderPar);
      LSFC = [];

    else                 % Packet loss concealment
      [es, DecoderMem] = GenExcPLC (DecoderMem, DecoderPar);

    end

    if (~ (FMode == 3 || FMode == 4))      % Not SID or Null
      DecoderMem.CNG.Seed = DecoderPar.CNGpar.ResetSeed;%�������seed�������
    end
    if (FMode ~= 5)
      DecoderMem.PLC.NErr = 0;%���ò���
    end
  
  end
    
  % LP filtering to get the output signal + formant% postfilter��������ͨ���ۺ��˲����͹��������˲�����Ȼ���������ͨ���������ŵ�Ԫ��
  [xhF, DecoderMem] = LPFilt (FMode, es, LSFC, DecoderMem, DecoderPar);
  xh(j+1:j+LFrame,1) = xhF;

  if (FMode ~= 5)                            % Not PLC
    DecoderMem.CNG.FModeP = FMode;
    DecoderMem.CNG.lsfP = DecoderMem.lsfQ;
  end

  j = j + LFrame;

end

% Summary
if (NErr > 0)
  fprintf ('No. error frames: %d / %d\n', NErr, NFrame);
end

% Write the audio file
if (nargin < 2)
  FNameO = SetFNameO (FNameI);
end
% play_sound(xh,Sfreq);
% WriteAudio (xh, FNameO, Sfreq, 'integer16', 'WAVE');

return

% ----------
function FNameO = SetFNameO (FNameI)

[pathstr name ext] = fileparts (FNameI);
if (strcmpi (ext, '.bit') || strcmpi (ext, '.dat') || strcmpi (ext, 'mat'))
  ext = [];
end
FNameO = fullfile ('', [name, ext, '_dec.wav']);

return

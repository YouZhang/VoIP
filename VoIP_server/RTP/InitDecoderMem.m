function DecoderMem = InitDecoderMem (DecoderPar)
% Initialize the decoder memory

% $Id: InitDecoderMem.m,v 1.9 2004/08/26 10:58:02 kabal Exp $

% Excitation memory
Pitchpar = DecoderPar.Pitchpar;
NPMode = max (Pitchpar.PMode);
LMem = 0;
for (i = 1:NPMode)
  if (i == 1)
    LMem = max (LMem, Pitchpar.PMax(i) + Pitchpar.POffs(end));
  else
    JMax = max (Pitchpar.LOffs{i});    
    LMem = max (LMem, Pitchpar.PMax(i) + JMax + Pitchpar.POffs(end));
  end
end
LFrame = sum (DecoderPar.LSubframe);

% Long memory for pitch postfilter 基音后置滤波器
DecoderMem.eMem = zeros (LMem + LFrame, 1);

% Synthesis filter memory 综合滤波器的参数
DecoderMem.SMem = [];

% LSF decoder initial value LSF解码器的参数
DecoderMem.lsfQ = DecoderPar.LSFpar.Mean;

% CNG value舒适噪声 参数
DecoderMem.CNG.Seed = DecoderPar.CNGpar.ResetSeed;
DecoderMem.CNG.FMode = 1;   % 0, 1, 2: normal, 3: SID, 4: CNG, 5: PLC
DecoderMem.CNG.Gain = NaN;
DecoderMem.CNG.SIDGain = NaN;
DecoderMem.CNG.lsfP = DecoderPar.LSFpar.Mean;  % Last non-PLC LSF's,LSF参数一开始用的是平均的，也就是逆向滤波的系数
DecoderMem.CNG.FModeP = 1;                     % Last non-PLC FMode

% PLC valuesPLC的参数
DecoderMem.PLC.Seed = DecoderPar.PLCpar.ResetSeed;
DecoderMem.PLC.NErr = 0;
DecoderMem.PLC.L = NaN;
DecoderMem.PLC.E = 0;
DecoderMem.PLC.uvGain = 0;

% Postfilter memory后置滤波器的参数
DecoderMem.PF.FMem = [];
DecoderMem.PF.TMem = [];
DecoderMem.PF.CCof = 0;
DecoderMem.PF.Gain = 1;

return

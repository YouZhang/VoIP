function [es, DecoderMem] = GenExcMP (QC, DecoderMem, DecoderPar)
% Multipulse mode decoder 多脉冲激励解码器

% $Id: GenExcMP.m,v 1.11 2009/07/15 17:07:09 pkabal Exp $

LSubframe = DecoderPar.LSubframe;

eMem = DecoderMem.eMem;

% Extract the codes 将QC中包含的L(基音)b（增益）P(冲激位置)三个向量解出来
[L, b, Pulseval] = DecodeStreamMP (QC, DecoderPar.Pitchpar, DecoderPar.MPpar);

NSubframe = length (LSubframe);
j = 0;
for (i = 1:NSubframe)%要分析四个子帧的激励；

  N = LSubframe(i);

  % Pitch contribution 基音的贡献，根据基音和其增益，还原激励值
  ep = PitchContrib (N, L(i), b(:,i), eMem, DecoderPar.Pitchpar);%在基音周围搜索5组周期激励，取最后一组

  % Fixed codebook contribution 固定码本贡献e_mul,
  em = MPContrib (N, Pulseval(i));%获得指定位置的随机冲激激励；
  es(j+1:j+N,1) = ep + em;%将基音+随机 = 激励源解码完成

  % Shift the pitch memory，转移pitch内存分配，将所有的子帧的激励保存下来；
  eMem = ShiftVector (eMem, es(j+1:j+N));

  j = j + N;

end

% PLC setup将非语音增益uvGain[6.1030e-05;]，测试基音频率的偏移；
[DecoderMem.PLC.uvGain, DecoderMem.PLC.L] = ...
                         PLCUpdate (L, eMem, Pulseval, DecoderPar.PLCpar);

% Gain for CNG获得CNG中SID帧的增益，存入DecoderMem.CNG.SIDGain
DecoderMem.CNG.SIDGain = CNGUpdate (eMem, DecoderPar.CNGpar);

% Pitch postfilter values (before clipping)获取基音后置滤波器的值；
FMode = 1;
PFval = PFPitchval (L, eMem, FMode, LSubframe, DecoderPar.PFpar);

% Clip the pitch memory 减掉音高内存；
DecoderMem.eMem = ClipSignal (eMem, DecoderPar.Clippar);

% Apply the pitch postfilter (after clipping)应用基音后置滤波器，获得一帧的语音信号；
if (DecoderPar.PFpar.enable)
  es = PPostFilter (DecoderMem.eMem, PFval, LSubframe);
end

return

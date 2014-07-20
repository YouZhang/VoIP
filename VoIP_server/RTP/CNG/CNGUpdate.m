function SIDGain = CNGUpdate (eMem, CNGpar)
% Calculate the gain for future CNG frames (in case an SID frame is
% lost)计算未来舒适噪声帧的增益（以防SID帧丢失）

% $Id: CNGUpdate.m,v 1.3 2006/09/27 18:14:36 pkabal Exp $

% Gain for CNG
N = CNGpar.NG;
E = eMem(end-N+1:end)' * eMem(end-N+1:end);%计算所有激励的能量
SIDGain = CNGpar.GScale * sqrt (E);%计算出SID增益GScale * sqrt (E)  0.0913
  
% Quantize / Decode SIDGain 量化/解码SID增益，就是标准的量化手段
QI = QuantL (SIDGain, CNGpar.GainDec);
SIDGain = CNGpar.GainCBook (QI + 1); %从码本中解码出来

return

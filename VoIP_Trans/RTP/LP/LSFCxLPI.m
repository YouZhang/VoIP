function [aQI, lsfQ] = LSFCxLPI (LSFC, lsfQP, LSFpar)
% Inverse quantize the LSF's, interpolate the quantized
% LSF's, convert to quantized LP parameters. If LSFC is
% empty, this is a packet loss frame.

% $Id: LSFCxLPI.m,v 1.2 2009/07/12 21:16:29 pkabal Exp $

% Inverse quantization of the LSFs
if (isempty (LSFC))%预测的下标不是空模式1；
  LSFMode = 2;    % PLC frame
  NSplit = length (LSFpar.VQ);
  LSFC = zeros (NSplit, 1);
else
  LSFMode = 1;
end
lsfQ = IQLSF (LSFC, lsfQP, LSFMode, LSFpar);%这个函数完成了对lsf参数恢复和修正

% Interpolation of the LSF's and convert to LP利用差值法计算出前3个子帧的Pn系数，然后转换为lpc参数
aQI = LSFxLPI (lsfQ, lsfQP, LSFpar);%完成lsp->ai

return

%--------------------
function lsfQ = IQLSF (LSFC, lsfQP, LSFMode, LSFpar)
% LSFC is a vector of codebook codes

% Calculate the prediction error
Pval = LSFpar.Pcof(LSFMode) * (lsfQP - LSFpar.Mean);

Nsplit = length (LSFpar.VQ);
i1 = 1;
for (k = 1:Nsplit)%lsp解码，将下标变回10维的en
  i2 = i1 + size (LSFpar.VQ{k}, 1) - 1;
  DlsfQ(i1:i2,1) = LSFpar.VQ{k}(:,LSFC(k) + 1);%取出下标对应的(3,3,4)维向量，
  i1 = i2 + 1;
end

% Fix closely spaced LSF's%%%对en进行稳定性检测，即频率相差不能超过31.25hz，超过要做修正；
lsfQ = FixLSF (DlsfQ + Pval + LSFpar.Mean, LSFMode, LSFpar.Fix);%利用恢复的Pn信号做稳定性检测%DlsfQ + Pval + LSFpar.Mean恢复Pn信号
if (isempty (lsfQ))
  lsfQ = lsfQP;
end

return

%------------------------
function lsf = FixLSF (lsf, LSFMode, Fix)
% Fix closely spaced LSF's

Np = length (lsf);

lsf(1)  = max (lsf(1), Fix.Min);%改变lsp参数的头和尾
lsf(Np) = min (lsf(Np), Fix.Max);

dwMin = Fix.MinSep(LSFMode);
dwTest = Fix.SepCheck(LSFMode);

NFix = 0;
for (m = 1:Fix.NIter)%Fix.NIter次数

  % Force a minimum separation
  for (j = 1:Np-1)
    dw = lsf(j+1) - lsf(j);%计算两次的Pn的差值dw,注意这里的Pn都是对应的cowW的值，所以，要做一个转换
    if (dw < dwMin) %当小于31.25HZ时
      lsf(j)   = lsf(j)   - 0.5 * (dwMin - dw);%将lsf(j)减小，将lsf(j+1)增大；
      lsf(j+1) = lsf(j+1) + 0.5 * (dwMin - dw);
      NFix = NFix + 1;
    end
  end

  % Test separation (dwTest is a bit smaller than dwMin)
  dw = diff (lsf);
  TooClose = any (dw < dwTest);%再次检查有没有小于dwtest的值
  if (~ TooClose)
    break;	% No more fixes necessary
  end

end

if (NFix > 0)
  disp ('FixLSF - Fix for close LSFs');
end

if (TooClose)
  lsf = [];
  disp ('FixLSF - Fix not successful');
end

return

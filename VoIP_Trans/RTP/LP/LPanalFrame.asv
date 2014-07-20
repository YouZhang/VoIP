function a = LPanalFrame (x, LPpar)
%lpc分析，保留之前帧的120个样点,与当前帧的240个样点,组合成一个新数组,lpc系统是针对这个数组进行计算的
%lpc系数分四组运算,每组取180个样点,组与组之间存在着120个样点的交叠

% LP analysis for a group of subframes in a frame of data. The structure
% LPpar contains the analysis information.

% $Id: LPanalFrame.m,v 1.4 2009/07/15 16:06:33 pkabal Exp $

WStart = LPpar.WStart + LPpar.FStart;
NSubframe = length (WStart);
Np = length (LPpar.LagWin) - 1;
LWin = length (LPpar.Win);

% LP analysis
a = zeros (Np+1, NSubframe);
for (i = 1:NSubframe)
  st = WStart(i);
  a(:,i) = LPanal (x(st+1:st+LWin), LPpar);%给进的数据时前180位；
end

return

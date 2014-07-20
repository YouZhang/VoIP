function y = MPContrib (N, Pulseval)
% Calculate the N sample multipulse contribution to the excitation.

% $Id: MPContrib.m,v 1.3 2009/07/12 21:20:01 pkabal Exp $

% Form a pulse train 形成一组冲激训练
y = zeros (N, 1);
y(Pulseval.m) = Pulseval.g; %在冲激位置上赋值，赋的是增益值，[+-6.103e-05;]

% Shift and repeat if necessary 周期为无穷大 所以不需要延拓
L = Pulseval.ShiftLag;
y = RepShift (y, L);

return

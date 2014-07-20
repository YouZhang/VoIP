function aI = LSFxLPI (lsf, lsfP, LSFpar)
% Interpolate the LSF vectors, convert to LP
%lsfI(:,i) = (1 - a) * lsfP + a * lsf;差值的公式
% $Id: LSFxLPI.m,v 1.1 2004/07/09 19:17:27 kabal Exp $

% Interpolate LSF's
N = length (LSFpar.IntC);
for (i = 1:N)
  a = LSFpar.IntC(i);
  lsfI(:,i) = (1 - a) * lsfP + a * lsf;
end

% Convert to LP coefficients%完成转换到LPC
aI = LSFxLP (lsfI, LSFpar);

return

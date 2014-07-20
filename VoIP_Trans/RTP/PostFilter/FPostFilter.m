function [y, PFmem] = FPostFilter (x, a, PFmem, PFpar)
% Formant postfilter (subframe)
% x:  Input signal
% a:  LP coefficients

% $Id: FPostFilter.m,v 1.3 2004/08/03 21:50:26 kabal Exp $

% LP weighting
NCof = a .* PFpar.ECWinN;
DCof = a .* PFpar.ECWinD;

[y1, PFmem.FMem] = PZFilter (NCof, DCof, x, PFmem.FMem);

% First order correlation
Ex = x' * x;
r1 = x(1:end-1)' * x(2:end);

% Correlation coefficient
if (Ex > PFpar.EThr)
  CCofN = r1 / Ex;
else
  CCofN = 0;
end

% Smooth the correlation coefficient (tilt compensation)
PFmem.CCof = (1 - PFpar.a) * PFmem.CCof + PFpar.a * CCofN;
Cpre = PFpar.Tp * PFmem.CCof;
[y2, PFmem.TMem] = PZFilter ([1 Cpre], 1, y1, PFmem.TMem);

% Scaling
[y, PFmem.Gain] = Scale_Signal (y2, Ex, PFmem.Gain, PFpar);

return

% -------------
function [yS, Gain] = Scale_Signal (y, Et, Gain, PFpar)
% Scale the energy of the output to match a target energy

alpha = PFpar.alpha;
AScale = PFpar.AScale;

% Find the gain required to equalize the energies
Ey = y' * y;
if (Ey > PFpar.EThr)
  G = sqrt (Et / Ey);
else
  G = 1;
end

% Sample-by-sample update of the gain
N = length (y);
for (i = 1:N)
  Gain = (1 - alpha) * Gain + alpha * G;
  yS(i,1) = AScale * y(i) * Gain;
end

return

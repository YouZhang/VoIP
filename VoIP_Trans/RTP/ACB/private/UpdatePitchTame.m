function E = UpdatePitchTame (ACBbIB, L, Tamepar)
% Update the estimated pitch error values
% E:     Updated error vector
% GIQ:   Pitch predictor gain index ([index, codebook])
% L:     Pitch lag

% $Id: UpdatePitchTame.m,v 1.3 2009/07/12 21:04:26 pkabal Exp $

% The gain values are supposed to represent "the gain value attributed
% to each filter as a worst case gain". This is a single value per
% multi-tap vector of pitch predictor coefficients. How these gain values
% were determined is a mystery. For instance, the all-zero vector of filter
% coefficients is given a gain of 1/8. An approximately ordered set of
% gains of approximately the same magnitudes is obtained by summing the
% absolute values of the pitch predictor coefficients.
bI = ACBbIB(1);
iCBook = ACBbIB(2);
beta = Tamepar.g{iCBook}(bI);%从增益码本中获取到对应的增益值

% The error values are normalized values. The error values exist on a
% subsampled grid (1/2 subframe interval). The error corresponding to
% lag L is multiplied by the gain and added to a constant input to give
% the new error value.

E = Tamepar.E;
EMax = Tamepar.EMax;
NE = length (E);
Ex = Tamepar.Ex;
ISub = Tamepar.ISub;

% The reference code has a confusing nested series of tests. The test is
% based on the sub-subframe number, which is calculated from the pitch lag,
%   iz = fix(L * 1092 / 32768).
% This computation can be replaced by
%   iz = fix((L-1)/30).
% "Error" values are stored in vector, indexed by the sub-subframe number.
% From oldest to newest they are as follows,
%   E[4], E[3], E[2], E[1], E[0].
% The original code finds the values of the error to the left and right
% of the sub-subframe value determined by the current pitch lag. In the
% original code, Worst1 uses the value to the left (older) and Worst0 uses
% the value to the right (newer). These values are calculated from the
% "effective" error to the left (E1) and the effective error to the right
% (E0). These effective errors are filtered through a first order recursive
% filter with constant input and coefficient determined from the equivalent
% gain of the pitch filter.
%
% The code also has checks whether the lag is on the boundary between
% sub-subframes, This check is for L == 30(iz+1). This is equivalent to
% mod(L,30) == 0. Then a table of values for E0 and E1 is as follows.
%          L              iz  E0             E1
%      1 - N/2-1    1- 29  0  E[0]           E[0]
%          N/2         30  0  E[0]           E[0]
%  N/2+1 - N-1     31- 59  1  max(E[0],E[1]) max(E[0],E[1])
%          N           60  1  E[0]           E[1]
%    N+1 - 3N/2-1  61- 89  2  max(E[0],E[1]) max(E[1],E[2])
%          3N/2        90  2  E[1]           E[2]
% 3N/2+1 - 2N-1    91-119  3  max(E[1],E[2]) max(E[2],E[3])
%          2N         120  3  E[2]           E[3]
%   2N+1 - 5N/2-1 121-149  4  max(E[2],E[3]) max(E[3],E[4])
% For the Matlab code, map E(i) <-> E[i-1]; W1 <-> Worst0; W2 <-> Worst1.

iz = fix ((L-1) / ISub);
if (L <= ISub)
  W1 = E(1) * beta + Ex;
  W2 = W1;
elseif (L < 2*ISub)
  W1 = max (E(1), E(2)) * beta + Ex;
  W2 = W1;
elseif (mod (L, ISub) == 0)
  W1 = E(iz) * beta + Ex;
  W2 = E(iz+1) * beta + Ex;
else
  W1 = max (E(iz), E(iz-1)) * beta + Ex;
  W2 = max (E(iz), E(iz+1)) * beta + Ex;
end

% Shift two places; insert the new values
for (i = NE:-1:3)
  E(i) = E(i-2);
end
E(2) = min (W2, EMax);
E(1) = min (W1, EMax);

return

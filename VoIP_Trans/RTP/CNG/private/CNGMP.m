function [Pulseval, Seed] = CNGMP (Seed, CNGpar)
% Generate the random signs and pulse positions
% Fill in Pulseval(i).m and Pulseval(i).g. The latter is only +/- 1 at this
% time. The pulse amplitude needs to be added later.

% The allocation is done two subframes at a time. The order of calling the
% random number generator is exactly as in the reference code to allow for
% an exact match for the CNG frames.

% $Id: CNGMP.m,v 1.5 2004/08/25 17:06:13 kabal Exp $

NSubframe = length (CNGpar.Np);
for (i = 1:2:NSubframe)

  % Generate random bits
  NBits = 2 + sum (CNGpar.Np(i:i+1));
  [Bits, Seed] = RandBits (NBits, Seed);

  k = 0;
  GridI(i:i+1) = Bits(1:2) + 1;
  k = k + 2;
  Np = CNGpar.Np(i);
  Sign{i} = 2 * Bits((1:Np)+k) - 1;
  k = k + Np;
  Np = CNGpar.Np(i+1);
  Sign{i+1} = 2 * Bits((1:Np)+k) - 1;
end

% Random pulse positions and signs
for (i = 1:NSubframe)
  [m, Seed] = RandPos (CNGpar.Np(i), CNGpar.Grid{i}{GridI(i)}, Seed);
  Pulseval(i).m = m;
  Pulseval(i).g = Sign{i};
  Pulseval(i).ShiftLag = Inf;    % Don't use pitch repetition
end

return

% ----------------------------
function [m, Seed] = RandPos (Np, Grid, Seed)

% - Number of available positions is Npos
% - Pick one of the positions randomly, saving the result in m
% - Replace the position just found with the last pulse position
% - Decrease the number of available positions

Grid = sort (Grid);    % Original grid not in order
Npos = length (Grid);
for (j = 1:Np)
  [ipos, Seed] = RandIntV (Seed, Npos);
  m(j) = Grid(ipos+1);
  Grid(ipos+1) = Grid(Npos);
  Npos = Npos - 1;
end

return

% ----------------------------
function [Bits, Seed] = RandBits (NBits, Seed)

NLev = 2;
[v, Seed] = RandIntV (Seed, NLev^NBits);
Bits = ExtractVals (v, NBits, NLev);

return

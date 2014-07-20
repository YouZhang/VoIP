function [L, b, Seed] = CNGPitch (Seed, CNGpar)
% Generate random pitch values
% - Pitch lag for every subframe
% - Pitch coefficient vectors for every subframe

% $Id: CNGPitch.m,v 1.3 2004/08/25 17:06:22 kabal Exp $

NSubframe = length (CNGpar.PMax);

LPrev = NaN;
for (i = 1:NSubframe)
  Nr = CNGpar.PMax(i) - CNGpar.PMin(i) + 1;
  [v, Seed] = RandIntV (Seed, Nr);
  v = v + CNGpar.PMin(i);
  if (CNGpar.PRel(i))
    L(i) = LPrev + v;
  else
    L(i) = v;
  end
  LPrev = L(i);
end

Nb = length (CNGpar.b);
for (i = 1:NSubframe)
  [v, Seed] = RandIntV (Seed, Nb);
  b(:,i) = CNGpar.b(:,v+1);
end

return

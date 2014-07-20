function eppf = PPostFilter (eMem, PFval, LSubframe)
% Pitch postfilter, called once per frame.

% $Id: PPostFilter.m,v 1.5 2006/09/27 18:14:37 pkabal Exp $

j = 0;
Ne = length (eMem);
LFrame = sum (LSubframe);
iS = Ne - LFrame + 1;

NSubframe = length (LSubframe);
for (i = 1:NSubframe)

  N = LSubframe(i);
  eppf(j+1:j+N,1) = Pitch_PF (eMem, iS, N, PFval(i));

  iS = iS + N;
  j = j + N;

end

return

% ----------
function eppf = Pitch_PF (e, iS, N, PFval)

iS1 = iS;
iSN = iS1 + N - 1;

g = PFval.g;
gE = PFval.gE;
L = PFval.L;

% Pitch postfiltering
eppf = gE * (e(iS1:iSN) + g * e(iS1+L:iSN+L));

return

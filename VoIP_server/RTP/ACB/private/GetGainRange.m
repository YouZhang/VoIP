function NgVal = GetGainRange (LL, LU, SineDet, Tamepar)
% Calculate the number of entries in the pitch filter gain codebooks to be
% used for the pitch predictor. An "error" value is available every ISub
% samples.

% $Id: GetGainRange.m,v 1.4 2009/07/12 21:03:45 pkabal Exp $

jU = fix (LU / Tamepar.ISub);
jL = fix (max (LL, 1) / Tamepar.ISub);

EMax = max (Tamepar.E(jL+1:jU+1));
if (EMax > Tamepar.EThr || SineDet ~= 0)
    iTest = 0;
else
    iTest = Tamepar.EThr - EMax;
end

NCBook = length (Tamepar.NgVMin);
for (i = 1:NCBook)
  NgVMax = length (Tamepar.g{i});
  NgVal(i) = min (Tamepar.NgVMin(i) + iTest * Tamepar.Nx(i), NgVMax);
end

return

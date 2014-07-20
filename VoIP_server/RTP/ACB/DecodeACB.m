function [L, b] = DecodeACB (ACBLC, ACBbIB, Pitchpar)
% Decode the pitch lags and pitch gain vectors for a frame.

% $Id: DecodeACB.m,v 1.7 2009/07/15 16:28:41 pkabal Exp $

NSubframe = length (ACBLC);
LPrev = NaN;
for (i = 1:NSubframe)

  PMode = Pitchpar.PMode(i);
  [L(i), b(:,i)] = DecodeACBSF (ACBLC(i), ACBbIB(:,i), PMode, LPrev, ...
                                Pitchpar);
  LPrev = L(i);

end

return

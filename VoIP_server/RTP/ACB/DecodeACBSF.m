function [L, b] = DecodeACBSF (ACBLC, ACBbIB, PMode, LPrev, Pitchpar)
% Decode adaptive codebook parameters for one subframe

% $Id: DecodeACBSF.m,v 1.1 2004/07/09 19:00:25 kabal Exp $

if (PMode == 1)
  L = ACBLC + Pitchpar.PMin(PMode);
  if (L > Pitchpar.PMax(PMode))
    error ('DecodeACB: Forbidden pitch lag');
  end
else
  ACBLI = ACBLC + 1;
  L = LPrev + Pitchpar.LOffs{PMode}(ACBLI);
end

% Determine the pitch coefficient vector / codebook indices
bI = ACBbIB(1);
CBookI = ACBbIB(2);
if (bI > size (Pitchpar.b{CBookI}, 2))
  error ('DecodeACB: Invalid gain index');
end

% Pitch coefficient vector
b = Pitchpar.b{CBookI}(:,bI);

return

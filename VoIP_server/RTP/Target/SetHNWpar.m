function HNWpar = SetHNWpar (LMem, HNWpar)
% Harmonic noise weighting filter parameters
% LMem:  Length of the past samples memory
% PGMin: Threshold on prediction gain
% GF:    Gain scaling factor
% dL:    Search range around open loop lag

% $Id: SetHNWpar.m,v 1.1 2003/11/21 13:52:22 kabal Exp $

if (nargin < 1)
    HNWpar = [];
end

if (~ isfield (HNWpar, 'PGMin'))
  HNWpar.PGMin = 1;
end
if (~ isfield (HNWpar, 'GF'))
  HNWpar.PGMin = 1;
end
if (~ isfield (HNWpar, 'dL'))
  HNWpar.dL = 0;
end

HNWpar.xp = zeros (LMem, 1);

return

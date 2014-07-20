function PitchOLpar = SetPitchOLpar (PitchOLpar)
% Open loop pitch search parameters
% PMin: Minimum pitch lag
% PMax: Maximum pitch lag
% LMem: Length of the past samples memory
% PMultThr: Relative mean-square threshold for pitch multiples

% $Id: SetPitchOLpar.m,v 1.1 2003/11/21 13:53:08 kabal Exp $

if (nargin < 1)
    PitchOLpar = [];
end

if (~ isfield (PitchOLpar, 'PMultThr'))
  PitchOLpar.PMultThr = 0.75;
end
if (~ isfield (PitchOLpar, 'LMem'))
  PitchOLpar.LMem = PitchOLpar.PMax;
end

PitchOLpar.xp = zeros (PitchOLpar.LMem, 1);

return

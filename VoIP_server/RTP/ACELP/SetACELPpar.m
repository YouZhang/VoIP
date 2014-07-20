function ACELPpar = SetACELPpar (N, ACELPpar)
% ACELP parameters

% $Id: SetACELPpar.m,v 1.3 2004/07/05 15:35:51 kabal Exp $

% Pulse gain table
if (ischar (ACELPpar.g))
  ACELPpar.g = load (ACELPpar.g);
end

% Mark out of range grid values with a NaN
[NTrack, NGridI] = size (ACELPpar.Grid);
for (i = 1:NTrack)
  for (j = 1:NGridI)
    Grid = ACELPpar.Grid{i,j};
    I = (Grid > N);
    Grid(I) = NaN;
    ACELPpar.Grid{i,j} = Grid;
  end
end

% Pitch repetition offset
if (ischar (ACELPpar.POffs))
  ACELPpar.POffs = load (ACELPpar.POffs);
end

% Pitch repetition gain table
if (ischar (ACELPpar.Pg))
  ACELPpar.Pg = load (ACELPpar.Pg);
end

return

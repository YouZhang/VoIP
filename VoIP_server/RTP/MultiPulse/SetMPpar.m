function MPpar = SetMPpar (MPpar)
% Multipulse parameters

% $Id: SetMPpar.m,v 1.1 2003/11/21 13:46:05 kabal Exp $

if (ischar (MPpar.g))
  MPpar.g = load (MPpar.g);
end

% Grids for pulses
NSubframe = length (MPpar.Grid);
NGridMax = 0;
for (i = 1:NSubframe)
  NG = length (MPpar.Grid{i});
  for (j = 1:NG)
    % Make a column vector, reverse its order so that the pulses are
    % searched from high index to low index. This is a hack so that
    % in the case of zero energy, pulses are placed in the high index
    % positions first (as in the G.723.1 code)
    % *** Don't forget to take this reversal into account when coding
    %     the positions ***
    MPpar.Grid{i}{j} = flipud (MPpar.Grid{i}{j}(:));
    NGridMax = max (NGridMax, length (MPpar.Grid{i}{j}));
  end
end

% Fill in a combinatoric table
% nCk(n+1,k+1) is n choose k, except that it is set to
% zero if k > n
NpMax = max (MPpar.Np);
nCk = zeros (NGridMax+1, NpMax+1);
for (n = 0:NGridMax)
  for (k = 0:NpMax)
    if (k <= n)   % Otherwise 0
      nCk(n+1,k+1) = nchoosek (n, k);
    end
  end
end
MPpar.nCk = nCk;

return

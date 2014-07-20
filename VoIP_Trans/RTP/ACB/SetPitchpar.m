function Pitchpar = SetPitchpar (Pitchpar)
% Pitch parameters
% PMin: Minimum pitch lag
% PMax: Maximum pitch lag
% PMode: Pitch mode for each subframe; 0 is relative to open loop pitch; 1
%    is relative to previous closed loop pitch
% CBookThr: Pitch lag threshold for choosing gain codebooks.
%    Lag values less than or equal to the threshold use codebook 0, other
%    lag values use codebook 1.
% LOffs: Pitch offsets for different modes
% b: Pitch coefficient vectors (two codebooks)
% Tamepar: Pitch taming parameters

% $Id: SetPitchpar.m,v 1.7 2009/07/12 21:05:18 pkabal Exp $

NCBook = length (Pitchpar.b);
for (i = 1:NCBook)
  if (ischar (Pitchpar.b{i}))
    Pitchpar.b{i} = load (Pitchpar.b{i});
  end
end
Nc = size (Pitchpar.b{1}, 1);

% Lag offsets for the pitch coefficients
if (~ isfield (Pitchpar, 'POffs'))
  RefOffs = fix ((Nc - 1) / 2);
  Pitchpar.POffs = (-RefOffs):(Nc - 1 - RefOffs);
end

% Excitation memory length
NPMode = max (Pitchpar.PMode);
LMem = 0;
for (i = 1:NPMode)
  if (i == 1)
    LMem = max (LMem, Pitchpar.PMax(i) + Pitchpar.POffs(end));
  else
    JMax = max (Pitchpar.LOffs{i});    
    LMem = max (LMem, Pitchpar.PMax(i) + JMax + Pitchpar.POffs(end));
  end
end

% Pitch taming parameters
if (isfield (Pitchpar, 'Tamepar'))
  Tamepar = Pitchpar.Tamepar;

  if (~ isfield (Tamepar, 'ISub'))
    Tamepar.ISub = 30;
  end
  if (~ isfield (Tamepar, 'NE'))
    Tamepar.NE = floor (LMem / Tamepar.ISub) + 1;
  end
  if (~ isfield (Tamepar, 'Nx'))
    Tamepar.Nx = repmat (inf, 1, NCBook);
  end

  for (i = 1:NCBook)
    if (ischar (Tamepar.g{i}))
      Tamepar.g{i} = load (Tamepar.g{i});
    elseif (isempty (Tamepar.g{i}))
      Nq = size (Pitchpar.b{i}, 2);
      for (j = 1:Nq)
        Tamepar.g{i}(j) = abs (sum (abs (Pitchpar.b{i}(:,j))));
      end
    end
  end
  Tamepar.E = zeros (Tamepar.NE, 1);

  Pitchpar.Tamepar = Tamepar;
end

return

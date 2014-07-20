function PFpar = SetPFpar (Np, PFpar)
% Postfilter parameters
% Np: filter order (Np+1 coefficients for the numerator and Np+1
%               coefficients for the denominator)
% PFpar.ECWinN: Numerator weighting
%               File name, expansion coefficients or expansion factor
% PFpar.ECWinD: Denominator weighting
%               File name, expansion coefficients or expansion factor

% $Id: SetPFpar.m,v 1.3 2004/08/03 21:51:27 kabal Exp $

if (nargin < 2)
  PFpar = [];
end

if (~ isfield (PFpar, 'alpha'))
  PFpar.alpha = 1;
end
if (~ isfield (PFpar, 'AScale'))
  PFpar.AScale = 1;
end
if (~ isfield (PFpar, 'Tp'))
  PFpar.Tp = 0;
end
if (~ isfield (PFpar, 'a'))
  PFpar.a = 1;
end

% Enable postfilter
if (~ isfield (PFpar, 'enable'))
  PFpar.enable = 1;
end

% Numerator bandwidth expansion
if (isfield (PFpar, 'ECWinN'))
  if (ischar (PFpar.ECWinN))
    PFpar.ECWinN = load (PFpar.ECWinN);
  elseif (length (PFpar.ECWinN) == 1)
    alpha = PFpar.ECWinN;
    PFpar.ECWinN = alpha.^(0:Np);
  end
else
  PFpar.ECWinN = ones (Np+1,1);
end
PFpar.ECWinN = PFpar.ECWinN(:);

% Denominator bandwidth expansion
if (isfield (PFpar, 'ECWinD'))
  if (ischar (PFpar.ECWinD))
    PFpar.ECWinD = load (PFpar.ECWinD);
  elseif (length (PFpar.ECWinD) == 1)
    alpha = PFpar.ECWinD;
    PFpar.ECWinD = alpha.^(0:Np);
  end
else
  PFpar.ECWinD = ones (Np+1,1);
end
PFpar.ECWinD = PFpar.ECWinD(:);

return

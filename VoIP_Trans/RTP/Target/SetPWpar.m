function PWpar = SetPWpar (Np, PWpar)
% Formant weighting filter parameters
% Np: filter order (Np+1 coefficients for the numerator and Np+1
%               coefficients for the denominator)
% PWpar.ECWinN: Numerator weighting
%               File name, expansion coefficients or expansion factor
% PWpar.ECWinD: Denominator weighting
%               File name, expansion coefficients or expansion factor

% $Id: SetPWpar.m,v 1.2 2004/07/08 03:34:55 kabal Exp $

if (nargin < 2)
  PWpar = [];
end

% Numerator bandwidth expansion
if (isfield (PWpar, 'ECWinN'))
  if (ischar (PWpar.ECWinN))
    PWpar.ECWinN = load (PWpar.ECWinN);
  elseif (length (PWpar.ECWinN) == 1)
    alpha = PWpar.ECWinN;
    PWpar.ECWinN = alpha.^(0:Np);
  end
else
  PWpar.ECWinN = ones (Np+1,1);
end
PWpar.ECWinN = PWpar.ECWinN(:);

% Denominator bandwidth expansion
if (isfield (PWpar, 'ECWinD'))
  if (ischar (PWpar.ECWinD))
    PWpar.ECWinD = load (PWpar.ECWinD);
  elseif (length (PWpar.ECWinD) == 1)
    alpha = PWpar.ECWinD;
    PWpar.ECWinD = alpha.^(0:Np);
  end
else
  PWpar.ECWinD = ones (Np+1,1);
end
PWpar.ECWinD = PWpar.ECWinD(:);

% Set up the filter memories
PWpar.Mem = [];

return

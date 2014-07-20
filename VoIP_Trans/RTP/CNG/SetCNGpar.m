function CNGpar = SetCNGpar (CNGpar)
% Comfort noise parameters

% $Id: SetCNGpar.m,v 1.2 2004/07/11 23:33:43 kabal Exp $

if (nargin < 1)
  CNGpar = [];
end

% Gain table and decision levels
if (isfield (CNGpar, 'GainCBook'))
  if (ischar (CNGpar.GainCBook))
    CNGpar.GainCBook = load (CNGpar.GainCBook);
  end
end
CNGpar.GainCBook = CNGpar.GainCBook(:);

if (isfield (CNGpar, 'GainDec'))
  if (ischar (CNGpar.GainDec))
    CNGpar.GainDec = load (CNGpar.GainDec);
  end
end
CNGpar.GainDec = CNGpar.GainDec(:);

return

function SineDetpar = SetSineDetpar (SineDetpar)
% Sine detector parameters

% $Id: SetSineDetpar.m,v 1.1 2003/11/21 13:27:01 kabal Exp $

% Sine detector
if (~ isfield (SineDetpar, 'rcThr'))
  SineDetpar.rcThr = 0.95;
end
Nrc = length (SineDetpar.rc);
if (~ isfield (SineDetpar, 'NThr'))
  SineDetpar.NThr = max (0, Nrc-2);
end

return

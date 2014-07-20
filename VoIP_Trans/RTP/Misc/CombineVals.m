function CVal = CombineVals (x, B)
% This routine combines individual values to form a combined integer-value.
%   CVal = CombineVals (V, B)
%   CVal = CombineVals (V, NLev)
%
% The combined value is of the form
%          NVal
%   CVal = SUM x(i) B(i), where B(1) = 1 < B(2) < ... < B(NVal).
%          i=1
% Case 1:
%   B is specified directly. Note that B(1) = 1.
% Case 2:
%   NLev is a vector of length NVal specifying the number of levels for
%   each value. B is formed as
%           i-1
%   B(i) = PROD NLev(k).
%           k=1
% Case 3:
%   NLev is a scalar. This is equivalent to the second case if NLev is
%   repeated NVal times. B is calculated as B = NLev^(0:NVal-1).
%
% For the first form of the function, consider B = [1 24 2048]. This
% example allows 24 (floor (B(2)/B(1))) levels for the first value, 85
% (floor (B(3)/B(2))) for the second value, and has no limit for the third
% value. Note that B(3) > 24 * 85. For the second form of the function,
% consider NLev = [24, 85, 2]. This time B is calculated from NLev, giving
% giving B = [1 24 2040]. This time B(3) = 24 * 85.

% $Id: CombineVals.m,v 1.2 2009/07/12 21:17:29 pkabal Exp $

NVal = length (x);
if (B(1) ~= 1)
  NLev = B;
  if (length (NLev) == 1)
    B = NLev.^(0:NVal-1);
  else
    B(2:NVal) = cumprod (NLev(1:NVal-1));
    B(1) = 1;
  end
end

CVal = B(:)' * x(:);

return

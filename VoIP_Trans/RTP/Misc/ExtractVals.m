function [varargout] = ExtractVals (x, B, NLev)
% This routine extracts individual values from a combined integer-value.
%              Vals = ExtractVals (x, B)
% [Val1, Val2, ...] = ExtractVals (x, B)
%              Vals = ExtractVals (x, NLev)
% [Val1, Val2, ...] = ExtractVals (x, NLev)
%              Vals = ExtractVals (x, NVal, NLev)
% [Val1, Val2, ...] = ExtractVals (x, NVal, NLev)
% The combined value is of the form
%       NVal
%   x = SUM V(i) B(i), where B(1) = 1 < B(2) < ... < B(NVal).
%       i=1
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
% value. Note that B(3) > 24 * 85. This means that there are "improper"
% sums of the first two values from 2040, ... , 2047. These improper
% sums are a result of either the first value taking on more than 24
% values or the second value taking on more than 85 values.
%
% For the second form of the function, consider NLev = [24, 85, 2]. This
% time B is calculated from NLev, giving giving B = [1 24 2040]. This
% time B(3) = 24 * 85.

% $Id: ExtractVals.m,v 1.3 2009/07/12 21:17:46 pkabal Exp $

if (nargin == 3)
  NVal = B;                     % Second argument
  B = NLev.^(0:NVal-1);         % NLev is a scalar

  % Use a simple decoding scheme
  V = mod (floor (x ./ B), NLev);
  
else
  NVal = length (B);
  if (B(1) ~= 1)
    NLev = B;                   % NLev is a vector
    B(2:NVal) = cumprod (NLev(1:NVal-1));
    B(1) = 1;
    
    % Use a simple decoding scheme
    V = mod (floor (x ./ B), NLev);

  else
    ModV = B(2:NVal);

    % Extract the values, peeling off one value at a time
    V(NVal) = floor (x / B(NVal));
    for (i = NVal-1:-1:1)
      x = mod (x, ModV(i));     % Overwrite x
      V(i) = floor (x / B(i));
    end
  end
end

% Either return a vector, or separate values
if (nargout == 1)
  varargout(1) = {V};
else
  NVal = length (B);
  for (i = 1:NVal)
    varargout(i) = {V(i)};
  end
end

return

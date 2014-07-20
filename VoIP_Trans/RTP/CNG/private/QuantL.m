function QI = QuantL (x, Xq)
% Binary search for a bounding interval for each value in an input vector.
% This function returns the index of the quantizer region corresponding to
% a given input value. The quantizer is specified by an array of quantizer
% decision levels. A binary search is used to determine the quantizer
% region.
%
% The index value takes on values from 0 to Nreg-1. If Nreg is equal to
% one, the index is set to zero. Otherwise, the index is determined as
% shown in the following table. Note that the number of decision levels is
% one less than the number of regions.
%   index
%    0                    x < Xq(1)
%    1           Xq(1) <= x < Xq(2)
%    2           Xq(2) <= x < Xq(3)
%   ...                  ...
%    i           Xq(i) <= x < Xq(i+1)
%   ...                  ...
%  Nreg-2   Xq(Nreg-2) <= x < Xq(Nreg-1)
%  Nreg-1   Xq(Nreg-1) <= x

% $Id: QuantL.m,v 1.3 2009/07/16 16:16:42 pkabal Exp $

% Binary search for the interval [Xq(iL+1), Xq(iU+1)) which brackets x
Nx = length (x);
for (n = 1:Nx)
  iL = 0;
  iU = length (Xq) + 1;

  % Isolate the interval
  while (iU > iL + 1)
    i = fix ((iL + iU) / 2);
    if (x(n) < Xq(i))
      iU = i;
    else
      iL = i;
    end
  end

  QI(n,1) = iL;
end

return

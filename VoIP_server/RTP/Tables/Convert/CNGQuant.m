function CNGQuant
% Generate a quantizer table by exercising the converted C-code for the CNG
% gain quantizer.
%
% The quantizer break points alternate between quantizing up and quantizing
% down at the break points.

i = -50:400;

Nx = 3 * length (i);
x(1:3:Nx) = i - 0.0001;
x(2:3:Nx) = i;
x(3:3:Nx) = i + 0.0001;

for (i = 1:Nx)
  EC(i) = Qlog(x(i));
  xq(i) = Qinvlog (EC(i));
end

plot (x, EC, x(2:3:Nx), EC(2:3:Nx), 'o');

figure;

plot (x, x, x, xq);

% Make a quantizer table
ECP = -Inf;
k = 1;
for (i = 1:Nx)
  if (EC(i) ~= ECP)
    Xqq(k) = x(i);
    Yqq(k) = xq(i);
    k = k + 1;
    ECP = EC(i);
  end
end

% Kill the first decision level
Xqq(1) = [];

% Generate the output level table
Yq = Yqq(:) / 32768;  % Normalize the table
FY = 'CNGGain64.dat';
save (FY, 'Yq', '-ASCII', '-DOUBLE');

% The quantizer will quantize into region i if
%   Xq(i) <= x < Xq(i).

% The break points have to be fixed to reflect the quantize up/down
% behaviour of the scheme in the C-code. The break points are near integer
% values, but sometimes an input on the decision point will be quantized
% up, sometimes down. Since the quantizer is normalized to values smaller
% than one, adding eps (smallest value value such steps 1+eps ~= 1) to
% selected decision levels will effectively change the behaviour at the
% decision level.

for (i = 1:length(Xqq))
  if (Xqq(i) ~= round (Xqq(i)))
    Xq(i,1) = (round (Xqq(i)) / 32768) + eps;
  else
    Xq(i,1) = Xqq(i) / 32768;
  end
end

FX = 'CNGGainDec63.dat';
save (FX, 'Xq', '-ASCII', '-DOUBLE');

% Test the procedure
TestQVals (x, FX, FY);

return

% ----------
function TestQVals (x, FX, FY)

Xq = load (FX);
Yq = load (FY);

Nx = length (x);
Iq1 = QuantL (x / 32768, Xq);
xq1 = Yq(Iq1+1) * 32768;
for (i = 1:Nx)
  Iq0 = Qlog(x(i));
  if (Iq0 ~= Iq1(i))
    error ('Quantizer indices differ');
  end
  xq0 = Qinvlog (Iq0);
  if (xq0 ~= xq1(i))
    error ('Quantizer levels differ');
  end
end

return

% ======================
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

% $ Id:$

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

% ----------
function EC = Qlog (x)
% Gain quantizer for CNG, C-code converted to Matlab

bseg = [1024, 9216, 115617];
bseg = sqrt (bseg);
base = [0, 32, 96];

% Quantize x
if (x >= bseg(2+1))
  EC = 63;
  return
end

% Compute segment number iseg
% [0 1024)       iseg = 0, step = 2, exp = 3, 2^(exp+1) = 16 values
% [1024 9216)    iseg = 1, step = 4, exp = 3, 16 values
% [9216 115617)  iseg = 2, step = 8,e xp = 4, 32 values
if (x >= bseg(1+1))
  iseg = 2;
  exp = 4;
else
  exp = 3;
  if (x >= bseg(0+1))
    iseg = 1;
  else
    iseg = 0;
  end
end

j = 2^exp;
k = fix (j / 2);

% Binary search in segment iseg
step = 2^(iseg+1);
for (i = 0:exp)
  temp = base(iseg+1) + j * step;
  y = temp;
  if (x >= y)
    j = j + k;
  else
    j = j - k;
  end
  k = fix (k / 2);
end

temp = base(iseg+1) + j * step;
y =  temp - x;
if (y <= 0)
  temp = base(iseg+1) + (j + 1) * step;
  z = x - temp;
  if (y > z)
    temp16 = iseg * 2^4 + j;
  else
    temp16 = iseg * 2^4 + j + 1;
  end
else
  temp = base(iseg+1) + (j - 1) * step;
  z = x - temp;
  if (y < z)
    temp16 = iseg * 2^4 + j;
  else
    temp16 = iseg * 2^4 + j - 1;
  end
end
    
EC = temp16;
    
return

% ----------
function x = Qinvlog (y)

base = [0, 32, 96];

iGain = y;
iseg = fix (iGain / 2^4);
if (iseg == 3)
  iseg = 2;
end
i = iGain - 2^4 * iseg;
temp = base(iseg+1) + i * 2^(iseg + 1);

x = temp;

return

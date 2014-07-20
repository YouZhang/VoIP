function y = RepShift (x, L, G)
% Add repeated, shifted versions of a signal. This is an IIR filter with
% zero state,
%   y[n] = x[n] - G * y[n-L]
%          inf 
%        = SUM G^k x[n - kL] .
%          k=0
% For L>N where N is the length of x, the output signal equals the input
% signal.
% y: Signal (length N) formed by adding repeated shifted versions of x
% x: Input signal (N samples)
% L: Shift

% $Id: RepShift.m,v 1.3 2004/07/11 23:35:52 kabal Exp $

if (nargin < 3)
  G = 1;
end

y = x;
N = length (x);
m = L+1;
a = G;
while (m <= N)
  y(m:N) = y(m:N) + a * x(1:N-m+1);
  m = m + L;
  a = a * G;
end

return

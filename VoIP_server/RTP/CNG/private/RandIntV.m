function [iR, Seed] = RandIntV (Seed, N)
% Generate a random integer in the interval [0, N-1].

% The original C-code for random number generation was as follows:
%   *p = (Word16)(((*p)*521L + 259) & 0x0000ffff)
% This code uses integer arithmetic: The seed (Word16) is promoted to long
% before being multiplied by 521. The result is masked to 16 bits.
%
% Here we work with unsigned integer values (in Matlab doubles).   

% $Id: RandIntV.m,v 1.6 2009/07/12 21:15:33 pkabal Exp $

if (N == 1)
  iR = 0;    % Don't invoke the random number generator
else
  Seed = mod (521 * Seed + 259, 65536);
  iR = fix (mod (Seed, 32768) * N / 32768);
end

return

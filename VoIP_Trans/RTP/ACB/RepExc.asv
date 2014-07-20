function eL = RepExc (e, N, L, POffs)
% Return a pitch-repeated excitation signal.
% eL:   Pitch-repeated signal (Nc samples), where Nc is the number of
%       filter coefficients. The first sample in eL corresponds to lag
%       L+POffs(end). The last sample corresponds to lag L+POffs(1)-(N-1).
% e:    Excitation signal, up to time -1
% N:    Frame size
% L:    Pitch lag (NaN indicates no repetition)
% POffs: Pitch filter coefficients lag offsets

%   eL[n] = e[n],          n < 0,
%           e[mod(n,L)-L], n >= 0.
% The mapping from e[n] (negative-valued indices) to the input signal e(n)
% is e[n] = e(Ne+n+1), where Ne is the length of e(.).

% The pitch coefficients are at relative offsets POffs.
%              -L-2 -L              0
%                 | |   past data   | current data 
%     oooooooooooooo|ooooooooooooooo|ooooooooooooo e[n]
%                 43210

% $Id: RepExc.m,v 1.6 2009/07/12 21:05:03 pkabal Exp $

if (nargin < 4)
  POffs = 0;
end

% Index array
I = (-(L+POffs(end))):(-(L+POffs(1)) + N - 1);

% Form a wrapped index array %形成一个包围检索矩阵，在指定的几个位置形成
ip = (I >= 0);
I(ip) = mod (I(ip), L) - L;

Ne = length (e);
eL = e(I + Ne + 1);

return

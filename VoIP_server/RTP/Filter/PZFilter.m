function [y, FiltMem] = PZFilter (b, a, x, FiltMem)
% Pole-zero filtering with memory. This function allows the filter
% coefficients to change from call-to-call. After the filter memory
% has been set up, the number of filter coefficients should stay
% constant from call-to-call.
% y = PZFilter (b, a, x):
%       Zero-state filtering (same as filter for 1-D signals)
% [y, FiltMem] = PZFilter (b, a, x)
%       Zero-state filtering, with updated filter state FiltMem
% [y, FiltMem] = PZFilter (b, a, x, FiltMem) 
%       Filtering with non-zero state, updated state on output
% FiltMem = [];    % PZFilter will initialize the memory
% [y, FiltMem] = PZFilter (b, a, x, FiltMem);
%
% Alternate calling sequence when the filter coefficients are given as
% FiltMem.b and FiltMem.a.
% [y, FiltMem] = PZFilter (x, FiltMem);
%
% The FILTER routine in Matlab implements pole-zero filter using a 
% transposed direct form II structure. The memory (state) of this structure
% is not conducive to having changing coefficient values. This routine uses
% FILTIC to create a filter memory that is derived from a vector of past
% inputs and a vector of past outputs before calling the built-in Matlab
% FILTER function.

% $Id: PZFilter.m,v 1.6 2009/07/12 21:02:58 pkabal Exp $

if (nargin == 2 && isstruct (a))
  x = b;
  FiltMem = a;
  b = FiltMem.b;
  a = FiltMem.a;
end

Nb = length (b) - 1;
Na = length (a) - 1;

% Initialization for filter memories
if (isempty (FiltMem) || ~ isfield (FiltMem, 'X'))
  FiltMem.X = zeros (Nb, 1);
  FiltMem.Y = zeros (Na, 1);
end

% Check the memory lengths
if (length (FiltMem.X) < Nb || length (FiltMem.Y) < Na)
  disp ('PZFilter: Memory too short for no. coefficients');
end

% Set up the filter memory based on past inputs and past outputs.
Mem = filtic (b, a, FiltMem.Y, FiltMem.X);

% Do the actual filtering
y = filter (b, a, x, Mem);

% Save the input and output vectors as memory
Lx = length (x);

if (Lx < Nb)
  x = [ FiltMem.X(end:-1:1); x(:) ];
end
FiltMem.X = x(end:-1:end-Nb+1);

if (Lx < Na)   % length(y) = Lx
  yy = [ FiltMem.Y(end:-1:1); y(:) ];
  FiltMem.Y = yy(end:-1:end-Na+1);
else
  FiltMem.Y = y(end:-1:end-Na+1);
end

return

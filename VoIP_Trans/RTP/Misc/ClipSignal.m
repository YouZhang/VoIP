function x = ClipSignal (x, Clippar)
% Clip values in a signal to a max and a min value.

% $Id: ClipSignal.m,v 1.1 2003/11/21 13:36:29 kabal Exp $

I = (x > Clippar.MaxThr);
x(I) = Clippar.MaxVal;
I = (x < Clippar.MinThr);
x(I) = Clippar.MinVal;

return

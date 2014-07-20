function y = ACELPContrib (N, Pulseval)
% Calculate the N sample ACELP contribution to the excitation.

% $Id: ACELPContrib.m,v 1.8 2006/09/27 18:13:51 pkabal Exp $

% Place the pulses with the (signed) gain
y = zeros (N, 1);
y(Pulseval.m) = Pulseval.g;

% Add pitch repetition, if appropriate
y = RepShift (y, Pulseval.ShiftLag, Pulseval.ShiftGain);

return

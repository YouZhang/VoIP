function [SineDet, rc] = SineDetector (a, SineDetpar)
% Detect sine waves
%
% Consider samples from a discrete-time sine wave. This signal has a
% spectrum with two poles on the unit circle, at w = w0 and w = -w0.
% An optimal predictor will generate two zeros to cancel these poles.
% The prediction error filter is
%   H(z) = 1 - 2cos(w0) z^{-1} + z^{-2}.
% The predictor coefficients are -2cos(w0) and 1.
% Let us verify this analysis. Let the sine wave be
%   s[n] = cos(w0 n + a).
% Directly from trigonometric identities, it can be shown that
%   s[n] = 2 cos(w0) s[n-1] - s[n-2].
% This is the predictor which exactly predicts the sine wave from its
% previous two values.

% $Id: SineDetector.m,v 1.2 2009/07/12 21:05:29 pkabal Exp $
	 
% For a two-tap predictor, the last predictor coefficient is also the
% negative of the second reflection coefficient. Here we take the higher
% order predictor and convert its coefficients to reflection coefficients
% to make a sine wave decision based on the second reflection coefficient.

NSubframe = size (a, 2);
rc2 = SineDetpar.rc;
Nrc = length (rc2);

for (i = 1:NSubframe)
  % Shift the vector of sine detector decisions
  rc2(2:Nrc) = rc2(1:Nrc-1);
  rc = poly2rc (a(:,i));
  rc2(1) = rc(2);
end
SineDetpar.rc = rc2;

rcThr = SineDetpar.rcThr;
NThr = SineDetpar.NThr;
SineDet = (length (find (rc2 > rcThr)) > NThr);

return

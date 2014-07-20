function [es, DecoderMem] = GenExcCNG (GainT, DecoderMem, DecoderPar)
% Generate a CNG frame.
%   GainT: Target gain

% $Id: GenExcCNG.m,v 1.6 2009/07/12 21:15:07 pkabal Exp $

LSubframe = DecoderPar.LSubframe;
eMem = DecoderMem.eMem;
Seed = DecoderMem.CNG.Seed;

CNGpar = DecoderPar.CNGpar;

% Generate random values for the pitch lags
[L, b, Seed] = CNGPitch (Seed, CNGpar);

% Generate random values for the multipulse pulse positions
% The pulse amplitudes are +/- 1.
[Pulseval, Seed] = CNGMP (Seed, CNGpar);

% CNG generation works with two subframes at a time. There are some
% potential problems with this. The pitch excitation procedure needs
% the clipped total excitation (pitch + pulses). However, we won't
% generate the pulse contribution until two subframes worth of pitch
% excitation has been generated. What saves us is that the pitch lag
% used for generating the pitch component is more than twice the
% length of a subframe. The past clipped total excitation is then
% available for the determination of the pitch contribution for both
% subframes.
%
% After the pitch contribution has been determined, the gain for the
% pulse contribution to the excitation is determined. The pulse
% positions and their signs have been set randomly. After scaling (one
% gain per 2 subframes), the total excitation is available.

NSubframe = length (LSubframe);
j = 0;
for (i = 1:2:NSubframe)

  eMemS = eMem;    % Save the pitch memory
  m = 0;
  N2 = 0;
  for (k = i:i+1)
    N = LSubframe(k);

    % Pitch contribution
    ep(m+1:m+N,1) = PitchContrib (N, L(k), b(:,k), eMem, DecoderPar.Pitchpar);
    
    % Fixed codebook contribution (normalized signed pulses)
    em(m+1:m+N,1) = MPContrib (N, Pulseval(k));

    % Shift the pitch memory (current total excitation is unavailable)
    eMem = ShiftVector (eMem, NaN * ones (N, 1));

    m = m + N;
    N2 = N2 + N;
  end

  % Find the gain which best matches the target energy
  G = EMatch (GainT^2, ep, em);
  G = min (max (G, CNGpar.GMin), CNGpar.GMax);

  % Scale the multipulse contribution
  em = G * em;

  % Form the overall excitation (for two subframes)
  est = ep + em;
  
  % Clip the excitation memory
  es(j+1:j+N2,1) = ClipSignal (est, DecoderPar.Clippar);

  % Update the pitch memory, properly this time
  eMem = ShiftVector (eMemS, es(j+1:j+N2));

  j = j + N2;

end

% Clip the pitch memory
DecoderMem.eMem = eMem;

DecoderMem.CNG.Seed = Seed;

return

%--------------------
function G = EMatch (Et, u, v)
% Given a vector u and a vector v, consider the sum u + G v. Find
% G to make the average energy of the sum as close to a target Et
% as possible.

% Err2 = (u + Gv)'(u+Gv) - N Et
%      = G^2 v'v + 2 G u'v + u'u - NEt
%      = a G^2 + 2 b G + c
%
% The error can be set to zero, but G is not always real. If G is real
% (the discriminant is positive), then choose the real root with the
% smaller absolute value. The average energy will be exactly Et. If the
% discriminant is negative, set the derivative of Err2 with respect to
% G to zero to minimize the mean square difference,
%   Gopt = - b / (2 a).

N = length (u);
a = v' * v;     % In the case of a pulse train, this is just Np
b = u' * v;
c = u' * u - N * Et;

D = b^2 - a * c;
if (D <= 0)
  G = -b / a;
else
  G1 = (-b + sqrt (D)) / a;
  G2 = (-b - sqrt (D)) / a;
  if (abs (G2) < abs (G1))   % This has to match the C-code
    G = G2;
  else
    G = G1;
  end
end

return

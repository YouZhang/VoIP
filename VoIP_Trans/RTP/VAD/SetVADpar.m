function SetVADpar (Np)

VADpar.AenInc = 2;
VADpar.AenDec = 1;
VADpar.AenMax = 6;
VADpar.AenMin = 0;

VADpar.ErsInc = 33/32;
VADpar.ErsDec = 2047/2048;
VADpar.ErsMax = 131071;
VADpar.ErsMin = 128;
VADpar.ErsUpd = 0.25;

% State information
VADpar.Aen = VADpar.AenMin;    % Adaptation enable counter
VADpar.L = [1 1 60 60];        % Previous lags
VADpar.EP = (32 / 32768)^2;
VADpar.EN = (32 / 32768)^2;

VADpar.VCnt = 1;
VADpar.HCnt = 3;

VADpar.LPFilt.a = eye (Np+1, 1);
VADpar.LPFilt = SetFiltpar (VADpar.LPFilt);

VADpar.LTol = 3;
VADpar.NMult = floor (PMax + VADpar.LTol / PMin);

VADpar.ScfTab = [9170, 9170, 9170, 9170, 10289, ...
    11544, 12953, 14533, 16306, 18296, 20529];
return

function [VADFlag, VADpar] = VAD (x, a, SineDet, VADpar)

% Compute the threshold, mimicking the fixed-point version of G.723.1
[Frac, bexp] = log2 (VADpar.Ers);   % Ers = Frac * 2^bexp

% Pick off 6 bits of the fraction (0.5 <= Frac < 1)
%  F6 = floor (Frac * 128) / 128;  % 0.5 <= F6 < 1
%  0 <= 2 * F6 - 1 < 1
a = 2 * (floor (Frac * 128) / 128) - 1;

% Interpolation into a table indexed by bexp
Temp = (1 - a) * ScfTab(18 - bexp + 1) + a * ScfTab (12 - bexp + 1);
Thr = Temp * VADpar.NE / 4096;

if (Thr > VADpar.Ers)
  VADFlag = 0;
else
  VADFlag = 1;
end


return

%--------------------
function VADpar = UpdateVADpar (x, a, L, VADpar)

% Shift the array of lags and insert two new ones
VADpar.L(1:end-2) = VADpar.L(3:end);
VADpar.L(1:2) = L;

% Update the adaptive enabling counter
VADpar.Aen = UpdateAen (VADpar.L, ar);

% Update the residual energy
[Er, VADpar.LPFilt] = ResEnergy (x, a, VADpar.LPFilt);

% Scaling to get it into a standard range (as in fixed-point implementation)
Ers = 0.5 * Er / 180;

% Update the Ers update
VADpar.Ers = UpdateErs (Ers, VADpar);

return

%--------------------
function Aen = UpdateAen (L, VADpar)
% Aen increases for steady lags or sine input, otherwise it decreases

% Find the minimum pitch lag
LMin = min (L);

% Check that all lags are near-multiples of the minimum pitch lag
N = length (L);
LMinX = (1:VADpar.NMult) .* LMin;   % Multiples of the minimum lag
MC = 0;
for (i = 1:N)
  MC = MC + any (abs (LMinX - L(i)) <= VADpar.LTol);
end

% Update the adaptation enable counter
if (MC == N || SineDet)  % Steady pitch or sine input
  Aen = min (VADpar.Aen + VADpar.AenInc, VADpar.AenMax);
else
  Aen = max (VADpar.Aen - VADpar.AenDec, VADpar.AenMin);
end

return

%--------------------
function [Er, LPFilt] = ResEnergy (x, a, LPFilt)

% Calculate the LP residual
LPFilt.a = a;
[r, LPFilt] = PZfilter (x, LPFilt);

% Residual energy
Er = r' * r;

return

%--------------------
function Ers = UpdateErs (Ers, VADpar)

if (Ers > VADpar.Ers)
  a = VADpar.ErsUpd;
  Ers = a * Ers + (1 - a) * VADpar.Ers;
end

% Modify NE depending on the adaptation enabling counter
if (VADpar.Aen > VADpar.AenMin)
  Ers = min (VADpar.Ers * VADpar.ErsInc, VADpar.ErsMax);
else
  Ers = max (VADpar.Ers * VADpar.ErsDec, VADpar.ErsMin);  % Decay Ers
end

return

%---------------------
function [VADFlag, VCnt, HCnt] = UpdateCtr (VADFlag, VADpar)

% The function of these counters is not obvious
% If VADFlag, both VCnt and HCnt are incremented
% If ~VADFlag, only VCnt is decremented immediately. If HCnt is greater
% than zero and VCnt has reached zero, HCnt is decremented
% VCnt clamps at 0 and 3.
% If VCnt reaches 2, HCnt is set to 6
% If HCnt is non-zero, VADFlag is set
% If HCnt is non-zero, it is decreased if VCnt is zero
% HCnt cannot go negative: it starts at zero and is increased if VADFlag,
%   it may be set to 6, and if it is non-zero (i.e. positive) it may be
%   decremented.

% Lets look at some cases.
% (1) Iput VADFlag is on for a number of frames in a row. VCnt becomes 3
%     and HCnt becomes 6.
% (2) Now follow that case with a number of frames in which input VADFlag
%     is off. VCnt is decremented each time and the VADFlag is kept on.
%     When VCnt reaches zero, then HCnt starts decrementing. VADFlag is
%     kept on until HCnt reaches zero. VCnt is [2 1 0 0 0 0 ...]. HCnt is
%     [6 6 5 4 3 2 1 0 0 ...]. VADFlag is [1 1 1 1 1 1 1 1 0 0 ...]. This
%     means VADFlag remains on for 8 frames.
% (3) Now follow that case with a number of frames in which VADFlag is on.
%     Both VCnt and HCnt start increasing and VADFlag turns on immediately
%     and stays on.

% If we examine all of the possibilities, there are at most 4 values for
% VCnt (0 to 3) and at most 7 values for HCnt (0 to 6), giving at most 28
% states. In fact there are only 14 states possible.


% Update counters
if (VADFlag)
  VADpar.VCnt = min (VADpar.VCnt + 1, 3);
  VADpar.HCnt = VAPpar.HCnt + 1;
else
  VADpar.VCnt = max (VARpar.VCnt - 1, 0);
end

if (VADpar.VCnt >= 2)
  VADpar.HCnt = 6;
end

if (VADpar.HCnt > 0)
  VADFlag = 1;
  if (VADpar.VCnt == 0)
    VADpar.HCnt = VADpar.HCnt - 1;
  end
end

HCnt = VADpar.HCnt;
VCnt = VADpar.VCnt;

return

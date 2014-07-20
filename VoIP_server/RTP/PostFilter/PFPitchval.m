function PFval = PFPitchval (L, eMem, FMode, LSubframe, PFpar)
% Find the pitch postfilter parameters for each subframe.

% $Id: PFPitchval.m,v 1.4 2009/07/16 16:09:19 pkabal Exp $

Ne = length (eMem);
LFrame = sum (LSubframe);
iS = Ne - LFrame + 1;

NSubframe = length (LSubframe);
LPrev = NaN;
for (i = 1:NSubframe)

  if (PFpar.PMode(i) == 1)
    Li = L(i);
    LPrev = Li;
  else
    Li = LPrev;
    LPrev = NaN;
  end

  N = LSubframe(i);
  PFval(i) = PFPitchval_SF (Li, eMem, iS, N, FMode, PFpar);

  iS = iS + N;
  
end

return

% ----------
function PFval = PFPitchval_SF (L, e, iS, N, FMode, PFpar)

iS1 = iS;
iSN = iS1 + N - 1;

% Search for the best backward and forward lags
[Lb, CLb, ELb] = B_Pitch (L, e(1:iSN), N, PFpar);
[Lf, CLf, ELf] = F_Pitch (L, e(iS1:end), N, PFpar);

E0 = e(iS1:iSN)' * e(iS1:iSN);

% Choose the best of forward / backward prediction
if (~ isnan (Lb) && ~ isnan (Lf))
  % Compare CLb^2 / ELb : CLf^2 / ELf
  if (CLb^2 * ELf > CLf^2 * ELb)
    [g, gE] = PPF_Gain (E0, CLb, ELb, FMode, PFpar);
    L = Lb;
  else
    [g, gE] = PPF_Gain (E0, CLf, ELf, FMode, PFpar);
    L = Lf;
  end
elseif (~ isnan (Lb))
  [g, gE] = PPF_Gain (E0, CLb, ELb, FMode, PFpar);
  L = Lb;
elseif (~ isnan (Lf))
  [g, gE] = PPF_Gain (E0, CLf, ELf, FMode, PFpar);
  L = Lf;
else
  g = 0;
  gE = 1;
  L = 0;
end

PFval.g = g;
PFval.gE = gE;
PFval.L = L;

return

% ----------
function [g, gE] = PPF_Gain (E0, CL, EL, FMode, PFpar)

% Check the prediction gain with the optimal gain
%   E = E0 - 2 * g * CL + g^2 * EL
%   gopt = - CL / EL;
%   Emin = E0 - CL^2 / EL;
%   PG = E0 / Emin = 1 / (1 - CL^2 / (E0 * EL))
% Need PG > PGmin,
%   1 - CL^2 / (E0 * EL) < 1 / PGmin
%            1 - 1/PGmin < CL^2 / (E0 * EL)
%            E0 * EL * A < CL^2
% where A = 1 - 1/PGmin.
% For PGmin = 4/3, A = 1/4.

A = 1 - 1 / PFpar.PGMin;
if (CL^2 > A * E0 * EL)
  g = PFpar.gScale(FMode+1) * min (CL/ EL, PFpar.gMax);
  E = E0 + 2 * g * CL + g^2 * EL;
  if (E >= PFpar.EThr)
    gE = sqrt (E0 / E);
  else
    gE = 0;
  end
else
  g = 0;
  gE = 1;
end

return

% ----------
function [L, CL, EL] = B_Pitch (L, e, N, PFpar)
% Look at a block of samples in e (last N values). Search pitch lags
% around L to find the best correlation with past values. If the relative
% correlation exceeds a given value, return the lag that gives the
% highest correlation. Otherwise return the lag as zero.
% Input:  e, excitation signal, where the last N values represent the
%         current subframe.
% Output: L (lag), negative value

LOffs = PFpar.LOffs;
Lc = min (L, PFpar.PMax - max (LOffs));

% Start of block
iS1 = length (e) - N + 1;
iSN = iS1 + N - 1;

e0 = e(iS1:iSN);
CL = 0;
EL = NaN;
L = NaN;
for (Lt = -(Lc+LOffs))
  CLt = e0' * e(iS1+Lt:iSN+Lt);
  if (CLt > CL)
    CL = CLt;
    L = Lt;
  end
end

if (~ isnan (L))
  EL = e(iS1+L:iSN+L)' * e(iS1+L:iSN+L);
end

return

% ----------
function [L, CL, EL] = F_Pitch (L, e, N, PFpar)
% Look at a block of samples in e (first N values). Search pitch lags
% around L to find the best correlation with future values. If the
% relative correlation exceeds a given value, return the lag that gives
% the highest correlation. Otherwise return the lag as zero.
% Input:  e, excitation signal, where the first N values represent the
%         current subframe.
% Output: L (lag)

LOffs = PFpar.LOffs;
Lc = min (L, PFpar.PMax - max (LOffs));

% Start of block
iS1 = 1;
iSN = iS1 + N - 1;

% Check for the search range
Ne = length (e);
I = (Lc + LOffs + iSN <= Ne);
LOffs = LOffs(I);

if (~ isempty (LOffs))
  e0 = e(iS1:iSN);
end

CL = 0;
EL = NaN;
L = NaN;
for (Lt = Lc + LOffs)
  CLt = e0' * e(iS1+Lt:iSN+Lt);
  if (CLt > CL)
    CL = CLt;
    L = Lt;
  end
end

if (~ isnan (L))
  EL = e(iS1+L:iSN+L)' * e(iS1+L:iSN+L);
end

return

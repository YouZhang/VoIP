function [L, b, Pulseval] = DecodeStreamMP (QC, Pitchpar, MPpar)
% Decode the bitstream data (Multipulse mode)

% $Id: DecodeStreamMP.m,v 1.8 2009/07/15 17:07:57 pkabal Exp $

% Extract the lags and gains for the pitch and the pulse contributions
ACBLC = QC.ACBLC;
CGC = QC.CGC;
GridC = QC.MPGridC;
SignC = QC.MPSignC;
PosC = QC.MPPosC;

LThr = Pitchpar.CBookThr;

% Form the subframe codes
PC = MP_FrameDecode (PosC, MPpar);

NSubframe = length (CGC);
CBookI = NaN;
LPrev = NaN;
for (i = 1:NSubframe)

  % Get the pitch lag for subframes with absolute lag coding.
  % This lag value controls both the choice of pitch gain codebook
  % and the possibility of using shift and repeat for the multipulse
  % contribution
  PMode = Pitchpar.PMode(i);
  if (PMode == 1)
    Lt = ACBLC(i) + Pitchpar.PMin(PMode);
    CBookI = (Lt >= LThr) + 1;
  end

  % Process the combined gain code, giving the pulse gain code (24 levels)
  % and the adaptive codebook gain code (85 or 170 levels)
  if (CBookI == 1)
    [gC, ACBbC, ShiftC] = ExtractVals (CGC(i), Pitchpar.GModV{CBookI});
  else
    [gC, ACBbC] = ExtractVals (CGC(i), Pitchpar.GModV{CBookI});
    ShiftC = 0;
  end
  ACBbIB = [ACBbC + 1; CBookI];

% Get the pitch filter lag and gain vector
  [L(i), b(:,i)] = DecodeACBSF (ACBLC(i), ACBbIB, PMode, LPrev, ...
                                Pitchpar);
  LPrev = L(i);

  if (ShiftC)
    Pulseval(i).ShiftLag = Lt;
  else
    Pulseval(i).ShiftLag = Inf;
  end

  % Pulse positions and pulse gains
  [Pulseval(i).g, Pulseval(i).m] = MP_BinomDecode (i, GridC(i), ...
                                               SignC(i), PC(i), gC, MPpar);
  Pulseval(i).gC = gC;       % Needed for PLC gain

end

% Get the pitch values
%[L, b] = DecodeACB (ACBLC, ACBbIB, Pitchpar);

return

%--------------------
function MPPC = MP_FrameDecode (MPPosC, MPpar)

% More details in the coding routine.
%
% The strategy used in G.723.1 is to express the code values for each
% subframe in modulo notation,
%   c(k) = p(k) + M(k) q(k),
% where p(k) = mod(c(k),M(k)) and q(k) = floor(c(k)/M(k)). For k=1 and
% k=3, use M(k)=2^16, and for k=2 and k=4, use M(k)=2^14.
%
% The coding procedure is as follows.
% (1) Get q(k) for each subframe.
% (2) Get p(k) for each subframe.
% (3) Form a combined value as [p(4) + 9 p(3) + 90 p(2) + 810 p(1)]. This
%     is the first code word (13 bits)
% (4) The next 4 codewords are the q(k) (16, 14, 16, and 14 bits).
%
% The decoding procedure extracts the parameters
% (1) Get the p(k) for each subframe from the first codeword.
% (2) The remaining codewords are the q(k)'s.
% (2) Add the scaled p(k)'s to the q(k)'s.

ModV = MPpar.ModV;

% Get the p(k)'s
pR = ExtractVals (MPPosC(1), MPpar.pLev);
p = pR(end:-1:1);

% Add p(k)'s and scaled q(k)'s
q = MPPosC(2:end);
MPPC = p .* ModV + q;

return

%--------------------
function [g, m] = MP_BinomDecode (MPMode, MPGridC, MPSignC, MPPC, gC, MPpar)
% Form the multipulse pulse gains (signed) and positions.

% Sort the grid
Grid = sort (MPpar.Grid{MPMode}{MPGridC+1});

% Combinatoric decoding
Np = MPpar.Np(MPMode);
NGrid = length (Grid);
GridP = PP_Decode (MPPC, Np, NGrid, MPpar.nCk);

% Pulse j is in position m(j) and has gain g(j)
m = Grid(GridP ~= 0)';

% A minus gives a 1 and a plus gives a 0
% The first pulse is in the most significant position
gV = MPpar.g(gC+1);
g = repmat (gV, 1, Np);

Signs(Np:-1:1) = ExtractVals (MPSignC, Np, 2);
g(Signs ~= 0) = -gV;

return

%---------------------
function P = PP_Decode (C, Np, NGrid, CTable)
% Decode positions from a combinatoric code

m = Np;
P = zeros (NGrid, 1);
C = CTable (NGrid+1, Np+1) - 1 - C;
for (n = NGrid-1:-1:0)
  CT = CTable (n+1,m+1);
  if (C >= CT)
    C = C - CT;
    P(NGrid-1-n+1) = 1;
    m = m - 1;
    if (m == 0)
      break
    end
  end
end

return

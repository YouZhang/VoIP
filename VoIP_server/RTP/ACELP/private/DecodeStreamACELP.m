function [L, b, Pulseval] = DecodeStreamACELP (QC, Pitchpar, ACELPpar)
% Decode the bitstream data (ACELP mode)

% $Id: DecodeStreamACELP.m,v 1.9 2009/07/15 17:06:42 pkabal Exp $

% Extract the gains for the pitch and the pulse contributions
ACBLC = QC.ACBLC;
CGC = QC.CGC;
GridC = QC.ACELPGridC;
SignC = QC.ACELPSignC;
PosC = QC.ACELPPosC;

CBookI = 2;             % ACELP mode always uses the second pitch codebook
LPrev = NaN;
NSubframe = length (CGC);
for (i = 1:NSubframe)

  % Process the combined gain code, giving the adaptive codebook gain code
  % and the pulse gain code
  [gC, ACBbC] = ExtractVals (CGC(i), Pitchpar.GModV{CBookI}); 
  ACBbIB = [ACBbC + 1; CBookI];

% Get the pitch filter lag and gain vector
  PMode = Pitchpar.PMode(i);
  [L(i), b(:,i)] = DecodeACBSF (ACBLC(i), ACBbIB, PMode, LPrev, ...
                                Pitchpar);
  LPrev = L(i);

  % Pulse positions and pulse gains
  [Pulseval(i).g, Pulseval(i).m] = ACELP_Pulses (GridC(i), SignC(i), ...
                                                 PosC(i), gC, ACELPpar);
  Pulseval(i).gC = gC;       % Needed for PLC gain
%end

%[L, b] = DecodeACB (ACBLC, ACBbIB, Pitchpar);

% Pitch repetition lag and gain
%for (i = 1:NSubframe)
  ShiftLag = L(i) + ACELPpar.POffs(ACBbIB(1));
  if (ShiftLag < ACELPpar.LThr)
    ShiftGain = ACELPpar.Pg(ACBbIB(1));
  else
    ShiftLag = Inf;
    ShiftGain = 0;
  end
  Pulseval(i).ShiftLag = ShiftLag;
  Pulseval(i).ShiftGain = ShiftGain;
end

return

%--------------------
function [g, m] = ACELP_Pulses (GridC, SignC, PPosC, gC, ACELPpar)
NTrack = size (ACELPpar.Grid, 1);
Np = NTrack;

gV = ACELPpar.g(gC+1);
g = repmat (gV, 1, Np);

% Decode the signs (Np times 1 bit)
Signs = ExtractVals (SignC, Np, 2);
g(Signs == 0) = -gV;                % Signed gain per track

% Decode the pulse positions (Np times 3 bits)
PPosI = ExtractVals (PPosC, Np, 8) + 1;

for (i = 1:Np)
  m(i) = ACELPpar.Grid{i,GridC+1}(PPosI(i));  % Could be NaN
end

% Missing pulses are marked with a NaN; remove them
I = isnan (m);
m(I) = [];
g(I) = [];

return

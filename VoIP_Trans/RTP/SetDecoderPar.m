function DecoderPar = SetDecoderPar (LSubframe)
% Decoder parameters

% $Id: SetDecoderPar.m,v 1.21 2009/07/15 16:26:44 pkabal Exp $

TableDir = 'Tables';

% Generic parameters
LFrame = sum (LSubframe);
NSubframe = length (LSubframe);

% Pitch parameters
NPitch = 128;
PMIN = 18;
PMAX = PMIN + NPitch - 1;    % 128 pitch values; the last 4 are "forbidden"

%---------------------------
% LSF quantizer codebooks
LSFpar.ECWin = 0.994;
LSFpar.ECWin = fullfile (TableDir, 'LSFECWin.dat');
LSFpar.Mean = fullfile (TableDir, 'LSFMean.dat');
LSFpar.Pcof = [12/32 23/32];                                % [normal, PLC]
LSFpar.VQ = {fullfile(TableDir, 'LSFVQ1.dat'), ...
             fullfile(TableDir, 'LSFVQ2.dat'), ...
             fullfile(TableDir, 'LSFVQ3.dat')};
LSFpar.Fix.Min = 3*pi/256;
LSFpar.Fix.Max = 252*pi/256;
LSFpar.Fix.NIter = 10;

LSFpar.Fix.MinSep = [2*pi/256, 4*pi/256];                   % [normal, PLC]
LSFpar.Fix.SepCheck = LSFpar.Fix.MinSep - (1/32) * pi/256;  % [normal, PLC]
LSFpar.Fix.CosTable = fullfile (TableDir, 'Cos512.dat');
LSFpar.IntC = (1:NSubframe) / NSubframe;   % Interpolation factors

LSFpar = SetLSFpar (LSFpar);

%---------------------------
% Pitch predictor parameters
% Two modes: Mode 1: absolute pitch lag; Mode 2: relative pitch lag
Pitchpar.PMode = ones (NSubframe, 1);
Pitchpar.PMode(2:2:end) = 2;    % Alternate subframes are relative

Pitchpar.PMin = [PMIN, PMIN];
Pitchpar.PMax = [PMAX-4, PMAX];
Pitchpar.LOffs = {[-1 0 1], [-1 0 1 2]};

Pitchpar.CBookThr = min (LSubframe) - max ([Pitchpar.LOffs{:}]);  % 60 - 2

Pitchpar.b = {fullfile(TableDir, 'ACBb85.dat'), ...
              fullfile(TableDir, 'ACBb170.dat')};

% Gain coding / pitch coefficient moduli
Pitchpar.GModV = {[1 24 2048]; [1 24]};

Pitchpar = SetPitchpar (Pitchpar);

%---------------------------
% Multipulse parameters
MPpar.g = fullfile (TableDir, 'PulseG24.dat');

% MPpar.Grid{i}{j} is a vector of pulse positions (subframe i, grid j)
for (i = 1:NSubframe)
  N = LSubframe(i);
  Grid = 1:2:N;
  [MPpar.Grid{i}{1:2}] = deal (Grid, Grid + 1); % N.B. Later reversed order
end
MPpar.Np = [6 5 6 5];            % Number of pulses (each subframe)

MPpar.gIOffs = [-2 1];           % Gain index search range
MPpar.LThr = Pitchpar.CBookThr;  % Threshold for pitch repetition

% Combined coding parameters (combine 4 subframe codes to 5 values)
MPpar.ModV = [2^16 2^14 2^16 2^14];
MPpar.pLev = [9 10 9 10];        % Reverse order: p(end), ... , p(1)

MPpar = SetMPpar (MPpar);

%---------------------------
% ACELP parameters
ACELPpar.g = MPpar.g;     % Same gain table as multipulse

% ACELPpar.Grid{i,j} is a vector of pulse positions (grid j, track i)
% Assume all subframes are of the same length
N = LFrame / NSubframe;
Grid0 = 1:8:N;
[ACELPpar.Grid{1:4,1:2}] = ...
               deal (Grid0 + 0, Grid0 + 2, Grid0 + 4, Grid0 + 6, ...
                     Grid0 + 1, Grid0 + 3, Grid0 + 5, Grid0 + 7);

% Pitch repetition parameters
ACELPpar.LThr = Pitchpar.CBookThr;  % Threshold for pitch repetition
ACELPpar.POffs = fullfile (TableDir, 'ACELPPOffs170.dat');
ACELPpar.Pg = fullfile (TableDir, 'ACELPPg170.dat');

ACELPpar = SetACELPpar (N, ACELPpar);

%---------------------------
% Comfort noise parameters
% Inherit some parameters from the multipulse mode
CNGpar.Grid = MPpar.Grid;
CNGpar.Np = MPpar.Np;

% Random number seed
CNGpar.ResetSeed = 12345;

% Pitch lag / gain codebook entry ranges
CNGpar.PMin = [123 -1 123 2];
CNGpar.PMax = [143 -1 143 2];
CNGpar.PRel = [0 1 0 1];
CNGpar.b = Pitchpar.b{2}(:,2:51);

% Gain codebook
CNGpar.GainCBook = fullfile (TableDir, 'CNGGain64.dat');
CNGpar.GainDec = fullfile (TableDir, 'CNGGainDec63.dat');
CNGpar.GMin = -5000 / 32768;
CNGpar.GMax = 5000 / 32768;
CNGpar.GFactor = 0.125;
CNGpar.NG = LSubframe(end) + LSubframe(end-1);
CNGpar.GScale = sqrt (0.008333);     % sqrt (1 / CNGpar.NG)

CNGpar = SetCNGpar (CNGpar);

%---------------------------
% Packet loss concealment parameters

% Random number seed
PLCpar.ResetSeed = 0;

PLCpar.NErrMax = 3;

% Voicing decision parameters
PLCpar.N = sum (LSubframe(end-1:end));
PLCpar.PMax = PMAX;
PLCpar.LOffs = -3:3;
PLCpar.PGMin = 8/7;

% Pitch gain factor and unvoiced gain factor
PLCpar.vGainF  = 0.75;
PLCpar.uvGainF = 0.75;
PLCpar.uvGainTable = load (fullfile (TableDir, 'PLCPG24x24.dat'));

%---------------------------
% Clipping parameters
% Strange, but that is what G.723.1 uses
Clippar.MinThr = -32767.5 / 32768;
Clippar.MinVal = -32768 / 32768;
Clippar.MaxThr = 32766.5 / 32768;
Clippar.MaxVal = 32767 / 32768;

%---------------------------
% Postfilter parameters

PFpar.EThr = pow2 (1, -126) / (32768^2);    % FLT_MIN / 32768^2

% Pitch postfilter
PFpar.PMax = PMAX;
PFpar.LOffs = -3:3;
PFpar.PMode = Pitchpar.PMode;
%               Data    MP      ACELP SID  Null PLC
PFpar.gScale = [NaN, 0.1875, 0.25, NaN, NaN, NaN];
PFpar.gMax = 1;
PFpar.PGMin = 4/3;

% Format postfilter
PFpar.alpha = 1/16;
PFpar.AScale = 1 + PFpar.alpha;
PFpar.a = 1/4;
PFpar.Tp = -0.25;
PFpar.ECWinN = fullfile (TableDir, 'PFECWinN.dat');
PFpar.ECWinD = fullfile (TableDir, 'PFECWinD.dat');

% Disable formant postfilter
%PFpar.enable = 0;

Np = length (LSFpar.Mean);
PFpar = SetPFpar (Np, PFpar);

%---------------------------
% Save the parameters in a super-structure
DecoderPar.LSubframe = LSubframe;
DecoderPar.LSFpar = LSFpar;
DecoderPar.Pitchpar = Pitchpar;
DecoderPar.MPpar = MPpar;
DecoderPar.ACELPpar = ACELPpar;
DecoderPar.CNGpar = CNGpar;
DecoderPar.PLCpar = PLCpar;
DecoderPar.Clippar = Clippar;
DecoderPar.PFpar = PFpar;

return

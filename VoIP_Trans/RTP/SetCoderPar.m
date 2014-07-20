function CoderPar = SetCoderPar (Np, LSubframe)
% Coder parameters

% $Id: SetCoderPar.m,v 1.9 2009/07/15 16:26:29 pkabal Exp $

TableDir = 'Tables';

% Generic parameters
LFrame = sum (LSubframe);
NSubframe = length (LSubframe);

% Pitch parameters
NPitch = 128;
PMIN = 18;
PMAX = PMIN + NPitch - 1;    % 128 pitch values; but last 4 are "forbidden"

%---------------------------
% Highpass (DC removal) filter
HPFilt.b = [1 -1];
HPFilt.a = [1 -127/128];
HPFilt.Mem = [];

%---------------------------
% LP parameters (used by LPanal)
LPpar.Rnn = 1 / 1024;		% White noise correction
LPpar.Win = 180;   % Hamming window, length 180
LPpar.Win = fullfile (TableDir, 'Win180.dat');
LPpar.LagWin = 42.4869 / 8000; % Gaussian lag window, bandwidth expansion
LPpar.LagWin = fullfile (TableDir, 'LagWin.dat');

LPpar = SetLPpar (Np, LPpar);

%----------
LWin = length (LPpar.Win);
WRef = (LWin - 1) / 2;

% Window centre offsets in a frame
Subframe_start = cumsum (LSubframe) - LSubframe(1);
WCenter = Subframe_start + (LSubframe - 1) / 2;
WStart = floor (WCenter - WRef);
WEnd = WStart + LWin - 1;
L_lookback = max (0, max (-WStart));
L_lookahead = max (0, max (WEnd - (LFrame-1)));
LMem = L_lookback + L_lookahead;

% Extra LP analysis parameters
LPpar.FStart = L_lookback;    % Start of frame offset in buffer
LPpar.WStart = WStart;		  % Offset relative to beginning of frame
LPpar.SFRef = NSubframe;	  % Subframe number for LSF quantization
LPpar.LMem = LMem;		      % Total memory for LP analysis

%---------------------------
% LSF quantizer codebooks
LSFpar.ECWin = 0.994;
LSFpar.ECWin = fullfile (TableDir, 'LSFECWin.dat');
LSFpar.Mean = fullfile (TableDir, 'LSFMean.dat');
LSFpar.Pcof = 12/32;
LSFpar.VQ = {fullfile(TableDir, 'LSFVQ1.dat'), ...
             fullfile(TableDir, 'LSFVQ2.dat'), ...
             fullfile(TableDir, 'LSFVQ3.dat')};
LSFpar.Fix.Min = 3*pi/256;
LSFpar.Fix.Max = 252*pi/256;
LSFpar.Fix.MinSep = 2*pi/256;
LSFpar.Fix.NIter = 10;
LSFpar.Fix.SepCheck = LSFpar.Fix.MinSep - (1/32) * pi/256;
LSFpar.Fix.CosTable = fullfile (TableDir, 'Cos512.dat');
LSFpar.IntC = (1:NSubframe) / NSubframe;   % Interpolation factors

LSFpar = SetLSFpar (LSFpar);

%---------------------------
% Sine detector parameter
SineDetpar.rc = zeros (1, 16);
SineDetpar.NThr = 14;       % 14/16 above the threshold => sine
SineDetpar.rcThr = 0.95;

SineDetpar = SetSineDetpar (SineDetpar);

%---------------------------
% Target vector parameters
% Perceptual weighting parameters
TVpar.LSubframe = LSubframe;
PWpar.ECWinN = 0.9;
PWpar.ECWinN = fullfile (TableDir, 'PWECWinN.dat');
PWpar.ECWinD = 0.5;
PWpar.ECWinD = fullfile (TableDir, 'PWECWinD.dat');
TVpar.PWpar = SetPWpar (Np, PWpar);

% Pitch estimation parameters (one estimate for every 2 subframes)
NSubframe = length (LSubframe);
for (i = 1:2:NSubframe)
  TVpar.POLSubframe((i+1)/2) = sum (LSubframe(i:min(i+1,end)));
end
PitchOLpar.PMin = PMIN;
PitchOLpar.PMax = PMAX - 3;   % Search a little beyond Pitchpar.PMax
TVpar.PitchOLpar = SetPitchOLpar (PitchOLpar);

% Harmonic noise weighting parameters
HNWpar.dL = -3:3;
HNWpar.PGMin = 1.6;     % Minimum prediction gain
HNWpar.GF = 0.3125;     % Gain scaling factor
LMem = PitchOLpar.PMax + max (HNWpar.dL);

TVpar.HNWpar = SetHNWpar (LMem, HNWpar);

%---------------------------
% Pitch predictor parameters
% Two modes: Mode 1: absolute pitch lag; Mode 2: relative pitch lag
Pitchpar.PMode = ones (NSubframe, 1);
Pitchpar.PMode(2:2:end) = 2;    % Alternate subframes are relative

Pitchpar.PMin = [PMIN, PMIN];
Pitchpar.PMax = [PMAX-4, PitchOLpar.PMax];
Pitchpar.LOffs = {[-1 0 1], [-1 0 1 2]};

Pitchpar.CBookThr = min (LSubframe) - max ([Pitchpar.LOffs{:}]);  % 60 - 2

Pitchpar.b = {fullfile(TableDir, 'ACBb85.dat'), ...
              fullfile(TableDir, 'ACBb170.dat')};
%Pitchpar.bb = {fullfile(TableDir, 'ACBbb85.dat'), ...
%               fullfile(TableDir, 'ACBbb170.dat')};

% Gain coding / pitch coefficient moduli
Pitchpar.GModV = {[1 24 2048]; [1 24]};

% Pitch filter taming parameters
Tamepar.g = {fullfile(TableDir, 'ACBg85.dat'), ...
             fullfile(TableDir, 'ACBg170.dat')};
Tamepar.NgVMin = [51, 93];
Tamepar.Nx = [2, 3];
Tamepar.Ex = 0.00000381464;  % Almost 2^(-18)
Tamepar.ISub = round (mean (LSubframe) / 2);
Tamepar.EMax = 256;
Tamepar.EThr = 128;

Pitchpar.Tamepar = Tamepar;
Pitchpar = SetPitchpar (Pitchpar);

%---------------------------
% Multipulse parameters
MPpar.g = fullfile (TableDir, 'PulseG24.dat');

% MPpar.Grid{i}{j} is a vector of pulse positions (subframe i, grid j)
for (i = 1:NSubframe)
  N = LSubframe(i);
  Grid = 1:2:N;
  [MPpar.Grid{i}{1:2}] = deal (Grid, Grid + 1);
end
MPpar.Np = [6 5 6 5];            % Number of pulses (each subframe)

MPpar.gIOffs = [-2 1];           % Gain index search range
MPpar.LThr = Pitchpar.CBookThr;  % Threshold for pitch repetition

% Combined coding parameters (combine 4 subframe codes to 5 values)
MPpar.ModV = [2^16 2^14 2^16 2^14];
MPpar.pLev = [9 10 9 10];        % Reverse order: p(end), ... , p(1)

MPpar = SetMPpar (MPpar);

%---------------------------
% Clipping parameters
% Strange, but that is what G.723.1 uses
Clippar.MinThr = -32767.5 / 32768;
Clippar.MinVal = -32768 / 32768;
Clippar.MaxThr = 32766.5 / 32768;
Clippar.MaxVal = 32767 / 32768;

%---------------------------
% Save the parameters in a super-structure
CoderPar.LSubframe = LSubframe;
CoderPar.HPFilt = HPFilt;
CoderPar.LPpar = LPpar;
CoderPar.LSFpar = LSFpar;
CoderPar.TVpar = TVpar;
CoderPar.Pitchpar = Pitchpar;
CoderPar.SineDetpar = SineDetpar;
CoderPar.MPpar = MPpar;
CoderPar.Clippar = Clippar;

return

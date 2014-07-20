function [es, DecoderMem] = GenExcSID (QC, DecoderMem, DecoderPar)
% SID frame decoder

% DecoderMem.CNG.SIDGain is updated to the received gain value
% DecoderMem.CNG.Gain is updated to the smoothed gain value

% $Id: GenExcSID.m,v 1.5 2009/07/12 21:15:52 pkabal Exp $

CNGpar = DecoderPar.CNGpar;

% Extract the codes
GainC = QC.GainC;

% Gain calculation
SIDGain = CNGpar.GainCBook(GainC + 1);   % Decode the transmitted gain
GainP = DecoderMem.CNG.Gain;             % Previous gain

% Update the gain value
FModeP = DecoderMem.CNG.FModeP;
if (FModeP == 0 || FModeP == 1 || FModeP == 2)
  GainT = SIDGain;                  % Previous: normal transmitted frame
else
  a = CNGpar.GFactor;               % Previous: SID or null
  GainT = (1 - a) * GainP + a * SIDGain;
end
DecoderMem.CNG.SIDGain = SIDGain;
DecoderMem.CNG.Gain = GainT;

% Generate a CNG frame
[es, DecoderMem] = GenExcCNG (GainT, DecoderMem, DecoderPar);

return

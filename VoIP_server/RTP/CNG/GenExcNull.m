function [es, DecoderMem] = GenExcNull (DecoderMem, DecoderPar)
% Null frame decoder

% $Id: GenExcNull.m,v 1.6 2006/09/27 18:14:36 pkabal Exp $

CNGpar = DecoderPar.CNGpar;

% Gain calculation
SIDGain = DecoderMem.CNG.SIDGain;
GainP = DecoderMem.CNG.Gain;
FModeP = DecoderMem.CNG.FModeP;

if (FModeP == 0 || FModeP == 1 || FModeP == 2)
  % Previous: normal transmitted frame
  % Special code here: normally should never get here directly from one
  % of those modes; should always pass through SID or null frame. If we
  % arrive here, it is because a PLC frame has intervened.

  GainT = SIDGain;

else                                           % Previous: SID or null
  a = CNGpar.GFactor;
  GainT = (1 - a) * GainP + a * SIDGain;
  
end

DecoderMem.CNG.SIDGain = SIDGain;
DecoderMem.CNG.Gain = GainT;

% Generate a CNG frame
[es, DecoderMem] = GenExcCNG (GainT, DecoderMem, DecoderPar);

return

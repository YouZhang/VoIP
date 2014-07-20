function [es, DecoderMem] = GenExcACELP (QC, DecoderMem, DecoderPar)
% ACELP mode excitation generation

% $Id: GenExcACELP.m,v 1.11 2009/07/12 21:06:04 pkabal Exp $

LSubframe = DecoderPar.LSubframe;

eMem = DecoderMem.eMem;

% Extract the pitch and pulse parameters
[L, b, Pulseval] = DecodeStreamACELP (QC, DecoderPar.Pitchpar, ...
                                      DecoderPar.ACELPpar);

NSubframe = length (LSubframe);
j = 0;
for (i = 1:NSubframe)

  N = LSubframe(i);

  % Pitch contribution
  ep = PitchContrib (N, L(i), b(:,i), eMem, DecoderPar.Pitchpar);

  % Fixed codebook contribution
  em = ACELPContrib (N, Pulseval(i));
  es(j+1:j+N,1) = ep + em;

  % Shift the pitch memory
  eMem = ShiftVector (eMem, es(j+1:j+N));

  j = j + N;

end

% PLC setup
[DecoderMem.PLC.uvGain, DecoderMem.PLC.L] = ...
                         PLCUpdate (L, eMem, Pulseval, DecoderPar.PLCpar);
                       
% Gain for CNG
DecoderMem.CNG.SIDGain = CNGUpdate (eMem, DecoderPar.CNGpar);

% Pitch postfilter values (before clipping)
FMode = 2;
PFval = PFPitchval (L, eMem, FMode, LSubframe, DecoderPar.PFpar);

% Clip the pitch memory
DecoderMem.eMem = ClipSignal (eMem, DecoderPar.Clippar);

% Apply the pitch postfilter (after clipping)
if (DecoderPar.PFpar.enable)
  es = PPostFilter (DecoderMem.eMem, PFval, LSubframe);
end

return

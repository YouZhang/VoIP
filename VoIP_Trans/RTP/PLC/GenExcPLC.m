function [es, DecoderMem] = GenExcPLC (DecoderMem, DecoderPar)
% Packet loss frame decoder
% The previous data is taken from DecoderMem.eMem. This is the excitation
% from the previous frame.

% $Id: GenExcPLC.m,v 1.5 2004/08/06 23:18:40 kabal Exp $

LSubframe = DecoderPar.LSubframe;
LFrame = sum (LSubframe);

eMem = DecoderMem.eMem;
NErr = DecoderMem.PLC.NErr;
DecoderMem.PLC.uvGain = DecoderMem.PLC.uvGain * DecoderPar.PLCpar.uvGainF;

% Update the error count
NErr = NErr + 1;

% If too many consecutive errors, set the output to zero
if (NErr >= DecoderPar.PLCpar.NErrMax)
  es = zeros (LFrame, 1);
  eMem = zeros (size (eMem));

else

  L = DecoderMem.PLC.L;
  if (~ isnan (L))

    % Voiced
    % Zero input, recursive filtering of past excitation
    es = DecoderPar.PLCpar.vGainF * RepExc (eMem, LFrame, L);
    eMem = ShiftVector (eMem, es);

  else

    % Unvoiced
    [esN, DecoderMem.PLC.Seed] = RandVal (DecoderMem.PLC.Seed, LFrame);
    es = DecoderMem.PLC.uvGain * esN;

    % Clear memory
    eMem = zeros (size (eMem));

  end

end

DecoderMem.eMem = eMem;
DecoderMem.PLC.NErr = NErr;

return

% -------------------------
function [RV, Seed] = RandVal (Seed, NVal)
% Generate NVal random numbers in [-1, +1) as a column vector.

for (i = 1:NVal)

  Seed = mod (521 * Seed + 259, 65536);

  % Create a signed value
  Val = Seed;
  if (Val >= 32768)
    Val = Val - 65536;
  end

  % Scale to [-1, +1)
  RV(i,1) = Val / 32768;  
end

return

function [xh, DecoderMem] = LPFilt (FMode, es, LSFC, DecoderMem, DecoderPar)
% LP synthesis filter and formant postfilter

% $Id: LPFilt.m,v 1.8 2009/07/12 21:20:51 pkabal Exp $

LSubframe = DecoderPar.LSubframe;
NSubframe = length (LSubframe);

% Generate the interpolated LP parameters (one vector for each subframe)
[aQI, DecoderMem] = Gen_aQI (FMode, LSFC, DecoderMem, DecoderPar.LSFpar);

% Generate the output samples
SMem = DecoderMem.SMem;
PFmem = DecoderMem.PF;
j = 0;
for (i = 1:NSubframe)

  N = LSubframe(i);

  % LP synthesis filter
  [xs, SMem] = PZFilter (1, aQI(:,i), es(j+1:j+N), SMem);

  % Formant postfilter
  if (DecoderPar.PFpar.enable)
    [xs, PFmem] = FPostFilter (xs, aQI(:,i), PFmem, DecoderPar.PFpar);
  end

  xh(j+1:j+N,1) = xs;
  j = j + N;
end

DecoderMem.SMem = SMem;
DecoderMem.PF = PFmem;

return

% ----------
function [aQI, DecoderMem] = Gen_aQI (FMode, LSFC, DecoderMem, LSFpar)
% Generate the interpolated LP parameters

% - The previous quantized LSF's are in DecoderMem.lsfQ.
% - The previous quantized LSF's from a non-PLC frame are in
%   DecoderMem.CNG.lsfSID.
% - For FMode equal to 1 or 2, the LSF codes are input. The interpolated
%   LSF's are created from the previous LSF's and  the current LSF's.
% - For a null CNG frame, interpolation is between the previous LSF's and
%   lsfSID. These differ only immediately after a PLC frame.
% - For a PLC frame, interpolation is between the previous LSF's and a
%   default value.

lsfQ = DecoderMem.lsfQ;

if (FMode == 0)         % Data file input
  aQI = LSFC;           % Input is already LP parameters

elseif (FMode == 4)     % Null frame
  aQI = LSFxLPI (DecoderMem.CNG.lsfP, lsfQ, LSFpar);

elseif (FMode == 5)     % PLC frame
  [aQI, lsfQ] = LSFCxLPI ([], lsfQ, LSFpar);

else                    % MP, ACELP, or SID frame
  [aQI, lsfQ] = LSFCxLPI (LSFC, lsfQ, LSFpar);

end

if (FMode == 4)
  lsfQ = DecoderMem.CNG.lsfP;
elseif (FMode ~= 5)
  % Update the last non-PLC LSF vector
  DecoderMem.CNG.lsfP = lsfQ;
end

DecoderMem.lsfQ = lsfQ;

return

function [es, DecoderMem] = GenExcDAT (VC, DecoderMem, DecoderPar)
% Data file mode decoder. The input VC is from a data passed from the coder
% (without passing through a bitstream file).

% $Id: GenExcDAT.m,v 1.9 2009/07/15 17:03:34 pkabal Exp $

FMode = VC.FType + 1;
if (FMode ~= 1 && FMode ~= 2)
  error ('GenExcDAT: Unsupported mode for data files');
end

LSubframe = DecoderPar.LSubframe;

eMem = DecoderMem.eMem;

L = VC.L;
b = VC.b;
em = VC.em;

NSubframe = length (LSubframe);
LeMem = length (eMem);
j = 0;
for (i = 1:NSubframe)

  N = LSubframe(i);

  % Pitch contribution
  ep = PitchContrib (N, L(i), b(:,i), eMem, DecoderPar.Pitchpar);

  % Total excitation
  es(j+1:j+N,1) = ep + em(:,i);

  % Shift the pitch memory
  ex = [eMem; es(j+1:j+N)];
  eMem = ex(end-LeMem+1:end);

  j = j + N;

end

% Pitch postfilter values (before clipping)
PFval = PFPitchval (L, eMem, FMode, LSubframe, DecoderPar.PFpar);

% Clip the pitch memory
DecoderMem.eMem = ClipSignal (eMem, DecoderPar.Clippar);

% Apply the pitch postfilter (after clipping)
if (DecoderPar.PFpar.enable)
  es = PPostFilter (DecoderMem.eMem, PFval, LSubframe);
end

return

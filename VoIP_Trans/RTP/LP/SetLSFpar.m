function LSFpar = SetLSFpar (LSFpar)
% Set LSF parameters
%
% LSFpar.ECWin - Window applied to error filter coefficients
%                File name, window vector, or expansion factor.
%                Returned as a column vector default [1; ...; 1].
% LSFpar.Mean:  Mean LSF values; File name or vector
% LSFpar.VQ{1}: VQ table for first split VQ of differential LSF's
% LSFpar.VQ{2}: VQ table for second split VQ of differential LSF's
% LSFpar.Pcof:  LSF predictor coefficient (for differential quantization)
% LSFpar.IntC:  Interpolation coefficients
% LSFpar.Fix.Min
% LSFpar.Fix.Max
% LSFpar.Fix.MinSep
% LSFpar.Fix.SepCheck
% LSFpar.Fix.NIter
% LSFpar.Fix.CosTable: Cosine table
%               File name, cosine values, or table length.

% $Id: SetLSFpar.m,v 1.3 2004/07/05 17:03:06 kabal Exp $

Nsplit = length (LSFpar.VQ);

% Get the VQ tables, so Np can be determined
Np = 0;
for (i = 1:Nsplit)
  if (ischar (LSFpar.VQ{i}))
    LSFpar.VQ{i} = load (LSFpar.VQ{i});
  end
  Np = Np + size (LSFpar.VQ{i}, 1);
end

% Bandwidth expansion
if (isfield (LSFpar, 'ECWin'))
  if (ischar (LSFpar.ECWin))
    LSFpar.ECWin = load (LSFpar.ECWin);
  elseif (length (LSFpar.ECWin) == 1)
    alpha = LSFpar.ECWin;
    LSFpar.ECWin = alpha.^(0:Np);
  end
else
  LSFpar.ECWin = ones (Np+1, 1);
end

LSFpar.ECWin = LSFpar.ECWin(:);

% VQ parameters
if (ischar (LSFpar.Mean))
  LSFpar.Mean = load (LSFpar.Mean);
end

if (~ isfield (LSFpar, 'Pcof'))
  LSFpar.Pcof = 1;
end

% Fix-up parameters
if (~ isfield (LSFpar, 'Fix'))
  LSFpar.Fix = [];
end
Fix = LSFpar.Fix;
if (~ isfield (Fix, 'Min'))
  Fix.Min = 0;
end
if (~ isfield (Fix, 'Max'))
  Fix.Max = pi;
end
if (~ isfield (Fix, 'MinSep'))
  Fix.MinSep = 0;
end
if (~ isfield (Fix, 'SepCheck'))
  Fix.SepCheck = 0;
end
if (~ isfield (Fix, 'NIter'))
  Fix.NIter = 10;
end

% Cosine table
if (isfield (Fix, 'CosTable'))
  if (ischar (Fix.CosTable))
    Fix.CosTable = load (Fix.CosTable);
  elseif (length (Fix.CosTable) == 1)
    NCos = Fix.CosTable;
    Fix.CosTable = cos ((0:(NCos-1)) * 2 * pi / NCos);
  end
end

LSFpar.Fix = Fix;

return

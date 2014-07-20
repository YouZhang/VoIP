function PrintQCodes (FName, FileO, Frames)
% Print the code values in a ITU-T G.723.1 coder bitstream file
%   PrintQCodes (FName)
%   PrintQCodes (Fname, Frames)
%   PrintQCodes (Fname, FileO)
%   PrintQCodes (Fname, FileO, Frames)
% FName: Bitstream file
% FileO: Output file (default to screen)
% Frames: Frames to include, default [1, inf]

% $Id: PrintQCodes.m,v 1.8 2009/07/15 16:26:14 pkabal Exp $

G7231Dir = fileparts (which ('G7231Coder.m'));
addpath (fullfile (G7231Dir, 'BitStream'));

if (nargin == 2)
  if (ischar (FileO))
    Frames = [1 inf];
  else
    Frames = FileO;
    FileO = [];
  end
elseif (nargin < 2)
  Frames = [1 Inf];
  FileO = [];
end

if (~ isempty (FileO))
  FID = fopen (FileO, 'wt');
else
  FID = 1;
end

% Read the bitstream file
QC = ReadG7231Stream (FName, Frames);
NF = length (QC);

IFr = Frames(1);
for (k = 1:NF)

  fprintf (FID, ' Frame: %d,', IFr);
  PrintQC (FID, QC(k));

  IFr = IFr + 1;
end

if (~ isempty (FileO))
  fclose (FID);
end

return

%--------------------
function PrintQC (FID, QC)

if (QC.FType == 0)
  fprintf (FID, ' Rate: 6.3 kb/s -----\n');
elseif (QC.FType == 1)
  fprintf (FID, ' Rate: 5.3 kb/s -----\n');
elseif (QC.FType == 2)
  fprintf (FID, ' SID frame      -----\n');
else
  fprintf (FID, ' Empty frame    -----\n');
end

if (QC.FType <= 2)
  fprintf (FID, '  LSF codes: %d %d %d\n', QC.LSFC);
end
if (QC.FType == 2)
  fprintf (FID, '  Gain code: %d\n', QC.GainC);
end
if (QC.FType <= 1)
  fprintf (FID, '  Adaptive codebook lag codes: %d %d %d %d\n', QC.ACBLC);
  fprintf (FID, '  Combined gain codes: %d %d %d %d\n', QC.CGC);
end
if (QC.FType == 0)
  fprintf (FID, '  Multipulse grid codes: %d %d %d %d\n', QC.MPGridC);
  fprintf (FID, '  Multipulse position codes: %d %d %d %d %d\n', QC.MPPosC);
  fprintf (FID, '  Multipulse sign codes: %d %d %d %d\n', QC.MPSignC);
elseif (QC.FType == 1)
  fprintf (FID, '  ACELP grid codes: %d %d %d %d\n', QC.ACELPGridC);
  fprintf (FID, '  ACELP position codes: %d %d %d %d %d\n', QC.ACELPPosC);
  fprintf (FID, '  ACELP sign codes: %d %d %d %d\n', QC.ACELPSignC);
end

return

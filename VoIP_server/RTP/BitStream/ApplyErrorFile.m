function QC = ApplyErrorFile (FName, QC)
% Read the frame error file; set the frame type in QC for error frames

% $Id: ApplyErrorFile.m,v 1.2 2009/07/16 16:00:17 pkabal Exp $

FErr = ReadErrFile (FName);

% Check the error file
NFrame = length (QC);
if (length (FErr) ~= NFrame)
  error ('G7231Decoder: Invalid frame error file length');
end
  
% Set FType for marked frames from the frame error file
QCN = NullStruct (QC);
QCN.FType = 4;
I = (FErr ~= 0);
QC(I) = QCN;

return

% ----- -----
function FErr = ReadErrFile (FName)

fid = fopen (FName, 'r', 'l');        % Little-endian
if (fid == -1)
  error ('G7231Decoder: Cannot open input frame error file');
end
FErr = (fread (fid, Inf, 'uint16') ~= 0);
fclose (fid);

fprintf ('G.723.1 Frame error file: %s\n', FullName (FName));

return


function [x, Nv, AFPar] = ReadAudioData (AFPar, offs, Ns)
% Read data from an audio file. This routine handles WAVE, AU, and
% headerless (raw) files. This routine maintains an internal buffer to
% make file access more efficient when accessing small chunks of data.
% In addition, the data in the file is treated as if it were preceded
% and followed with zeros.
%
%   x = ReadAudioData (File)
%   x = ReadAudioData (File, offs, Ns)
% This case represents the simple interface for reading data from an audio
% file in one shot. Internally, ReadAudioData calls OpenAudioFile to get
% the file parameters. This simple interface cannot be used for headerless
% files.
% - x:    Audio data
% - offs: Offset from the beginning of the file for the start of data
%         (default zero)
% - Ns:   Number of samples to be read (default to end-of-file)
%
%   [x, Nv, AFPar] = ReadAudioData (AFPar, offs, Ns)
% This case is used for repeated reading of data from a file. The file must
% be first opened with OpenAudioFile. OpenAudioFile returns the structure
% AFPar which is used as input to ReadAudioData.
% - x:  Audio data
% - Nv: Number of samples (not including trailing zeros) returned. This
%       value can be used to determine when the end-of-file occurs.
% - AFPar: Structure from OpenAudioFile (input and output)
% - offs: Offset from the beginning of the file for the start of data
%       (default zero)
% - Ns: Number of samples to be read (default to end-of-file)
%
% AFPar contains a buffer of samples. Requests are checked whether they can
% be satisfied from the buffer without accessing the file. The structure
% AFPar can be cleared when reading is finished ("clear AFpar") to recover
% the space used for buffering.
%
% Note that the audio data in the file is considered to be preceded and
% followed by zeros. With this convention, the offset can be negative, in
% which case zeros are added in front of the data. Also the read can extend
% beyond the end-of-file, in which case zeros are added at the end of the
% data.

% $Id: ReadAudioData.m,v 1.6 2009/07/24 16:43:16 pkabal Exp $

% Notes:
% - This routine is designed for programs which access audio data frame by
%   frame.
% - The audio file reading routines in Matlab, open and close the audio
%   file on each access. This routine trades off the number of file
%   accesses and internal buffer size. For short files, the data will fit
%   into the buffer, and no further access to the file is necessary. The
%   penalty for this buffer is that it must be passed into the read routine
%   and back out of the read routine.
% - For some accesses, the data is written directly to the user buffer.
%   This occurs at the end of the file or when the entire data is
%   requested. The internal buffer is then deallocated. This means that
%   for sequential access, on the last access to the file, the buffer is
%   deallocated.
% - Some provision for accessing the file backwards is provided. If the
%   routine detects that accesses are occurring at offsets which decrease,
%   the buffer becomes "look-back" rather than "look-ahead".

% Call OpenAudioFile if the first argument is not a structure
if (~isstruct (AFPar))
  File = AFPar;
  AFPar = OpenAudioFile (File);
end

Nsamp = AFPar.Nsamp;
Nchan = AFPar.Nchan;

% Default values for offs and Ns
if (nargin < 2)
  offs = 0;
end
if (nargin < 3)
  Ns = max (0, Nsamp - offs);
end

% Allocate storage and zero the output array
x = zeros (Ns, Nchan);

% Calculate number of zeros before the start of data
Nz = 0;
if (offs < 0)
  Nz = min (-offs, Ns);
  offs = offs + Nz;
end

% Get samples from the file
Nf = min (Ns - Nz, Nsamp - offs);
if (offs >= 0 && Nf > 0)
  if (nargout < 3)
    x(Nz+1:Nz+Nf,:) = AF_audio_data (AFPar, offs, Nf);
  else
    [x(Nz+1:Nz+Nf,:), AFPar] = AF_audio_data (AFPar, offs, Nf);
  end
end

% Number of samples, excluding zeros added after file data
Nv = Nz + Nf;

%------------------------
function [x, AFPar] = AF_audio_data (AFPar, offs, Ns)

MAXBUFF = 50000;

NBuff = size (AFPar.Buff, 1);
Rlimits = [offs offs+Ns-1];                   % Request limits
Blimits = [AFPar.Offs AFPar.Offs+NBuff-1];    % Buffer limits
Dlimits = [0 AFPar.Nsamp-1];                  % Data limits

% Error check (should never occur if called properly)
if (Rlimits(1) < Dlimits(1) && Rlimits(2) >= Dlimits(2))
  error ('ReadAudioData: Invalid limits');
end

% Data available in the buffer
if (Rlimits(1) >= Blimits(1) && Rlimits(2) <= Blimits(2))
  Boffs = Rlimits(1)-Blimits(1);
  x = AFPar.Buff(Boffs+1:Boffs+Ns,:);

% Read data directly into the user buffer
% - If the data is not available in the buffer
%   - When the read is up to the end of the file
%   - When the transfer is a large amount such that two successive reads of
%     the same amount would entail going to the file
%   - When the output structure is not used   
elseif (Rlimits(2) == Dlimits(2) || Ns > 0.5 * MAXBUFF || nargout < 2)
  x = AF_Read_audio_data (AFPar, Rlimits);
  AFPar.Buff = [];     % Delete the buffer to save space
  AFPar.Offs = Rlimits(1);

% Data has to be refreshed into the buffer
% Determine if the data is being read in the forward direction or in
% the reverse direction.
else

  % Special case: empty buffer
  if (NBuff == 0 && AFPar.Nsamp <= MAXBUFF)
    Blimits = Dlimits;
    
  % Moving forward
  elseif (Rlimits(1) >= AFPar.Offs)
    NBuff = min (Dlimits(2)-Rlimits(1)+1, MAXBUFF);
    Blimits = [Rlimits(1) Rlimits(1)+NBuff-1];

  % Moving backward
  else
    NBuff = min (Rlimits(2)-Dlimits(1)+1, MAXBUFF);
    Blimits = [Rlimits(2)-NBuff+1 Rlimits(2)];

  end

  % Refresh buffer
  AFPar.Buff = AF_Read_audio_data (AFPar, Blimits);
  AFPar.Offs = Blimits(1);

  % Move data from the buffer to the output
  BOffs = Rlimits(1)-Blimits(1);
  x = AFPar.Buff(BOffs+1:BOffs+Ns,:);

end

return

%----------------------
function x = AF_Read_audio_data (AFPar, Rlimits)

switch AFPar.Ftype
    case 'WAVE'
        x = wavread (AFPar.Fname, Rlimits + 1);
    case 'AU'
        x = auread (AFPar.Fname, Rlimits + 1);
    case 'Raw'
        x = AFrawRead (AFPar.Fname, Rlimits + 1, AFPar.Swapb, ...
                     AFPar.Start, AFPar.Nchan);
    otherwise
        error ('ReadAudioData: Unsupported audio file type');
end

return

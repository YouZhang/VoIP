function AFPar = OpenAudioFile (File, AFPar)
% Print information about an audio file, pick up the file parameters. This
% routine can open WAVE, AU, and  headerless (raw) audio files. The audio
% file is opened temporarily to access this information.
%
% AFPar = OpenAudioFile (File)
% AFPar = OpenAudioFile (File, AFPar)  % For headerless files only
% The output structure AFPar is used as input to ReadAudioData to read
% audio data from the file.
%
% The second argument to OpenAudioFile is used to determine if the input
% file is to be considered as headerless. If that argument is not present,
% headerless files will not be accepted. For headerless files, the input
% structure contains information about the file format. For headerless
% files, it is assumed that data is in 16-bit format.
%   AFPar.Sfreq: Sampling frequency (Hz), defaults to 8000
%   AFPar.Nchan: Number of channels, defaults to 1
%   AFPar.Swapb: Data swap information, 'Native', Swap', 'Little-endian',
%                or 'Big-endian', defaults to 'Native'
%   AFPar.Start: Start byte for data
%
% For the case of reading all of the audio data in one shot, ReadAudioData
% can be used directly (it will call OpenAudioFile itself).
%
% The parameters in the output structure AFPar useful for end users are
%   - AFPar.Sfreq: Sampling frequency (Hz)
%   - AFPar.Nsamp: Number of samples per channel
%   - AFPar.Nchan: Number of channels
%   - AFPar.Fname: Full file name
%   - AFPar.Dformat: Data format ('integer16', ...)
% The output structure contains additional fields used to store state
% information for use by ReadAudioData, including a data buffer. Note that
% audio file does not remain open, it is opened and closed on each access.
% The data buffer in AFPar is used to reduce the number of accesses to the
% file. The structure AFPar can be cleared ("clear AFpar") to recover the
% space used for buffering.
%
% The parameters in the output structure used to store state information
% are:
%   - AFPar.Buff: Sample buffer
%   - AFPar.Offs: Sample buffer contains data at Offs samples from the
%     beginning of data in the file
%   - AFPar.Ftype: File type ('WAVE', 'AU', 'Raw')
%   - AFPar.Start: File offset in bytes to start of data (used only for
%     headerless files)
%   - AFPar.Swapb: Data byte order ('Native', etc.; used only for
%     headerless files)

% $Id: OpenAudioFile.m,v 1.8 2009/07/21 12:08:36 pkabal Exp $

% Open the file for a peek at the first 4 characters
fid = fopen (File, 'r');

if (fid == -1)
  error ('OpenAudioFile: Cannot open audio file for reading');
end
File = FullName (File);

id = char (fread (fid, 4, 'uchar')');
fclose (fid);

switch id
  case 'RIFF'
    AFPar = OpenWAVEFile (File);
  case '.snd'
    AFPar = OpenAUFile (File);
  otherwise
    if (nargin == 2)
      AFPar = OpenRawFile (File, AFPar);
    else
      error ('OpenAudioFile: Unsupported file type');
    end
end

% Set up a null buffer
AFPar.Buff = [];
AFPar.Offs = 0;

PrintAudioFilePar (AFPar);

% --------------------
function AFPar = OpenWAVEFile (File)

[Size Sfreq NbS opt] = wavread (File, 'size');
AFPar.Ftype = 'WAVE';
AFPar.Fname = File;
AFPar.Sfreq = Sfreq;
AFPar.Nsamp = Size(1);
AFPar.Nchan = Size(2);
AFPar.Dformat = 'unsupported';
switch opt.fmt.wFormatTag
  case 1
    switch NbS
      case 8
        AFPar.Dformat = 'unsigned8';
      case 16
        AFPar.Dformat = 'integer16';
      case 24
        AFPar.Dformat = 'integer24';
      case 32
        AFPar.Dformat = 'integer32';
    end
  case 2
    switch NbS
      case 32
        AFPar.Dformat = 'float32';
      case 64
        AFPar.Dformat = 'float64';
    end
  case 6
    AFPar.Dformat = 'mu-law8';
  case 7
    AFPar.Dformat = 'A-law8';
end

return

% --------------------
function AFPar = OpenAUFile (File)

[Size Sfreq NbS] = auread (File, 'size');
AFPar.Ftype = 'AU';
AFPar.Fname = File;
AFPar.Sfreq = Sfreq;
AFPar.Nsamp = Size(1);
AFPar.Nchan = Size(2);

% auread does not return the data format directly
% 8 bits/sample can be mulaw8, A-law8 (not supported), or integer8.
% We assume it is mu-law8.
% Similarly for 32 bits/sample, we assume float32 rather than integer32.
switch NbS
  case 8
    AFPar.Dformat = 'mu-law8';
  case 16
    AFPar.Dformat = 'integer16';
  case 24
    AFPar.Dformat = 'integer24';
  case 32
    AFPar.Dformat = 'float32';
  case 64
    AFPar.Dformat = 'float64';
  otherwise
    AFPar.Dformat = 'unsupported';
end

return

% --------------------
function AFPar = OpenRawFile (File, AFPar)

if (~isfield (AFPar, 'Sfreq'))
   AFPar.Sfreq = 8000;
end
if (~isfield (AFPar, 'Nchan'))
   AFPar.Nchan = 1;
end
if (~isfield (AFPar, 'Swapb'))
   AFPar.Swapb = 'Native';
end
if (~isfield (AFPar, 'Start'))
   AFPar.Start = 0;
end

% rawread only supports 16 bits/sample
Size = AFrawRead (File, 'size', AFPar.Swapb, AFPar.Start, AFPar.Nchan);
AFPar.Ftype = 'Raw';
AFPar.Fname = File;
AFPar.Nsamp = Size(1);
AFPar.Dformat = 'integer16';

return

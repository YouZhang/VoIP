function [y,Fs,bits,opts] = AFrawRead (File, ext, Swapb, Start, Nchan)
%RAWREAD Read raw sound file.
%   Y = AFrawRead (File, [], SWAPB, START, NCHAN)
% Load a sound file specified by the string RAWFILE, returning the sampled
% data in y. Amplitude values are in the range [-1,+1]. The data in the
% the file is multichannel data in 16-bit PCM format.
%
%  SWAPB is a byte swap code taking on values of 'native', 'swap',
%    'little-endian', or 'big-endian', defaulting to 'native'. These codes
%     may be shortened down to the first letter.
%  START is the number of bytes to skip at the beginning of the file
%  NCHAN is the number of channels, defaulting to one.
%
%   Y=AFrawread(File, N, ...) returns only the first N samples from each
%       channel of the file.
%   Y=AFrawread(File, [N1 N2], ...) returns only samples N1 through N2
%       from each channel in the file.
%   SIZ=AFrawread(File, 'size', ...) returns the number of samples of
%       audio data contained in the file in place of the actual audio data,
%       returning the vector SIZ=[samples channels].

% Convert swap code to either 'B ' or 'L'
if (nargin < 3)
  Swapb = 'native';
end
Swapb = AF_DecodeSwapb(Swapb);
if (nargin < 4)
  Start = 0;
end
if (nargin < 5)
  Nchan = 1;
end

fid = fopen(File, 'rb', Swapb);
if (fid == -1)
  error('AFrawRead: Cannot open RAW audio file for input');
end

% No optional information
Fs = NaN;
bits = 16;
opts = [];

% Get the file size
fseek(fid, 0, 'eof');	% End-of-file
Nbyte = ftell(fid) - Start;
if (mod(Nbyte, 2 * Nchan) ~= 0)
  error('AFrawRead: File size / number of samples mismatch');
end
Nsamp = Nbyte / (2 * Nchan);

if (nargin < 3)
  ext = [];    % Default - read all samples
end

NE = numel(ext);
if (strncmpi(ext, 'size', NE))
  fclose(fid);
  y = [Nsamp, Nchan];  % Return data size
  return
elseif (NE > 2)
  error('AFrawRead: Data range must be a scalar or 2-element vector');
elseif (NE == 1),
  ext = [1 ext];  % Prepend start sample index
end

% Read data:
y = AF_read_rawdata(fid, ext, Nsamp, Start, Nchan);
fclose(fid);

return

% ----- -----
function Swapb = AF_DecodeSwapb (Swapb)

keys = {'native'; 'swap'; 'little-endian'; 'big-endian'};
i = strmatch(lower(Swapb), keys);
if (isempty(i))
   error ('AFrawRead: Invalid byte swap value');
end

[C, Maxsize, Endian] = computer;
if (i == 1)
   Swapb = Endian;
elseif (i == 2)
   if (strcmp(Endian, 'L') == 0)
      Swapb = 'B';
   else
      Swapb = 'L';
   end
elseif (i == 3)
   Swapb = 'L';
else
   Swapb = 'B';
end

return

% ----- -----
function data = AF_read_rawdata (fid, ext, Nsamp, Start, Nchan)

if (isempty(ext))
  ext = [1 Nsamp];    % Return all samples
else
  if (numel(ext) ~= 2 || ext(1) < 1 || ext(2) > Nsamp || ext(1) > ext(2))
    error('AFrawRead: Invalid sample limits');
  end
end

% Skip over leading data in the file
status = fseek(fid, Start+2*(ext(1)-1)*Nchan, 'bof');% 2 bytes per sample
if (status == -1)
  error('AFrawRead: File format error');
end

% Read data
nF = ext(2)-ext(1)+1;    % # samples per channel
[data, Nv] = fread(fid, [Nchan nF], 'int16');
if (Nv ~= Nchan * nF)
  error('AFrawRead: Data file is truncated');
end

% Rearrange data into a matrix with one channel per column
data = data';

% Normalize data values
data = data * 2^(-15);

return

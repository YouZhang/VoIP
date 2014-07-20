function WriteAudio (x, Fname, Fs, Dformat, Ftype)
% Write data to an audio file
%
% x:   Data to be written. Multichannel data is dimensioned Nsamp by
%      Nchan.
% Fs:  Sampling frequency
% Dformat: 'mu-law8' (AU files), 'unsigned8' (WAVE files), 'integer8'
%        (AU files), 'integer16', 'integer24' (WAVE files), or 'float32'
%        (WAVE files). The default is 'integer16'.
% Ftype: 'WAVE' or 'AU' (default 'WAVE')

% $Id: WriteAudio.m,v 1.4 2009/07/21 12:08:05 pkabal Exp $

if (size (x, 1) == 1)
  x = x(:);
end
[AFPar.Nsamp, AFPar.Nchan] = size (x);

if (nargin < 5)
  Ftype = 'WAVE';
end
AFPar.Ftype = Ftype;

if (nargin < 4)
  Dformat = 'integer16';
end
AFPar.Dformat = Dformat;

AFPar.Sfreq = Fs;
AFPar.Fname = Fname;
switch AFPar.Ftype
  case 'WAVE'
    Write_WAVE (x, AFPar); 
  case 'AU'
    Write_AU (x, AFPar);
  otherwise
    error ('WriteAudio: Unsuported file format');
end

AFPar.Fname = FullName (AFPar.Fname);
PrintAudioFilePar (AFPar);

return

% --------------------
function Write_WAVE (x, AFPar)

switch AFPar.Dformat
  case 'unsigned8'
    NBits = 8;
  case 'integer16'
    NBits = 16;
  case 'integer24'
    NBits = 24;    % Discrepancy: wavwrite documentation and wavwrite code
  case 'float32'
    NBits = 32;
  otherwise
    error ('WriteAudio: WAVE file, unsupported data format');
end

wavwrite (x, AFPar.Sfreq, NBits, AFPar.Fname);

return

% --------------------
function Write_AU (x, AFPar)

switch AFPar.Dformat
  case 'mu-law8'
    NBits = 8;
    Method = 'mu';
  case 'integer8'
    NBits = 8;
    Method = 'linear';
  case 'integer16'
    NBits = 16;
    Method = 'linear';
  otherwise
    error ('WriteAudio: AU file, unsuported data format');
end

auwrite (x, AFPar.Sfreq, NBits, Method, AFpar.Fname);

return

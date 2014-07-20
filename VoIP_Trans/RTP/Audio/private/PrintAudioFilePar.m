function PrintAudioFilePar (AFPar)
% Print audio file parameters

switch AFPar.Ftype
  case 'WAVE'
    Ftype = 'WAVE';
  case 'AU'
    Ftype = 'AU';
  case 'Raw'
    Ftype = 'Headerless';
  otherwise
    Ftype = 'unknown';
end

switch AFPar.Dformat
  case 'integer8'
    Dformat = '8-bit integer';
  case 'unsigned8';
    Dformat = 'offset-binary 8-bit integer';
  case 'integer16'
    Dformat = '16-bit integer';
  case 'integer24'
    Dformat = '24-bit integer';
  case 'integer32'
    Dformat = '32-bit integer';
  case 'float32'
    Dformat = '32-bit float';
  case 'float64'
    Dformat = '64-bit float';
  case 'mu-law8'
    Dformat = '8-bit mu-law';
  case 'A-law8'
    Dformat = '8-bit A-law';
  otherwise
    Dformat = 'unknown';
end

fprintf (' %s file: %s\n', Ftype, AFPar.Fname);
fprintf ('   Number of samples : %d (%.4g s)\n', AFPar.Nsamp, ...
              AFPar.Nsamp / AFPar.Sfreq);
fprintf ('   Sampling frequency: %g Hz\n', AFPar.Sfreq);
fprintf ('   Number of channels: %d (%s)\n', AFPar.Nchan, Dformat);

return

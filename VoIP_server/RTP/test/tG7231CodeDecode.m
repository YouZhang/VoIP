function tG7231CodeDecode

% This test exercises the bit file and data file outputs of G7231Coder and
% the bit file and data file inputs of G7231Decoder

% $Id: tG7231CodeDecode.m,v 1.2 2009/07/16 16:41:19 pkabal Exp $

TDir = 'TestFiles';
WaveFileIn = fullfile(TDir, 'FE27_04.wav');
BitFile = 'FE27_04.bit';
BitFileRef = fullfile(TDir, 'FE27_04_Mref63.bit');
DataFile = 'FE27_04.dat';
DataFileRef = fullfile(TDir, 'FE27_04_Mref63.dat');
WaveFileOutB = 'FE27_04B.wav';
WaveFileOutD = 'FE27_04D.wav';

addpath('..');

fprintf('\n----- Wave to Bit -----\n');
G7231Coder(WaveFileIn, BitFile);

fprintf('\n----- Compare Bit Files -----\n');
eval (['!FC ' BitFile ' ' BitFileRef]);

fprintf('----- Wave to Data -----\n');
G7231Coder(WaveFileIn, DataFile);

fprintf('\n----- Compare Data Files -----\n');
Compare_DATFiles (DataFile, DataFileRef);

fprintf('\n----- Bit File to Wave File -----\n');
G7231Decoder(BitFile, WaveFileOutB);
delete(BitFile);

fprintf('\n----- Data File to Wave File -----\n');
G7231Decoder(DataFile, WaveFileOutD);
delete(DataFile);

fprintf ('\n ----- Compare wave files from bit and data files\n');
eval (['!FC ' WaveFileOutB ' ' WaveFileOutD]);

delete(WaveFileOutB);
delete(WaveFileOutD);

return

% ----- -----
function Compare_DATFiles (DFile1, DFile2)

% Each data file contains a variable VC, with fields FMode, a, L,b,em
S1 = load(DFile1, '-mat');
S2 = load(DFile2, '-mat');

fprintf('Data file: %s\n', FullName(DFile1));
fprintf('Data file: %s\n', FullName(DFile2));

N1 = length(S1.VC);
N2 = length(S2.VC);

if (length(S1) ~= length(S2) || N1 ~= N2)
  error('Data files not compatible');
end

Err = 0;
for (i = 1:N1)
  Err = Compare_DataFrame (S1.VC(i), S2.VC(i), i); 
end

if (~ Err)
  fprintf('>>> No differences found\n');
end

return

% ----- -----
function Err = Compare_DataFrame (VC1, VC2, i)

Err = 0;

if (VC1.FType ~= VC2.FType)
  Err = Print_Error('FType', i, Err);
end

if (any(VC1.a(:) ~= VC2.a(:)))
  Err = Print_Error('a', i, Err);
end

if (any(VC1.L ~= VC2.L))
  Err = Print_Error('L', i, Err);
end

if (any(VC1.b(:) ~= VC2.b(:)))
  Err = Print_Error('b', i, Err);
end

if (any(VC1.em(:) ~= VC2.em(:)))
  Err = Print_Error('em', i, Err);
end

return

% ----- -----
function Err = Print_Error (Var, i, Err);

if (Err == 0 )
  fprintf('Frame %d\n', i);
end

fprintf('   %s differs\n', Var);
Err = 1;

return

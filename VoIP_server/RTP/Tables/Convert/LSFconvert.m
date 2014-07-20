function LSFconvert
% Convert pi/256 values in LSF parameter tables

% Mean (DC) values
mean = (pi / 256) * load ('C-CodeData/LSFMean0.dat');
save ('LSFMean.dat', 'mean', '-ASCII', '-DOUBLE');
size (mean)

% VQ table (dLSF1 to dLSF3)
VQ1 = (pi / 256) * load ('C-CodeData/LSFVQ10.dat');
VQ1 = VQ1';
save ('LSFVQ1.dat', 'VQ1', '-ASCII', '-DOUBLE');
size (VQ1)

% VQ table (dLSF4 to dLSF5)
VQ2 = (pi / 256) * load ('C-CodeData/LSFVQ20.dat');
VQ2 = VQ2';
save ('LSFVQ2.dat', 'VQ2', '-ASCII', '-DOUBLE');
size (VQ2)

% VQ table (dLSF6 to dLSF10)
VQ3 = (pi / 256) * load ('C-CodeData/LSFVQ30.dat');
VQ3 = VQ3';
save ('LSFVQ3.dat', 'VQ3', '-ASCII', '-DOUBLE');
size (VQ3)

return

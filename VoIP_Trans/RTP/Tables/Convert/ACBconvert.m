function ACBconvert
% Convert Adaptive Codebook quantizer gain tables
% The original coefficients are in reverse order, b5, b4, ..., b1

QT = load ('C-CodeData/ACB85.dat');
[b, bb] = ExtractQT (QT);
SaveMat ('ACBb85.dat', 'ACBbb85.dat', b, bb);
CheckGain ('..\ACBg85.dat', b);

disp ('=====================');

QT = load ('C-CodeData/ACB170.dat');
[b, bb] = ExtractQT (QT);
SaveMat ('ACBb170.dat', 'ACBbb170.dat', b, bb);

return

%---------------------------------
function SaveMat (FN1, FN2, b, bb)

[N, M, P] = size (bb);
bbb = reshape (bb, N*M, P);

save (FN1, 'b', '-ASCII', '-DOUBLE');
save (FN2, 'bbb', '-ASCII', '-DOUBLE');

c = load (FN1);
cc = load (FN2);

[NN, P] = size (cc);
N = sqrt (NN);
cc = reshape (cc, N, N, P);

disp ('-----------------');

max (max (abs (b - c)))
max (max (max (abs (bb - cc))))

Nv = size (c, 2);
for (i = 1:Nv)
  dd(:,:,i) = c(:,i) * c(:,i)';
end
max (max (max (abs (cc - dd))))

return

%---------------------
function CheckGain (FN, b)

g = load (FN);
N = length (g);

GG = zeros (N, 1);
GS = zeros (N, 1);
GA = zeros (N, 1);
GB = zeros (N, 1);
for (i = 1:N)
  GG(i) = b(:,i)' * b(:,i);
  GS(i) = sqrt (GG(i));
  GA(i) = sum (abs (b(:,i)));
  GB(i) = abs (sum (b(:,i)));
end

[g GG GS GA GB]

return

%---------------------
function [b, bb] = ExtractQT (QT)

Np = 5;
Nv = Np + Np * (Np+1) / 2;
Nq = length (QT) / Nv;

QT = reshape (QT, Nv, Nq);
fprintf ('Data size: %d by %d\n', size (QT));

bb = zeros (Np,Np,Nq);
for (k = 1:Nq)
  kk = 1;
  for (i = 1:Np)
    IR = Np+1-i;
    b(IR,k) = QT(kk,k);
    kk = kk + 1;
  end
  for (i = 1:Np)
    IR = Np+1-i;
    bb(IR,IR,k) = -QT(kk,k);
    kk = kk + 1;
  end
  for (i = 1:Np)
    IR = Np+1-i;
    for (j = 1:i-1)
      JR = Np+1-j;
      bb(IR,JR,k) = -QT(kk,k);
      bb(JR,IR,k) = -QT(kk,k);
      kk = kk + 1;
    end
  end
end

return

function ap = LPanal (x, LPpar)
% LP analysis for a frame of data
% The vector x is assumed to the same length as the window LPpar.Win.
% Returns the Np error filter coefficients [1; -p(1); ... -p(Np)] in a
% column vector, where Np is length(LPpar.LagWin) - 1.

% The LP analysis parameters can be set with SetLPpar.

% $Id: LPanal.m,v 1.5 2010/02/10 20:14:22 pkabal Exp $

Np = length(LPpar.LagWin) - 1;

% Window the data
xw = x .* LPpar.Win;    %乘以汉明窗的数据

% Correlation calculation 这里的核心应该就是LD算法了；
Rxx = LP_acorr(xw, Np+1);   %将乘以窗后的数据做交叉自相关
E0 = Rxx(1); %零时自相关
if (E0 <= 0)
  if (E0 < 0)
    error('LPanal: Negative error');
  end
  ap = zeros(Np+1);
  ap(1) = 1;

else
  Rxxp = (Rxx + E0 * LPpar.Rnn) .* LPpar.LagWin;%获得自相关矩阵Rxxp

  % Levinson recursion
  a = levinson(Rxxp, Np);   %利用迭代法求出这个系数；
  a = a(:);

  % Bandwidth expansion
  ap = a .* LPpar.ECWin;    %ECWin应该是进行一个带宽展宽；

end

return

%-----------------------------
function rxx = LP_acorr (x, Nt)

Nx = length(x);
N = Nt;
if (Nt > Nx)
  N = Nx;
end

rxx = zeros (Nt, 1);
for (i=0:N-1)
  Nv = Nx - i;
  rxx(i+1) = x(1:Nv)' * x(i+1:i+Nv);   %rxx(0) rxx(1) rxx(2)...相关矩阵算了出来
end

return

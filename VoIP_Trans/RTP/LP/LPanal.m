function ap = LPanal (x, LPpar)
% LP analysis for a frame of data
% The vector x is assumed to the same length as the window LPpar.Win.
% Returns the Np error filter coefficients [1; -p(1); ... -p(Np)] in a
% column vector, where Np is length(LPpar.LagWin) - 1.

% The LP analysis parameters can be set with SetLPpar.

% $Id: LPanal.m,v 1.5 2010/02/10 20:14:22 pkabal Exp $

Np = length(LPpar.LagWin) - 1;

% Window the data
xw = x .* LPpar.Win;    %���Ժ�����������

% Correlation calculation ����ĺ���Ӧ�þ���LD�㷨�ˣ�
Rxx = LP_acorr(xw, Np+1);   %�����Դ�������������������
E0 = Rxx(1); %��ʱ�����
if (E0 <= 0)
  if (E0 < 0)
    error('LPanal: Negative error');
  end
  ap = zeros(Np+1);
  ap(1) = 1;

else
  Rxxp = (Rxx + E0 * LPpar.Rnn) .* LPpar.LagWin;%�������ؾ���Rxxp

  % Levinson recursion
  a = levinson(Rxxp, Np);   %���õ�����������ϵ����
  a = a(:);

  % Bandwidth expansion
  ap = a .* LPpar.ECWin;    %ECWinӦ���ǽ���һ������չ��

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
  rxx(i+1) = x(1:Nv)' * x(i+1:i+Nv);   %rxx(0) rxx(1) rxx(2)...��ؾ������˳���
end

return

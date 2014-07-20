function y = MPContrib (N, Pulseval)
% Calculate the N sample multipulse contribution to the excitation.

% $Id: MPContrib.m,v 1.3 2009/07/12 21:20:01 pkabal Exp $

% Form a pulse train �γ�һ��弤ѵ��
y = zeros (N, 1);
y(Pulseval.m) = Pulseval.g; %�ڳ弤λ���ϸ�ֵ������������ֵ��[+-6.103e-05;]

% Shift and repeat if necessary ����Ϊ����� ���Բ���Ҫ����
L = Pulseval.ShiftLag;
y = RepShift (y, L);

return

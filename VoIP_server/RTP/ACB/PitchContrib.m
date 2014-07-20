function  ep = PitchContrib (N, L, b, eMem, Pitchpar)
% Find the pitch contribution to the excitation%���������ļ�Ȩϵ��

% $Id: PitchContrib.m,v 1.5 2004/08/06 23:17:34 kabal Exp $

POffs = Pitchpar.POffs;

% Get the pitch-repeated excitation, (N+NCof-1) x 1
eL = RepExc (eMem, N, L, POffs);%��������ȥ��չ��������������5��������λ��

Nc = length (POffs);
y = filter (b, 1, eL);%����ȡ�����ź�ͨ��b��
ep = y(Nc:end);      % Ignore the Nc-1 warm-up points����ǰ��4�鼤����ֻ���µ����鼤��

return

function SIDGain = CNGUpdate (eMem, CNGpar)
% Calculate the gain for future CNG frames (in case an SID frame is
% lost)����δ����������֡�����棨�Է�SID֡��ʧ��

% $Id: CNGUpdate.m,v 1.3 2006/09/27 18:14:36 pkabal Exp $

% Gain for CNG
N = CNGpar.NG;
E = eMem(end-N+1:end)' * eMem(end-N+1:end);%�������м���������
SIDGain = CNGpar.GScale * sqrt (E);%�����SID����GScale * sqrt (E)  0.0913
  
% Quantize / Decode SIDGain ����/����SID���棬���Ǳ�׼�������ֶ�
QI = QuantL (SIDGain, CNGpar.GainDec);
SIDGain = CNGpar.GainCBook (QI + 1); %���뱾�н������

return

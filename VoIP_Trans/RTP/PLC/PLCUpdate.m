function [uvGain, L] = PLCUpdate (L, eMem, Pulseval, PLCpar)
% Calulate an appropriate gain for unvoiced PLC excitation and a lag for
% voiced PLC excitation.

% $Id: PLCUpdate.m,v 1.4 2004/08/06 23:19:00 kabal Exp $

% Unvoiced gain from pulse amplitudes (interpolated from the last two
% subframes
uvGain = PLCpar.uvGainTable(Pulseval(end).gC+1, Pulseval(end-1).gC+1);%��÷������źţ��弤�����棬�����������֡��ֵ�õ����ӱ��еõ�

% Pitch lag for PLC mode, set to zero if none.%������Ƶ��ƫ�ƣ����NaN�����ԭ����
L = VuV_PLC (L(end-1), eMem, PLCpar);

return

% ------------
function L = VuV_PLC (L, e, PLCpar)
% Look at a block of samples in e (last N values). Search pitch lags
% around L to find the best correlation with past values. If the relative
% correlation exceeds a given value, return the lag that gives the
% highest correlation. Otherwise return the lag as zero.
% Input:  e, excitation signal, where the last N values represent the
%         current subframe.
% Output: L (lag), set to NaN for "unvoiced" frames.

LOffs = PLCpar.LOffs;
Lc = min (L, PLCpar.PMax - max (LOffs));
N = PLCpar.N;

% Start of block
iS1 = length (e) - N + 1;
iSN = iS1 + N - 1;

e0 = e(iS1:iSN);%��ȡ���120�����㣻
CLMax = 0;
L = NaN;
for (Lt = Lc+LOffs)
  CL = e0' * e(iS1-Lt:iSN-Lt);%�����뼤�������120�����㣬��������������΢������أ����˵��������ֵ���͵õ���
  if (CL > CLMax)
    CLMax = CL;
    L = Lt;
  end
end

if (~ isnan (L))

  % Zero lag energy  ��ʱ���������
  E0 = e0' * e0;

  % Lopt lag energy  ��ʱL�����������
  EL = e(iS1-L:iSN-L)' * e(iS1-L:iSN-L);

  % Test Prediction gain ����Ԥ������
  CThr = (PLCpar.PGMin - 1) / PLCpar.PGMin; 
  if (CThr * EL * E0 > CLMax^2) %����CThr * EL * E0 > CLMax^2��L NaN
    L = NaN;
  end

end

return
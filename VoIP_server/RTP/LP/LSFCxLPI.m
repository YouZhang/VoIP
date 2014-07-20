function [aQI, lsfQ] = LSFCxLPI (LSFC, lsfQP, LSFpar)
% Inverse quantize the LSF's, interpolate the quantized
% LSF's, convert to quantized LP parameters. If LSFC is
% empty, this is a packet loss frame.

% $Id: LSFCxLPI.m,v 1.2 2009/07/12 21:16:29 pkabal Exp $

% Inverse quantization of the LSFs
if (isempty (LSFC))%Ԥ����±겻�ǿ�ģʽ1��
  LSFMode = 2;    % PLC frame
  NSplit = length (LSFpar.VQ);
  LSFC = zeros (NSplit, 1);
else
  LSFMode = 1;
end
lsfQ = IQLSF (LSFC, lsfQP, LSFMode, LSFpar);%�����������˶�lsf�����ָ�������

% Interpolation of the LSF's and convert to LP���ò�ֵ�������ǰ3����֡��Pnϵ����Ȼ��ת��Ϊlpc����
aQI = LSFxLPI (lsfQ, lsfQP, LSFpar);%���lsp->ai

return

%--------------------
function lsfQ = IQLSF (LSFC, lsfQP, LSFMode, LSFpar)
% LSFC is a vector of codebook codes

% Calculate the prediction error
Pval = LSFpar.Pcof(LSFMode) * (lsfQP - LSFpar.Mean);

Nsplit = length (LSFpar.VQ);
i1 = 1;
for (k = 1:Nsplit)%lsp���룬���±���10ά��en
  i2 = i1 + size (LSFpar.VQ{k}, 1) - 1;
  DlsfQ(i1:i2,1) = LSFpar.VQ{k}(:,LSFC(k) + 1);%ȡ���±��Ӧ��(3,3,4)ά������
  i1 = i2 + 1;
end

% Fix closely spaced LSF's%%%��en�����ȶ��Լ�⣬��Ƶ�����ܳ���31.25hz������Ҫ��������
lsfQ = FixLSF (DlsfQ + Pval + LSFpar.Mean, LSFMode, LSFpar.Fix);%���ûָ���Pn�ź����ȶ��Լ��%DlsfQ + Pval + LSFpar.Mean�ָ�Pn�ź�
if (isempty (lsfQ))
  lsfQ = lsfQP;
end

return

%------------------------
function lsf = FixLSF (lsf, LSFMode, Fix)
% Fix closely spaced LSF's

Np = length (lsf);

lsf(1)  = max (lsf(1), Fix.Min);%�ı�lsp������ͷ��β
lsf(Np) = min (lsf(Np), Fix.Max);

dwMin = Fix.MinSep(LSFMode);
dwTest = Fix.SepCheck(LSFMode);

NFix = 0;
for (m = 1:Fix.NIter)%Fix.NIter����

  % Force a minimum separation
  for (j = 1:Np-1)
    dw = lsf(j+1) - lsf(j);%�������ε�Pn�Ĳ�ֵdw,ע�������Pn���Ƕ�Ӧ��cowW��ֵ�����ԣ�Ҫ��һ��ת��
    if (dw < dwMin) %��С��31.25HZʱ
      lsf(j)   = lsf(j)   - 0.5 * (dwMin - dw);%��lsf(j)��С����lsf(j+1)����
      lsf(j+1) = lsf(j+1) + 0.5 * (dwMin - dw);
      NFix = NFix + 1;
    end
  end

  % Test separation (dwTest is a bit smaller than dwMin)
  dw = diff (lsf);
  TooClose = any (dw < dwTest);%�ٴμ����û��С��dwtest��ֵ
  if (~ TooClose)
    break;	% No more fixes necessary
  end

end

if (NFix > 0)
  disp ('FixLSF - Fix for close LSFs');
end

if (TooClose)
  lsf = [];
  disp ('FixLSF - Fix not successful');
end

return

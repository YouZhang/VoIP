function LSFC = LPxLSFQ (a, lsfQP, LSFpar)
% Convert LP parameters to LSFs, quantize the LSFs.

% $Id: LPxLSFQ.m,v 1.3 2004/07/05 17:02:54 kabal Exp $

% Convert to LSFs
ap = a .* LSFpar.ECWin;%ECWin �����޶���;
lsf = poly2lsf (ap);	% lsf's are in radians%���lsp����10��

% Quantize the LSFs
LSFC = QLSF (lsf, lsfQP, LSFpar);%����lsp�����Ľ⣬��������������������ʸ����Ӧ���±�

return

%--------------------
function LSFC = QLSF (lsf, lsfQP, LSFpar)
% Quantize LSFs
% - Weighting inversely proportional to LSF spacings
% - Form the LSFs less the mean LSFs
% - Calculate the prediction error from the LSFs from the
%   previous frame

Np = length (lsf);

% Form the weight vector
% W(i) = 1 / min (lsf(i+1)-lsf(i),lsf(i)-lsf(i-1))
Slsf = diff (lsf);  %��Ӧ������������Ĳ�ֵ
W = 1 ./ min ([Slsf(1); Slsf], [Slsf; Slsf(end)]);%���ü�Ȩ�������г���ϵ��źŽ��м�ǿ��p���Ľ��ģ������У�1��1��������㣬����1/diff(1)

% Calculate the prediction errorһ������Ԥ��ϵ��0.375����ȥ��ֵ��12/32
Pval = LSFpar.Pcof * (lsfQP - LSFpar.Mean); %֮ǰ������������Լ�ȥֱ������һ��Ԥ������
Dlsf = (lsf - LSFpar.Mean) - Pval;  %Dlsf�в�

IQ = SVQLSF (Dlsf, W, LSFpar.VQ);%�������������������±꣬��Ӧ��
LSFC = IQ - 1;%�±��һ

return

%--------------------
function IQ = SVQLSF (Dlsf, W, YQ)%Ԥ�����ʸ������
% Returns a vector of codebook indices

Nsplit = length (YQ);

i1 = 1;
for (k = 1:Nsplit)%�������뱾�������Σ���Ϊ3,3,4���뱾Ŷ��
  i2 = i1 + size (YQ{k}, 1) - 1;
  IQ(k) = VQ (Dlsf(i1:i2), W(i1:i2), YQ{k});%�����������±�%0.������һ���ֵĲвҲ���ǰ�һ��10ά���������ֳ�3,3,4�����ֱ��������1.��ɼ�Ȩ�в�ļ���eWe.���뱾��Ѱ����֮��ֵ��С�������ĽǱ�
  i1 = i2 + 1;
end

return

%--------------------
function Index = VQ (x, W, YQ)  %x�Ǹ������Ĳв%�в��ǰ��ά����һ���뱾�ã��������ɵ�һ���±꣬����3,3,4�ķ�ʽ������
% Returns the codebook index minimizing the weighted error

% We want to minimize (where W is a diagonal matrix)
%   (x-y)'W (x-y) = x'Wx - 2 y'W x + y'W y   �����Ȩ�в���뱾�еĲв���
%                 = x'Wx + y'W (y - 2 x)=(W.*y)'*(y-2x)

Ny = size (YQ, 2);%�뱾�Ĵ�С
ErrMin = inf;%��ʼ���Ϊ���޴�
for (k = 1:Ny)
  Err = (W .* YQ(:,k))' * (YQ(:,k) - 2 * x);%�����Ȩ�в��������ļ򻯹�ʽ����һ�μ���Ϊ0��
  if (Err < ErrMin)%�����������С��֮ǰ�������С����ô�͸���ErrMin������˻���Ȼ������pn,pn',en,���ߵ������±�
    ErrMin = Err;%Ҳ��һ���ݹ���̣�
    Index = k;
  end
end

return
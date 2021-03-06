function LSFC = LPxLSFQ (a, lsfQP, LSFpar)
% Convert LP parameters to LSFs, quantize the LSFs.

% $Id: LPxLSFQ.m,v 1.3 2004/07/05 17:02:54 kabal Exp $

% Convert to LSFs
ap = a .* LSFpar.ECWin;%ECWin 噪声修订窗;
lsf = poly2lsf (ap);	% lsf's are in radians%算出lsp参数10个

% Quantize the LSFs
LSFC = QLSF (lsf, lsfQP, LSFpar);%量化lsp参数的解，并且完成量化，输出三个矢量对应的下标

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
Slsf = diff (lsf);  %反应相邻两个极点的差值
W = 1 ./ min ([Slsf(1); Slsf], [Slsf; Slsf(end)]);%利用加权误差矩阵对谐波上的信号进行加强（p靠的近的），其中（1，1）是特殊点，等于1/diff(1)

% Calculate the prediction error一阶线性预测系数0.375，减去均值；12/32
Pval = LSFpar.Pcof * (lsfQP - LSFpar.Mean); %之前解码的向量乘以减去直流乘以一个预测因子
Dlsf = (lsf - LSFpar.Mean) - Pval;  %Dlsf残差

IQ = SVQLSF (Dlsf, W, LSFpar.VQ);%输出就是量化后的三个下标，对应着
LSFC = IQ - 1;%下标减一

return

%--------------------
function IQ = SVQLSF (Dlsf, W, YQ)%预测分裂矢量量化
% Returns a vector of codebook indices

Nsplit = length (YQ);

i1 = 1;
for (k = 1:Nsplit)%对三个码本，做三次，因为3,3,4个码本哦，
  i2 = i1 + size (YQ{k}, 1) - 1;
  IQ(k) = VQ (Dlsf(i1:i2), W(i1:i2), YQ{k});%量化出三个下标%0.输入是一部分的残差（也就是把一个10维的向量，分成3,3,4），分别进行量化1.完成加权残差的计算eWe.从码本中寻找与之差值最小的向量的角标
  i1 = i2 + 1;
end

return

%--------------------
function Index = VQ (x, W, YQ)  %x是给进来的残差，%残差的前三维被第一个码本用，被量化成第一个下标，按照3,3,4的方式进来；
% Returns the codebook index minimizing the weighted error

% We want to minimize (where W is a diagonal matrix)
%   (x-y)'W (x-y) = x'Wx - 2 y'W x + y'W y   计算加权残差和码本中的残差差别
%                 = x'Wx + y'W (y - 2 x)=(W.*y)'*(y-2x)

Ny = size (YQ, 2);%码本的大小
ErrMin = inf;%初始差距为无限大
for (k = 1:Ny)
  Err = (W .* YQ(:,k))' * (YQ(:,k) - 2 * x);%计算加权残差，利用上面的简化公式，第一次计算为0；
  if (Err < ErrMin)%如果算出的误差小于之前算出的最小误差，那么就更新ErrMin，这个乘积自然表征了pn,pn',en,三者的最优下标
    ErrMin = Err;%也是一个递归过程；
    Index = k;
  end
end

return

function [xt, LOL, WSynCof, TVpar] = GenTarget (xc, a, TVpar)
% Generate the target vector using the weighted synthesis filter

% $Id: GenTarget.m,v 1.4 2009/07/12 21:21:41 pkabal Exp $

LSubframe = TVpar.LSubframe;
POLSubframe = TVpar.POLSubframe;

% Apply the formant weighting filter
[xr, TVpar.PWpar.Mem] = PWFilter (xc, LSubframe, a, TVpar.PWpar); %共振峰感知加权滤波

% Open loop pitch estimate (from perceptually weighted speech)%开环基音估计
[L, TVpar.PitchOLpar.xp] = PitchOL (xr, POLSubframe, TVpar.PitchOLpar);

% Calculate the harmonic noise weighting parameters 谐波噪声形成滤波器
LOL = [L(:) L(:)]';
LOL = LOL(:)';      % [L(1) L(1) L(2) L(2) ... ] %将基音估计值和感知加权过后的语音送入谐波噪声形成模块，对基音周围的码本序列进行滤波（梳状谱滤波）
[xt, GHNW, LHNW, TVpar.HNWpar.xp] = HNW (xr, LSubframe, LOL, TVpar.HNWpar);%返回值xt为经过谐波噪声滤波的样点，G为增益矩阵，L为精同步的基音周期，内存

% Set up the coefficients for the weighted synthesis filter
NSubframe = size (a, 2);
for (i = 1:NSubframe)
% WSynCof(i).aQ = ?  Not defined yet
  WSynCof(i).bW = a(:,i) .* TVpar.PWpar.ECWinN; %共振峰感知加权滤波器的分子
  WSynCof(i).aW = a(:,i) .* TVpar.PWpar.ECWinD; %共振峰感知加权滤波器的分母
  WSynCof(i).G = GHNW(i);   %四个子帧对应的增益值
  WSynCof(i).L = LHNW(i);   %基音精估计（4个子帧）
end

return

%--------------------
function [xr, FiltMem] = PWFilter (x, LSubframe, a, PWpar)
% This filtering is implemented as a pass through a pole/zero filter
% (with changing coefficients). The implementation mimics the Direct
% Form I structure in the reference code for G.723.1.

NSubframe = length (LSubframe);
LFrame = sum (LSubframe);
FiltMem = PWpar.Mem;

xr = zeros (LFrame, 1);     % Allocate buffer space
i1 = 1;
for (i = 1:NSubframe)
  i2 = i1 + LSubframe(i)-1;

  % Pole / zero filter%共振峰感知加权滤波器，目的是调整他的
  bW = a(:,i) .* PWpar.ECWinN;  %分子的调整值
  aW = a(:,i) .* PWpar.ECWinD;  %分母的调整值
  [xr(i1:i2), FiltMem] = PZFilter (bW, aW, x(i1:i2), FiltMem); %分别对每个子帧的数据进行共振峰感知加权滤波

  i1 = i2 + 1;
end

return

%--------------------
function [xnw, Go, Lo, xp] = HNW (x, LSubframe, L, HNWpar)
% Calculate harmonic noise weighting filter parameters
% Apply the harmonic noise weighting filter

% Form the extended vector
xe = [HNWpar.xp; x];

Nsubframe = length (LSubframe); %分4个子帧进行谐波噪声形成滤波
LMem = length (HNWpar.xp);
LFrame = sum (LSubframe);
xnw = zeros (LFrame, 1);     % Allocate memory

% Open-loop pitch estimates%进一步确定基音周期，相当于精同步；
j = LMem;
k = 0;
for (i = 1:Nsubframe)
  Nx = LSubframe(i);
  [Lo(i), G] = FindHNWCof (xe, j, Nx, L(i) + HNWpar.dL, HNWpar.PGMin);
  Go(i) = HNWpar.GF * G;     % Scale the coefficient

% Filter with the harmonic noise weighting filter (FIR
% filter)%将子帧数据乘以FIR滤波器，时移，算出4帧的谐波噪声形成器；
  xnw(k+1:k+Nx) = xe(j+1:j+Nx) - Go(i) * xe(j-Lo(i)+1:j-Lo(i)+Nx);
  j = j + Nx;
  k = k + Nx;
end

% Save the filter memory
xp = xe(end-LMem+1:end);

return

%--------------------
function [Lo, G] = FindHNWCof (x, LMem, NSum, P, PGMin)
% x:    Data vector, x(LMem+1) is the reference sample
% LMem: Memory length
% NSum: Number of terms in the correlation sum
% P:    Lags to be searched
% PThr: Threshold

ELo = 1;
CLo = 0;

% If no positive correlation is found, use a default value of lag
Lo = floor (min(P) + max(P)) / 2;
G = 0;

x0 = x(LMem+1:LMem+NSum);%取出第一个子帧
E0 = x0' * x0;%求子帧的能量；

for (L = P)%让L=38,39,40,41，42做这个增益值计算，进一步确定，只时候不做120个点的相关了，只做60个点的相关

  % Energy term, cross-correlation%交叉自相关值
  xL = x(LMem-L+1:LMem-L+NSum);
  EL = xL' * xL;
  CL = xL' * x0;

  % The error for a pitch predictor is 这里的这个推导和刚才的基音预测是一样的；
  %   e[n] = x[n] - G x[n-L]
  % The squared error for a frame is
  %   E2[L] = E[0] - 2G C[L] + G^2 E[L],
  % where E[L] = SUM x[n-L]^2 and C[L] = SUM x[n] x[n-L].
  % For a given L, the optimal coefficient G is
  %   Gopt = C[L] / E[L].
  % For this choice of G, the squared error is
  %   E2[L] = E[0] - C[L]^2 / E[L].
  % In the following code we find L which maximizes C[L]^2 / E[L]. This can
  % be done by searching over L. For each L, we compare the largest values
  % found so far (at Lo) with a value at L and choose the new value of L if
  %   C[L]^2   C[Lo]^2
  %   ------ > -------  or C[L]^2 E[Lo] > C[Lo]^2 E[L]
  %    E[L)]    E[Lo]
  % Only positive values of C[L] are candidates for a pitch lag. The
  % original test had E[L] > 0 & C[L] > 0. Clearly E[L] >= 0. Having,
  % C[L] > 0 implies that at least one of the terms used to calculate
  % E[L] is non-zero. Hence E[L] > 0.
  if (CL > 0)
    if (CL^2 * ELo > CLo^2 * EL)
      Lo = L;
      ELo = EL;
      CLo = CL;
    end
  end

end

% This test is taken from the C-code - it does not agree with the
% documentation in the standard
% The prediction gain with the optimum coefficient is
%   PG = E[0] / E2[L].
% We only use the filter if the prediction gain is larger than PGMin,
%          PG > PGMin
%        E[0] > PGMin E2[L]
%   E[0] E[L] > PGMin (E[0] E[L] - C[L]^2)
%      C[L]^2 > E[0] E[L] (PGMin-1)/PGMin
% PGMin = 1.6 gives CThr = 3/8 in the code below.
CThr = (PGMin - 1) / PGMin;%计算增益因子，某个门限CL/E - 1的值要大于 
if (CLo^2 > CThr * ELo * E0)
  if (CLo > ELo || ELo == 0)
    G = 1;
  else
    G = CLo / ELo;%算出增益beta
  end
end

return

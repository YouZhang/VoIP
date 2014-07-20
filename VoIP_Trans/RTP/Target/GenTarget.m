function [xt, LOL, WSynCof, TVpar] = GenTarget (xc, a, TVpar)
% Generate the target vector using the weighted synthesis filter

% $Id: GenTarget.m,v 1.4 2009/07/12 21:21:41 pkabal Exp $

LSubframe = TVpar.LSubframe;
POLSubframe = TVpar.POLSubframe;

% Apply the formant weighting filter
[xr, TVpar.PWpar.Mem] = PWFilter (xc, LSubframe, a, TVpar.PWpar); %������֪��Ȩ�˲�

% Open loop pitch estimate (from perceptually weighted speech)%������������
[L, TVpar.PitchOLpar.xp] = PitchOL (xr, POLSubframe, TVpar.PitchOLpar);

% Calculate the harmonic noise weighting parameters г�������γ��˲���
LOL = [L(:) L(:)]';
LOL = LOL(:)';      % [L(1) L(1) L(2) L(2) ... ] %����������ֵ�͸�֪��Ȩ�������������г�������γ�ģ�飬�Ի�����Χ���뱾���н����˲�����״���˲���
[xt, GHNW, LHNW, TVpar.HNWpar.xp] = HNW (xr, LSubframe, LOL, TVpar.HNWpar);%����ֵxtΪ����г�������˲������㣬GΪ�������LΪ��ͬ���Ļ������ڣ��ڴ�

% Set up the coefficients for the weighted synthesis filter
NSubframe = size (a, 2);
for (i = 1:NSubframe)
% WSynCof(i).aQ = ?  Not defined yet
  WSynCof(i).bW = a(:,i) .* TVpar.PWpar.ECWinN; %������֪��Ȩ�˲����ķ���
  WSynCof(i).aW = a(:,i) .* TVpar.PWpar.ECWinD; %������֪��Ȩ�˲����ķ�ĸ
  WSynCof(i).G = GHNW(i);   %�ĸ���֡��Ӧ������ֵ
  WSynCof(i).L = LHNW(i);   %���������ƣ�4����֡��
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

  % Pole / zero filter%������֪��Ȩ�˲�����Ŀ���ǵ�������
  bW = a(:,i) .* PWpar.ECWinN;  %���ӵĵ���ֵ
  aW = a(:,i) .* PWpar.ECWinD;  %��ĸ�ĵ���ֵ
  [xr(i1:i2), FiltMem] = PZFilter (bW, aW, x(i1:i2), FiltMem); %�ֱ��ÿ����֡�����ݽ��й�����֪��Ȩ�˲�

  i1 = i2 + 1;
end

return

%--------------------
function [xnw, Go, Lo, xp] = HNW (x, LSubframe, L, HNWpar)
% Calculate harmonic noise weighting filter parameters
% Apply the harmonic noise weighting filter

% Form the extended vector
xe = [HNWpar.xp; x];

Nsubframe = length (LSubframe); %��4����֡����г�������γ��˲�
LMem = length (HNWpar.xp);
LFrame = sum (LSubframe);
xnw = zeros (LFrame, 1);     % Allocate memory

% Open-loop pitch estimates%��һ��ȷ���������ڣ��൱�ھ�ͬ����
j = LMem;
k = 0;
for (i = 1:Nsubframe)
  Nx = LSubframe(i);
  [Lo(i), G] = FindHNWCof (xe, j, Nx, L(i) + HNWpar.dL, HNWpar.PGMin);
  Go(i) = HNWpar.GF * G;     % Scale the coefficient

% Filter with the harmonic noise weighting filter (FIR
% filter)%����֡���ݳ���FIR�˲�����ʱ�ƣ����4֡��г�������γ�����
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

x0 = x(LMem+1:LMem+NSum);%ȡ����һ����֡
E0 = x0' * x0;%����֡��������

for (L = P)%��L=38,39,40,41��42���������ֵ���㣬��һ��ȷ����ֻʱ����120���������ˣ�ֻ��60��������

  % Energy term, cross-correlation%���������ֵ
  xL = x(LMem-L+1:LMem-L+NSum);
  EL = xL' * xL;
  CL = xL' * x0;

  % The error for a pitch predictor is ���������Ƶ��͸ղŵĻ���Ԥ����һ���ģ�
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
CThr = (PGMin - 1) / PGMin;%�����������ӣ�ĳ������CL/E - 1��ֵҪ���� 
if (CLo^2 > CThr * ELo * E0)
  if (CLo > ELo || ELo == 0)
    G = 1;
  else
    G = CLo / ELo;%�������beta
  end
end

return

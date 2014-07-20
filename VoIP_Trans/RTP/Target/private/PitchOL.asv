function [L, xp] = PitchOL (x, LSubframe, PitchOLpar)%输入是之前经过感知加权后的语音信号
% Find the open loop pitch lag

% $Id: PitchOL.m,v 1.3 2009/07/12 21:21:52 pkabal Exp $

% Form the extended vector将142个空白头加入到240个数据前面，因为后面做相关的时候会有数据的溢出问题；
xe = [PitchOLpar.xp; x];

% Form open-loop estimates 每两个子帧做一次开环基音估计，算是粗同步的内容，大致找到基音的范围
NSubframe = length (LSubframe);
LMem = length (PitchOLpar.xp);

j = LMem;
for (i = 1:NSubframe)   %分别对两个子帧进行搜索
  Nx = LSubframe(i);
  L(i) = PitchEst (xe, j, Nx, PitchOLpar);  %输出的L0是样点周期的估计值41 138
  j = j + Nx;
end

% Memory for next frame
xp = xe(end-LMem+1:end);

return

%---------------------
function Lo = PitchEst (x, iref, N, PitchOLpar)%基音估计函数

PMin = PitchOLpar.PMin;
PMax = PitchOLpar.PMax;
PMultThr = PitchOLpar.PMultThr;%0.75的门限值，因为当估计出来的两个基音差别大于等于18，就要进行门限的判断

ELo = 1;
CLo = 0;
Lo = PMin;

L = PMin - 1;
i1 = iref - L;
i2 = i1 + N - 1;
EL = x(i1+1:i2+1)' * x(i1+1:i2+1);	% Energy for pitch lag PMin-1  分母，即语音信号的能量；

for (L = PMin:PMax) %从18-142一直做相关求平方，计算出135个相关值^2，分子
  i1 = i1 - 1;
  i2 = i2 - 1;

  % Recursive calculation of the energy term  递归计算能量，能量不需要每次都重新计算，即添头去尾；
  EL = EL + (x(i1+1)^2 - x(i2+2)^2);

  % Cross correlation term
  CL = x(i1+1:i2+1)' * x(iref+1:iref+N);    %计算交叉关联至C;

  % The error for a pitch predictor is
  %   e(n) = x(n) - p x(n-L)
  % The squared error for a frame is
  %   ES(L) = E(0) - 2p C(L) + p^2 E(L),
  % where E(L) = SUM x(n-L)^2 and C(L) = SUM x(n) x(n-L).
  % For a given L, the optimal coefficient p is p的最优解释一下这个表达式
  %   popt = C(L) / E(L). 将这个表达式代入到ES(L)的表达式中
  % For this choice of p, the squared error is
  %  ES(L) = E(0) - C(L)^2 / E(L).因此将C(L)^2 / E(L)比值作为交叉关联系数，越大则越好
  % In the following code we find L which maximizes C(L)^2 / E(L). For each
  % L, we compare the largest values found so far (at Lo) with a value at L
  % and choose the new value of L if
  %  C(L)^2   C(Lo)^2
  %  ------ > -------  or C(L)^2 E(Lo) > C(Lo)^2 E(L)
  %   E(L)     E(Lo)
  % The search is conducted from small values of L up. Only positive values
  % of C(L) are candidates for a pitch lag. If the better value of squared
  % error is within Pmin of the Lo, it is kept. If it further away, the new
  % value must be at least 1/A times better.
  %  A C(L)^2 E(Lo) > C(Lo)^2 E(L)
  % This second check is used to avoid locking onto pitch multiples.
  if (EL > 0 && CL > 0)         %初始时CLo=0;ELo=1;然后下次满足条件的就更新这些值
    %  ( [ ------------------------- && --------------- ] || ...
    if ( ( (CL^2 * ELo > EL * CLo^2) && ((L-Lo) < PMin) ) || ... %将除法的判断变成乘法的判断；
           (PMultThr * CL^2 * ELo > EL * CLo^2) )
    %      ------------------------------------ )
      Lo = L;   
      ELo = EL;
      CLo = CL;
    end
  end
end

return

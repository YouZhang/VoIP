function [ACBLC, ACBbIB, E] = GetACB (xt, eMem, h, PMode, L, SineDet, Pitchpar)
% This routine finds the best pitch contribution given past excitations.获得自适应码本
% E:  Error vector for pitch taming 基音偏差 
% xt: Target vector  输入进来取出了振铃的信号
% eMem:  Past excitation
% h:  Impulse response of the (weighted) synthesis filter 加权滤波器的冲击响应
% PMode: Pitch lag mode, absolute or relative coding 绝对编码还是相关编码
% L: Open loop pitch lag (PMode == 1) or previous pitch lag (PMode == 2)
% SineDet: Sine detector flag
% Pitchpar: Pitch predictor parameters

% $Id: GetACB.m,v 1.6 2009/07/12 21:04:49 pkabal Exp $

% PMode determines which mode we use: absolute or relative lag coding
LOffs = Pitchpar.LOffs{PMode};%首先就要做一个精确的基音预测
if (PMode == 1)
  LMin = Pitchpar.PMin(PMode) - min (LOffs);
  LMax = Pitchpar.PMax(PMode) - max (LOffs);
  L = max (min (L, LMax), LMin);   % L is only modified for PMode 1
end

% Pitch lags:
% The range of pitch lags is defined at several places. Define the
% names with all capitals
%   PMIN = 18;  PMAX = PMIN+128-1;
% The open loop pitch (determined earlier) is in the range [PMIN,PMAX-3].
% There are two modes in coding the pitch lag.
% Mode 1:
%   The pitch is determined relative to the open loop pitch value. The
%   relative lag values are [-1,0,1]. These lags are the lags corresponding
%   to reference coefficient in the vector of multitap pitch filter
%   coefficients. The filter has 5 coefficients, with the reference
%   coefficient being in the middle. Note however that this reference
%   coefficient is not necessarily the largest cofficient in the tables
%   used in G.723.1 (any one of the five coefficients can be the largest).
%
%   The following diagram shows the initial position of the filter for a
%   given lag offset applied for an open loop pitch lag of Li. The digits
%   indicate the filter coefficient numbers (zero-based) with the reference
%   coefficient being in the middle. The position shown gives the output
%   for the first pitch contribution to the current subframe. The filter
%   slides to the right, one sample at a time to give the subsequent values
%   for the subframe.
%                  -Li              0
%                   |   past data   | current data 
%     oooooooooooooo|ooooooooooooooo|ooooooooooooo
%                  43210  lag offset -1
%                 43210   lag offset  0
%                43210    lag offset  1
%   *** Some optimization could be done here. For example, run the coder
%       with a larger set of lag offsets. If values other than -1,0,1 get
%       chosen a lot, the larger search range may be worthwhile.
%
%       A second strategy would be to re-optimize the pitch gain values.
%       It would seem that coefficient vectors that have the largest
%       coefficient at either end are trying to catch the cases in which
%       the best lag is at an offset further than the range tested at the
%       coder. A change to the pitch coefficients would require changes at
%       both the transmitter and receiver.
%
%   The allowable pitch lags are 124 values from PMIN to PMAX-4. The last 4
%   pitch lags are "forbidden". The open loop lags are from PMIN to PMAX-3.
%   Adding the the offsets to these values gives potential lags in the
%   interval,
%     [PMIN+JMin1,PMAX-3+JMax1],
%   where JMin1 and JMax1 define the lag offset range for Mode 1 (JMin1 and
%   JMax1 are -1 and +1, respectively).
%
%   The open loop values are modified so that the final lag stays in the
%   range [PMIN,PMAX-4]. This is done by modifying the open loop pitch
%   with
%     Li' = min (max (Li, PMAX-4-JMax1), PMIN-JMin1)
%   Note that in this routine, the value PMax (mixed upper and lower case
%   name) has already been set to PMAX-4.
%
%   With the diagram in mind, we can determine the amount of memory (past
%   data) needed. The furthest to the left data sample accessed is
%     nMin = -Li - JMax1 -(NCof-1-IRefOffs) ,
%   where JMax1 the the largest lag offset for Mode 1, NCof is the number
%   of filter coefficients and IRefOffs the offset of the reference
%   coefficient. The number of past data values needed is
%     LMem = max(Li') + JMax1 + (NCof - IRefOffs) .
%   With the modification of Li as described above,
%     LMem = PMAX - 4 + (NCof - IRefOffs)
%          = PMAX - 2.
%
% Mode 2:
%   The pitch lag is coded relative to the pitch found in the previous
%   subframe. The offsets searched are [-1 0 1 2] (JMin2=-1 and JMax2=2)
%   and the best offset is coded with 2 bits. There is no initial
%   modification of the lag as in Mode 1. Thus the possible lags are in
%   the range [L+JMin2,L+JMax2]. Given the range of L enforced in Mode 1,
%   the lags returned are in the range [PMIN, PMAX-4], giving potential lag
%   values for Mode 2 from [PMIN+JMin2,PMAX-4+JMax2] or [PMIN-1,PMAX-2].
%   The amount of memory needed is
%     LMem = max(L) + JMax2 + (NCof - IRefOffs)
%          = PMAX - 4 + JMax2 + (NCof - IRefOffs)
%          = PMAX.

% Get the range of gain indices to search for each codebook
POffs = Pitchpar.POffs;

LFrame = length (xt);
LL = L + POffs(1) - (LFrame - 1);
LU = L + POffs(end);
NgVal = GetGainRange (LL, LU, SineDet, Pitchpar.Tamepar);
NCBook = length (NgVal);
for (i = 1:NCBook)
  b{i} = Pitchpar.b{i}(:,1:NgVal(i));
end

% Search over lags and gains to find the best pitch filter
% For PMode 2 (relative lag coding), we force the use of the appropriate
% codebook based on the lag from the previous subframe. We cannot let the
% lower level routine choose the codebook because of the required
% coordination between the shift and repeat operation of the multipulse
% coding which uses the lags from the absolute lag subframes. If the shift
% and repeat is used, we need one bit to signal this information. The space
% for the one bit comes from the use of codebook 1 (which is smaller),
% rather than codebook 2.
CBookThr = Pitchpar.CBookThr;
if (PMode == 2)
  if (L >= CBookThr)
    CBookThr = 0;    % Force the use of pitch gain codebook 2
  else
    CBookThr = inf;  % Force the use of pitch gain codebook 1
  end
end      %最优自适应码本获得，xt：第一个子帧，eMem激励码本，L+LOff,h冲击响应，
[ACBbIB, LOpt, dErr] = BestACBEntry (xt, eMem, L + LOffs, h, ...
                                     POffs, CBookThr, b);
%上面这个函数：1.获得了最佳的码本索引；2.获得了最接近的基音，3.误差的后两项
% Fix the choice of lag for zero valued past signals. This is important
% since a reduced range search may occur in the next frame. We want to
% set the lag to the middle of the search range for such a case. The zero
% reduction in error is achieved only if the past signal is zero (for any
% values of gain) or by zero gain values.
if (dErr <= 0)
  LOpt = L;
end

% Code the lag values
if (PMode == 1)
  ACBLC = LOpt - Pitchpar.PMin(PMode);
else
  ACBLC = LOpt - L - Pitchpar.LOffs{PMode}(1);
end

% Update the taming error vector 误差向量的能量
E = UpdatePitchTame (ACBbIB, LOpt, Pitchpar.Tamepar);

return

%-------------
function [bIB, LOpt, dErrMax] = BestACBEntry (xt, eMem, Li, h, POffs, CBookThr, b)
% Search over lags and gains to find the best pitch filter (lag and gains).
% xt: Target vector (N values)
% eMem: Past excitation (where the last sample corresponds to one sample
%     before the current frame)
% Li: Pitch lag values to be tested
% h:  Impulse response of the (weighted) synthesis filter (length N)
% POffs: Pitch filter coefficients lag offsets
% CBookThr: Lag threshold for using the second codebook. For subframes
%     using relative lag coding, this value is set to 0 (to force the
%     use of codebook 2) or to inf (to force the use of codebook 1).
% b:  Tables of pitch gains

dErrMax = -inf;
for (L = Li)

  % Calculate the correlations%1.计算相关值  % Rtx为估计的激励通过综合滤波器后的数值Spl和xt的相关值；2.Rxx为SPl的自相关值
  [Rtx, Rxx] = GetRtx (xt, eMem, L, h, POffs);%计算出真实值和估计值的互相关，自相关

  % Determine which codebook to use%根据基音决定用哪个码本
  iCBook = (L >= CBookThr) + 1;

  % Find the largest reduction in error and corresponding gain index%% %最佳的增益搜寻，使当前激励产生的spl信号与，真实相差最小
  [dErr, bI] = BestGain (Rtx, Rxx, b{iCBook});%通过最小均方误差求得最优增益码本检索号
  if (dErr > dErrMax)
    dErrMax = dErr;
    bIB = [bI; iCBook];%第一个是索引值，第二个是用哪个码本
    LOpt = L;
  end
end

return

%-------------
function [dErrMax, bI] = BestGain (Rtx, Rxx, b)
% Find the pitch gains which maximize the reduction in error.
%
% The pitch contribution (in vector notation) for a given set of pitch
% gains b is
%   p = spL b, where p is N x 1, spL is N x Nc, and  b is Nc x 1.
% The squared error is
%   E = (t - p)' (t - p), where t is the target vector (N x 1).
%   E = t't - 2 t' p + p'p
%     = t't - 2 t' spL b + b' spL' spL b
% When minimizing E with respect to the vector b, the first term is a
% constant and we need only minimize the sum of the remaining terms.
%将b作为一个变量，对b进行求导，可以解出最优的b，即满足以下关系式；
% For a given lag, the optimum b satisfies the matrix equation
%   spL' spL bo = spL' t.
% With this relationship the error becomes
%   E(bo) = t't - t' spL bopt .
% The optimal pitch predictor always reduces error relative to no
% prediction. Choosing b=0 gives no reduction in error. In the following
% we maximize the reduction in error.
%
% Precompute terms as follows问题被转换成了这样
%   E = t't - 2 Rtx b + b' Rxx b ,
% where Rtx = t' spL and Rxx = spL' spL.

Ng = size (b, 2);
dErrMax = -inf;
for (i = 1:Ng)
  dErr = 2 * Rtx * b(:,i) - b(:,i)' * Rxx * b(:,i);%这个值要越大越好
  if (dErr > dErrMax)
    dErrMax = dErr;
    bI = i; %bI表示best index 最佳增益索引
  end
end

return

% The error to be minimized with respect to the choice of b is as follows
%   E = t't - 2 Rtx b + b' Rxx b ,
% The first term does not depend on the choice of b. The second term is the
% dot product of two vectors of length Nc. The last term is a symmetric
% quadratic form. The computation of this term can be streamlined by taking
% into account the symmetry and by precomputing terms.
%
% The term b' Rxx b can be computed as
%        Nc-1 Nc-1
%   Exx = SUM  SUM B(i,j) Rxx(i,j) ,
%         i=0  j=0
% where B(i,j) = b(i) b(j). Using the symmetry of both B and Rxx, this can
% be written as
%        Nc-1                    Nc-1 i-1
%   Exx = SUM b(i,i) Rxx(i,i) + 2 SUM SUM b(i,j) Rxx(i,j)
%         i=0                     i=0 j=0
% The first term is the dot product of two vectors (Nc terms). The second
% term can also be reformulated as the dot product of two vectors
% ((Nc-1)Nc/2 terms).

% The approach taken in the reference code for G.723.1 is to form two
% vectors consisting of the concatenation of the following components,
% 1. Rxt(i)             -2 b(i)          0 <= i <= Nc-1
% 2. Rxx(i,i)           b(i) b(i)        0 <= i <= Nc-1
% 3. Rxx(i,j)           2 b(i) b(j)      0 <= i <= Nc-1; 0 <= j < i
% The dot products of these two vectors give the error to be minimized. The
% lengths of these vectors is Nc + Nc + (Nc-1)Nc/2 = 20 for Nc = 5.

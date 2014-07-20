function PulsevalOpt = MultiPulse (xt, h, L, MPMode, MPpar)
% Find the multipulse contribution.
% PulsevalOpt: Structure with pulse parameters
% xt:   Target vector (N values)
% h:    Filter impulse response (N values)
% L:    Pitch lag for possible pitch repetition
% MPMode: Mode (subframe index), determines the number of pulses

% $Id: MultiPulse.m,v 1.3 2009/07/12 21:20:19 pkabal Exp $
%GirdΪ���������ż�����磬ѡ����һ�������أ�Np����Ҫ���õ���������֮ǰ�Ĳ���������
Grid = MPpar.Grid{MPMode};
NGrid = length (Grid);
Np = MPpar.Np(MPMode); 
gIOffs = MPpar.gIOffs; %
g = MPpar.g;    %����

% For short pitch lags, the multipulse contribution is shifted and repeated
% by the pitch lag. This can be achieved in one of two ways:
% (1) Shift and repeat the pulse pattern
% (2) Shift and repeat the synthesis filter impulse response
% The second method is used while searching for pulses and assessing their
% contribution to the synthesized signal; the first method is used for
% calculating the excitation contribution when the pulses have been
% determined.���������Ƿ�С����֡��,�ٵ����弤��Ӧ�ٽ���һ������,Ȼ����δ�����弤��Ӧ������������бȽ�,ȡ���ӽ�����һ������λ��������
AddPitch = (L < MPpar.LThr); %�����趨��һ�����ޣ�����������С��58ʱ,Ҫ����һ�����������ڣ�����ֱ����h
Lk(1) = inf;       % L > N effectively turns off the pitch repetition
if (AddPitch)
  Lk(2) = L;       % Lk(2) is only used if AddPitch ����С��58��
end

N = length (xt);
Rhh = zeros (N, 1);    % Allocate space
Rth = zeros (N, 1);
  
% Find best set of pulses
ErrMin = inf;
for (k = 1:(AddPitch+1)) %�����ε�����λ�ú����棬1.L=inf,2.L = L,���������hһ�������ڵģ�һ���Ƿ����ڵ�

  % Add pitch repetition to the impulse response%���ڻ������ڲ���60������Ҫ��Ϊ�Ľ������Ӧ�ӵ�60
  hL = RepShift (h, Lk(k)); %����L�������ڽ�h�������ڻ���
  
  % Cross-correlation of target with impulse% response%����Ŀ������������Ӧ�Ľ�����غͳ弤��Ӧ�������
  % Impulse response autocorrelation function
  for (m = 1:N)
    Rhh(m) = hL(m:end)' * hL(1:N-m+1);
    Rth(m) = xt(m:end)' * hL(1:N-m+1);
  end

  for (i = 1:NGrid)%�ֱ������ε�������ѳ弤λ�ú����棬һ�����������磬һ����ż����  %�����ѵĳ��λ�ú����棬����������λ�ã�����������С�����ֱ𱣴�������ṹ����
    [Pulseval, Err] = GetBestMP (Rth, Rhh, xt, hL, Np, g, Grid{i}, gIOffs);
    if (Err < ErrMin)
      ErrMin = Err;
      PulsevalOpt = Pulseval;
      PulsevalOpt.ShiftLag = Lk(k);
      PulsevalOpt.GridI = i;%
    end

  end

end

return

%--------------------
function [PulsevalOpt, ErrMin] = GetBestMP (Rth, Rhh, xt, h, ...
                                            Np, g, Grid, gIOffs)
% Find the best pulse positions, gain and pulse signs. An initial guess
% is made at the quantized gain. The search over gain values is for gain
% values with indices around the initial guess.
% Rth:  Cross-correlation, target with impulse response
% Rhh:  Autocorrelation of the impulse response
% xt:   Target signal
% h:    Impulse response
% Np:   Number of pulses to be placed  ��Ҫ���õ�������
% g:    Vector of quantized gain values 
% Grid: Allowable pulse positions
% gIOffs: Gain index offsets. For a given initial gain index i, the
%       search is restricted to the range [i+GIOffs(1),i+GIOffs(2)].

% Initial guess for the quantized gain index
% The optimal gain for a pulse at location m is (see details later)
%   gopt = Rth(m)/Rhh(0).
% The largest decrease in error occurs by placing a pulse at the location
% m which has the largest value of Rth^2[m]/Rhh[0], or for a fixed Rhh[0],
% the largest value of |Rth[m]|. In the G.723.1 scheme, the search for the
% best lag M is on a restricted grid. The gain will be quantized by finding
% the nearest value in the table of quantized values, i.e. by minimizing
%   min_i |gQ[i] - |Rth[M]|/Rhh[0]| or min_i |gQ[i] Rhh[0] - |Rth[M]||.
% The second form avoids divide by zero when the signal is zero. This
% minimization gives the best quantized gain for a single pulse. We will
% use the same magnitude for all pulses. The pulse placement problem
% will then be solved for a number of different quantized gain values
% around the gain value found for the first pulse.

% There is an additional wrinkle in the G.723.1 code. In the search for
% the search for best gain index, the gain error is initialized to
% gX Rhh[0], where gX is near one. The question is whether intializing
% to that value instead of infinity, limits the gains that can be used.
% This is equivalent to asking whether
%   gErr = |gQ[i] - |gopt[M]|| <? gX Rhh[0].
% The quantized gain values take on values less than one. For |gopt[M]|
% less than gQ[i], the error is less than one. Rhh[0] is at least one,
% since it is the correlation for the impulse response h[n], which is
% constrained to have h[0]=1. When |gopt[M}| is larger than gQ[i], the
% largest gain will be chosen anyway. Conclusion: the initialization to
% the finite value has no effect on the possible choices of gain index.
RthMax = max (abs (Rth(Grid))); %����ֵG�ķ��ӵ�ֵ��gΪ�������������������24���ȼ���ÿ���ȼ�3.2db
[temp, gI] = min (abs (g * Rhh(1) - RthMax)); %gI�����������ţ�����24�����ܷ�ĸ�ˣ�ֻ�����ӵĲ��˭��С��

% Adjust the gain index search range %��������������Χ
[gIL, gIU] = AdjRange (gI + gIOffs(1), gI + gIOffs(2), 1, length (g));

N = length (Rth);
ErrMin = inf;

% Loop over quantized gain values%���ָ�������ĵ�����4�Σ�
for (i = gIL:gIU)

  % Get the pulses and gains ��ó��λ�ú�����
  Pulseval = FindPulses (Rth, Rhh, Np, g(i), Grid);

  % Form the pulse train and filter the result P�����洢��Щ����Լ�����
  P = zeros (N, 1);
  P(Pulseval.m) = Pulseval.g;
  xMP = filter (h, 1, P);%�����ͨ���ۺ��˲�����������Ƶ���������

  % Form the error signal%��Ŀ��������ȥ�������������֣����-�����
  e = xt - xMP;

  Err = e' * e; %�������
  if (Err < ErrMin) %���������С����һ�μ���������͸�����С���ֵ����������������ŵĳ弤���
    ErrMin = Err;
    PulsevalOpt = Pulseval;
    PulsevalOpt.gC = i - 1;%���������ڼ�������Ľ��
  end

end 

return

%--------------------
function [iL, iU] = AdjRange (iL, iU, iMin, iMax)
% Adjust the index range by shifting the range if necessary.

% Initial range is [iL,iU]. Shift this up to bring the lower limit to at
% least iMin, adjusting the upper limit of the shifted range to be at most
% iMax. Shift the original range down so the upper limit is at most iMax,
% adjusting the lower limit of the shifted range to be at least iMin. Take
% the union of the two shifted ranges.
% - Both shifts are zero if iL and iU are already in [iMin, iMax].
% - Both shifts being non-zero brings the range to [iMin, iMax].

ShiftU = max (0, iMin - iL);
ShiftD = max (0, iU - iMax);
iU = min (iMax, iU + ShiftU);
iL = max (iMin, iL - ShiftD);

return

%--------------------
function Pulseval = FindPulses (Rth, Rhh, Np, g, Grid)
% Rth:  Cross-correlation, target with impulse response
% Rhh:  Autocorrelation of the impulse response
% Np:   Number of pulses
% g:    Gain (amplitude)
% Grid: Vector of allowable pulse positions

% The pulse placement problem for a single pulse is to minimize the error
% energy for a frame. Assume a causal finite length filter response h[n],
% and a causal finite length target t[n]. The autocorrelation approach to
% minimizing the error energy is as follows,
%          inf                     2
%   E[M] = SUM (t[n] - g[M] h[n-M])
%          n=0
%          inf                 inf                      inf
%        = SUM t^2[n] - 2 g[M] SUM t[n] h[n-M] + g^2[M] SUM h^2[n-M]
%          n=0                 n=0                      n=0
%
%        = Et - 2 g[M] Rth[M] + g^2[M] Rhh[0],
%
% where for sequences of length N,
%           N-1               N-1
%  rth[m] = SUM t[n] h[n-m] = SUM t[n] h[n-m],
%           n=0               n=m
%           N-1               N-1
%  rhh[m] = SUM h[n] h[n-m] = SUM h[n] h[n-m] .
%           n=0               n=m
% This form penalizes pulses which cause the response to overlap into the
% next frame where the target is assumed to be zero.
%
% The minimization is over the choice of pulse position M. The gain g[M]
% could be optimized for each choice of M. For a fixed M, the optimum value
% of g[M] is obtained as
%   gopt[M] = Rth[M] / Rhh[0].
% With this value of gain, error energy is
%   Emin[M] = Et - Rth^2[M] / Rhh[0].
% If the gain is not the optimal value, there is an excess error,
%   E[M] = Emin[M] + Rhh[0] (g[M]-gopt[M])^2.
% This indicates that the quantized value of gain should be as close to
% gopt[M] as possible.
%
% The actual procedure used differs from this in that a single gain
% (specified as input) is used for all pulses, though the signs of the
% individual pulses can differ. The error is (from above)
%   E[M] = Et - 2 g[M] Rth[M] + g^2[M] Rhh[0].
% For a fixed absolute value of g[M], this is minimized by choosing the
% largest value of |Rth[M]| and assigning a sign to g[M] which is the same
% as that of Rth[M].
%
% The multiple pulse problem is handled in a sequential manner.
% First find the best single pulse. The position and gain of this pulse is
% then fixed and the second best pulse is found.
%
% The target vector, t[n], can be updated taking the contribution of a
% pulse that has been placed into account
%   t'[n] = t[n] - g[M] h[n-M].
% The cross-correlation can be directly updated,
%             inf
%   Rt'h[m] = SUM t'[n] h[n-m]
%             n=0
%             inf                    inf
%           = SUM t[n] h[n-m] - g[M] SUM h[n-m] h[n-M].
%             n=0                    n=0
%
% The sum in the last term can be written as
%   inf                 inf
%   SUM h[n-m] h[n-M] = SUM h[n] h[n-(m-M)] = Rhh[m-M].
%   n=0                 n=0
%
% Further more Rhh[-k] = Rhh[k], so use Rhh[m-M] = Rhh[|m-M|] to avoid
% having to store values of Rhh[.] for negative offsets.

N = length (Rth);
for (j = 1:Np)

  % Find the best position for a single pulse
  [RthMax, iMax] = max (abs (Rth(Grid))); %�൱���ҳ����ӵ�ֵ�ĸ����
  mMax = Grid(iMax);    %ѡ����Ӧ���ĸ�λ�õĳ����

  % Pick the sign of the pulse �������λ�õ�Rth��ȷ������������������Ϊ���涼һ���ˣ�
  if (Rth(mMax) >= 0)
    Pulseval.g(j) = g;
  else
    Pulseval.g(j) = -g;
  end

  % Set the position ����һ�£�������λ����Ϊ�����ã���ոþ���
  Pulseval.m(j) = mMax;      % Sample index
  Grid(iMax) = [];           % Make the position unavailable

  % Update the cross-correlation vector ���½������ֵ��Rth;
  Rth = Rth - Pulseval.g(j) * Rhh (abs (mMax-1 - (0:N-1))+1);

end

return

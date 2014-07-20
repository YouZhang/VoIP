function [Rtx, Rxx] = GetRtx (xt, e, L, h, POffs)
% Form the correlations, target with signal, and signal with signal for
% the lags corresponding to the pitch filter tap delays.
% Rtx: Nc correlations of the target vector and the filtered excitation
%    with delays corresponding to the pitch filter coefficients
% Rxx: Nc x Nc correlations of the filtered excitation with delays
%    corresponding to the pitch filter coefficients
% xt: Target vector (N values)
% e: Past excitation (where the last sample corresponds to one sample
%    before the current frame)
% L: Pitch lag
% h: Impulse response of the (weighted) synthesis filter (length N)
% POffs: Pitch filter coefficients lag offsets

% $Id: GetRtx.m,v 1.4 2009/07/12 21:04:08 pkabal Exp $

% Get the filtered excitation vectors 激励向量滤波器
spL = FiltExc (e, L, h, POffs); %1.在基音附近取出连续的5个激励源；2.将激励源通过综合滤波器算出估计值spl：

% Correlations: Target with signal, signal with signal
Rtx = xt' * spL;%计算出真实值和估计值的互相关
Rxx = spL' * spL;%自相关

return

%--------------------
function spL = FiltExc (e, L, h, POffs)
% This routine finds the filtered excitation needed for calculating the
% multi-tap pitch contribution.
% spL: filtered excitation, N x Nc
% e: Past excitation (where the last sample corresponds to one sample
%    before the current frame)
% L: Pitch lag
% h: Impulse response of the (weighted) synthesis filter (length N)
% POffs: Pitch filter coefficients lag offsets

% The pitch contribution uses a multi-tap pitch predictor. Let the frame
% length be N and the pitch lag be L. The pitch predictor contribution to
% the excitation for the current frame is
%             KU
%   epL[n] = SUM b[k] eL[n-L-k] u[n],
%            k=KL
% where the excitation eL[.] is formed from the previous excitation by
% pitch repetition if necessary,
%   eL[n] = e[n],          n < 0,
%           e[mod(n,L)-L], n >= 0.
% The pitch contribution to the reconstructed speech (zero state response),
%   p[n] = epL[n] u[n] * h[n],
% where the unit step u[n] is added to explicitly show that the
% contribution is zero for n < 0. Substituting for epL[n],
%           KU      N-1
%   p[n] = SUM b[k] SUM h[m] eL[n-m-L-k] u[n-m] ,
%          k=KL     m=0
%           KU
%        = SUM b[k] spL[n,L+k] ,
%          k=KL
% where h[n] is the impulse response of the (weighted) synthesis filter and
%              N-1
%   spL[n,q] = SUM h[m] eL[n-m-q] u[n-m]
%              m=0
%               n
%            = SUM h[m] eL[n-m-q] .
%              m=0

% Get the pitch-repeated excitation eL, (N+Nc-1) x Nc
% eLx[0,0]  corresponds to lag L+POffs(1)
%           eLx[:,0] is the signal to be multiplied by b[0]
% eLx[0,k]  corresponds to lag L+POffs(k+1)
%           eLx([,k] is the signal to be multiplied by b[k]
% eLx[0,Nc-1] corresponds to lag L+POffs(Nc)
%           eLx[:,Nc] is the signal to be multiplied by b[Nc-1]
% eLx[n,k] = eL[n+(Nc-1-k)]
% eLx(n,k) = eLx[n-1,k-1] = eL[n+(Nc-1-k)] = eL(n+(Nc-k))

N = length (h);%形成一个包围检索矩阵，在指定的几个位置形成
eL = RepExc (e, N, L, POffs);%从激励码本中在基音周期左右，取得连续的5组激励64个index值

Nc = length (POffs);
spL = zeros (N, Nc);    % Allocate memory
for (k = 1:Nc)
  m = POffs(end) - POffs(k);
  spL(:,k) = filter (h, 1, eL(m+1:m+N));%将激励源通过滤波器，算出估计值spl;
end

return

% The response can also be updated using the following relationship
%                  n+1
%   spL[n+1,q+1] = SUM h[k] epL[n-k-q]
%                  k=0
%                = spL[n,q] + h[n+1] eL[-q-1]
% or writing it another way
%   spL[n,q] = spL[n-1,q-1] + h[n] eL[-q].
%
% Recursive computation of the response (length N)
% spL(:,k) = [0; spL(1:N-1,k-1)] + h * eL(m+1:m+N);

function  ep = PitchContrib (N, L, b, eMem, Pitchpar)
% Find the pitch contribution to the excitation%搜索激励的加权系数

% $Id: PitchContrib.m,v 1.5 2004/08/06 23:17:34 kabal Exp $

POffs = Pitchpar.POffs;

% Get the pitch-repeated excitation, (N+NCof-1) x 1
eL = RepExc (eMem, N, L, POffs);%按照周期去拓展这个激励，获得了5个激励的位置

Nc = length (POffs);
y = filter (b, 1, eL);%将获取到的信号通过b，
ep = y(Nc:end);      % Ignore the Nc-1 warm-up points忽略前面4组激励，只留下第五组激励

return

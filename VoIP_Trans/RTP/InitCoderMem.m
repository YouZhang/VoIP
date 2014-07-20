function CoderMem = InitCoderMem (CoderPar)
% Initialize the decoder memory

% $Id: InitCoderMem.m,v 1.2 2004/08/06 23:19:15 kabal Exp $

% Excitation memory
Pitchpar = CoderPar.Pitchpar;
NPMode = max (Pitchpar.PMode);
LMem = 0;
for (i = 1:NPMode)
  if (i == 1)
    LMem = max (LMem, Pitchpar.PMax(i) + Pitchpar.POffs(end));
  else
    JMax = max (Pitchpar.LOffs{i});    
    LMem = max (LMem, Pitchpar.PMax(i) + JMax + Pitchpar.POffs(end));
  end
end
CoderMem.eMem = zeros (LMem, 1);

% LSF decoder initial value
CoderMem.lsfQ = CoderPar.LSFpar.Mean;%初始使用均值作为第一次的“上一帧lsf参数”

return
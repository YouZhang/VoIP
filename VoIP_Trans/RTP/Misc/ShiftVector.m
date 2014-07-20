function eMem = ShiftVector (eMem, e)
% Add samples to the end of a vector and truncate, keeping the rightmost
% samples.

% $Id: ShiftVector.m,v 1.2 2009/07/12 21:18:31 pkabal Exp $

LeMem = length (eMem);
ex = [eMem; e];  %eMem开了389的内存空间，将激励源存入
eMem = ex(end-LeMem+1:end);%取合并后的ex的最后389位；

return

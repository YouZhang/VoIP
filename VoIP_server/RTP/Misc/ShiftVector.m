function eMem = ShiftVector (eMem, e)
% Add samples to the end of a vector and truncate, keeping the rightmost
% samples.

% $Id: ShiftVector.m,v 1.2 2009/07/12 21:18:31 pkabal Exp $

LeMem = length (eMem);
ex = [eMem; e];  %eMem����389���ڴ�ռ䣬������Դ����
eMem = ex(end-LeMem+1:end);%ȡ�ϲ����ex�����389λ��

return

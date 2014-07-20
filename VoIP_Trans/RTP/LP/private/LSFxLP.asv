function a = LSFxLP (lsf, LSFpar)
% Convert LSF's to LP coefficients. Optionally modify the LSF values to
% account for the use of linear interpolation of a cosine table as used in
% the G.723.1 procedure.
%   lsf: Column vectors of LSF parameters

% $Id: LSFxLP.m,v 1.2 2009/07/12 21:16:12 pkabal Exp $

% In G.723.1, the conversion from LSFs to LP coefficients is carried out in
% the x = cos(w) domain. The conversion to the x-domain is done via linear
% interpolation into a cosine table. Here we modify the LSF's to take into
% account the error in the conversion to x values.
if (isfield (LSFpar.Fix, 'CosTable'))
  NCos = length (LSFpar.Fix.CosTable);%读取余弦数据的数据库，ai = -2coswi
  w = (0:(NCos-1)) * 2 * pi / NCos;     % w runs from 0 to 2*pi
  x = interp1 (w, LSFpar.Fix.CosTable, lsf, 'linear');
  lsf = acos (x); %？？？
end

% Convert to LP coefficients
N = size (lsf, 2);
for (i = 1:N)
  ai = lsf2poly (lsf(:,i));   % Inconsistent: aI is a row vector将Pn系数转换为Ai系数
  a(:,i) = ai(:);
end

return

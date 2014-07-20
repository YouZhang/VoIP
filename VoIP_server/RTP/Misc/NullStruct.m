function SN = NullStruct (S)
% Create a structure element with null fields with the same field names
% as an input structure

% $Id: NullStruct.m,v 1.1 2009/07/15 17:05:21 pkabal Exp $

SN = S(1:0);            % Empty sample element from the stucture
FN = fieldnames (SN);
% St(1).(FN{1}) = [];             % Only for Matlab 6.5 and later
eval (['SN(1).' FN{1} ' = [];']); % Create a null element

return

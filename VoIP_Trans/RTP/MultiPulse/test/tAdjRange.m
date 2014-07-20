function tAdjRange

iMin = 2;
iMax = 100;

% Test cases
xAdjRange (-2, 0, iMin, iMax);
xAdjRange (-2, 4, iMin, iMax);
xAdjRange (-2, 100, iMin, iMax);
xAdjRange (-2, 102, iMin, iMax);
xAdjRange (2, 2, iMin, iMax);
xAdjRange (2, 4, iMin, iMax);
xAdjRange (2, 100, iMin, iMax);
xAdjRange (2, 102, iMin, iMax);
xAdjRange (4, 6, iMin, iMax);
xAdjRange (4, 100, iMin, iMax);
xAdjRange (4, 102, iMin, iMax);
xAdjRange (100, 100, iMin, iMax);
xAdjRange (100, 102, iMin, iMax);
xAdjRange (-inf, 2, iMin, iMax);
xAdjRange (-2, inf, iMin, iMax);
xAdjRange (-inf, inf, iMin, iMax);

return

function xAdjRange (iL, iU, iMin, iMax)

[iLx, iUx] = AdjRange (iL, iU, iMin, iMax);
fprintf ('[%d %d] adjusted to [%d %d] => [%d %d]\n', iL, iU, iMin, iMax, iLx, iUx);


function [iL, iU] = AdjRange (iL, iU, iMin, iMax)
% Adjust the index range by shifting the range if necessary.

% Initial range is [iL,iU]. Shift this up to bring the lower
% limit to at least iMin, adjusting the upper limit of the
% shifted range to be at most iMax. Shift the original range down
% so the upper limit is at most iMax, adjusting the lower limit
% of the shifted range to be at least iMin. Take the union of
% the two shifted ranges.
% - Both shifts are zero if iL and iU are already in [iMin, iMax].
% - Both shifts being non-zero brings the range to [iMin, iMax].

ShiftU = max (0, iMin - iL);
ShiftD = max (0, iU - iMax);
iU = min (iMax, iU + ShiftU);
iL = max (iMin, iL - ShiftD);

return

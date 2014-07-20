function WSynMem = WSynInit (PMax)
% Initialize the synthesis filter memories
% - All-pole filter (synthesis filter)
% - Pole-zero filter (formant weighting filter)
% - Recursive pitch filter (harmonic noise weighting filter)

% $Id: WSynInit.m,v 1.2 2006/09/27 18:14:37 pkabal Exp $

WSynMem.APMem = [];
WSynMem.WFMem = [];
WSynMem.HNWMem.xp = zeros (PMax, 1);

return

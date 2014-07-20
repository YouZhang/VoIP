function [y, WSynMem] = WSyn (x, WSynCof, WSynMem)
% Filter with three stages of filtering
% - All-pole filter (synthesis filter)×ÛºÏÂË²¨Æ÷A£¨z£©
% - Pole-zero filter (formant weighting filter)¹²Õñ·å¸ÐÖª¼ÓÈ¨ÂË²¨Æ÷W(z)
% - Recursive pitch filter (harmonic noise weighting filter)Ð³²¨ÔëÉù³ÉÐÎÂË²¨Æ÷

% $Id: WSyn.m,v 1.1 2003/11/21 13:48:16 kabal Exp $

[yAP, WSynMem.APMem] = PZFilter (1, WSynCof.aQ, x, WSynMem.APMem);

[yWF, WSynMem.WFMem] = PZFilter (WSynCof.bW, WSynCof.aW, yAP, WSynMem.WFMem);

[y, WSynMem.HNWMem] = HNWFilter (yWF, WSynCof.G, WSynCof.L, WSynMem.HNWMem);

return

%--------------------
function [y, HNWMem] = HNWFilter (x, G, L, HNWMem)
% FIR filter, lag L, gain -G

LMem = length (HNWMem.xp);

% Form the extended input vector
xe = [HNWMem.xp; x];

% Filter with the harmonic noise weighting filter
Nx = length (x);
y = x - G * xe(LMem-L+1:LMem-L+Nx);

HNWMem.xp = xe(end-LMem+1:end);

return

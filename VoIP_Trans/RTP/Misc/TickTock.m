function TickTock (delta, PInt, Text)
% Print every PIncr units
% Initialize with TickTock(delta, PIncr, Text), then call it without an
% argument to increment the value by delta. When the accumulated value
% exceeds a multiple of PInt, the multiple of PInt value is printed.
% The first call to TickTock (after the setup call) will print a zero
% value.
%   delta: Value increment between calls
%   PInt:  Value interval between printouts
%   Text:  Text string, including formatting of the PInt value
%          (default '<%d>\n')

% $Id: TickTock.m,v 1.4 2009/07/12 21:18:59 pkabal Exp $

persistent accval vdelta VP VPInt VText

if (nargin > 0)
  vdelta = delta;
  accval = 0;
  voffs = 0;
  VP = 0;
  VPInt = PInt;
  if (nargin == 2)
    VText = '<%d>\n';
  else
    VText = Text;
  end
  return
end

if (accval >= VP);
  while (accval >= VP + VPInt)
    VP = VP + VPInt;
  end
  fprintf (VText, VP);
  VP = VP + VPInt;
end
accval = accval + vdelta;

return

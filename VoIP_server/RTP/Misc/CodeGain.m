function CGC = CodeGain (ACBbIB, Pulseval, Pitchpar)
% Combined codes for the adaptive codebook gains and the multipulse gains.

% $Id: CodeGain.m,v 1.4 2009/07/12 21:17:18 pkabal Exp $

GModV = Pitchpar.GModV;

NSubframe = length (Pulseval);
for (i = 1:NSubframe)

  % Code the gains for the pitch and the multipulse contributions
  ShiftC = (~ isinf (Pulseval(i).ShiftLag));
  CGC(i) = SubframeGainC (ACBbIB(:,i), Pulseval(i).gC, ShiftC, GModV);
  
end

return

%--------------------
function CGC = SubframeGainC (ACBbIB, gC, ShiftC, GModV)
% Form the combined gain code for the adaptive codebook gain and the
% multipulse gain.
% ACBbIB: Adaptive codebook gain (index, codebook). The index takes on
%         85 levels (codebook 1) or 170 levels (codebook 2)
% gC:     Multipulse amplitude code code (24 levels)
% ShiftC: Multipulse shift flag for shift and repeat operation. The use
%         of shift and repeat is only available if the pitch filter uses
%         codebook 1.

% The total number of combinations is 4080, which can be coded with 12 bits

ACBbC = ACBbIB(1) - 1;
CBookI = ACBbIB(2);
if (CBookI == 1)    % Choose 85 or 170 levels将这几个比特数打包成特殊的整形数，例如 1 1 1 0 1 0 -> 198
  CGC = CombineVals ([gC, ACBbC, ShiftC], GModV{CBookI});
else
  CGC = CombineVals ([gC, ACBbC], GModV{CBookI});
end

return

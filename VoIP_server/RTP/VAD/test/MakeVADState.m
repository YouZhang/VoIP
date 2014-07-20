function MakeVADState

for (VADFlagI = 0:1)
  for (Vcnt = 0:3)
    for (Hcnt = 0:6)
      StateI = Vcnt * 7 + Hcnt;
      NextState(VADFlagI+1, StateI+1) = nan;
      NextVADFlag(VADFlagI+1, StateI+1) = nan;
    end
  end
end

Vcnt = 0;
Hcnt = 0;
Nbit = 14;
for (i = 0:(2^Nbit-1))
  for (k = 0:(Nbit-1))
    VADFlagI = mod (floor (i / 2^k), 2);

    [VADFlagO, VcntO, HcntO] = UpdateCount (VADFlagI, Vcnt, Hcnt);
    [VADFlagI, Vcnt, Hcnt, VADFlagO, VcntO, HcntO]
        
    StateI = Vcnt * 7 + Hcnt;
    StateO = VcntO * 7 + HcntO;
    
    if (isnan (NextState(VADFlagI+1, StateI+1)))
      NextState(VADFlagI+1, StateI+1) = StateO;
    else
      if (NextState(VADFlagI+1, StateI+1) ~= StateO)
        error ('Mismatched states');
      end
    end
    if (isnan (NextVADFlag(VADFlagI+1, StateI+1)))
      NextVADFlag(VADFlagI+1, StateI+1) =VADFlagO;
    else
      if (NextVADFlag(VADFlagI+1, StateI+1) ~= VADFlagO)
        error ('Mismatched outputs');
      end
    end

    Vcnt = VcntO;
    Hcnt = HcntO;

  end
end

NextState
NextVADFlag

function [VADFlag, Vcnt, Hcnt] = UpdateCount (VADFlag, Vcnt, Hcnt)

% Update counters
if (VADFlag)
  Vcnt = Vcnt + 1;
  Hcnt = Hcnt + 1;
else
  Vcnt = Vcnt - 1;
  if (Vcnt < 0)
    Vcnt = 0;
  end
end

if (Vcnt >= 2)
  Hcnt = 6;
  if (Vcnt >= 3)
    Vcnt = 3;
  end
end

if (Hcnt)
  VADFlag = 1;
  if (Vcnt == 0)
    Hcnt = Hcnt - 1;
  end
end

return

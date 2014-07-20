function [Vadstate, VadStat] = VADOrig (Dpnt, SinDet, VadStat)
% Original VAD, close to floating-point C code

ScfTab = [9170 9170 9170 9170 10289 11544 12953 14533 16306 18296 20529];

PitchMax = 18 + 127;
SubFrLen = 60;
Frame = 240;
LpcOrder = 10;

Minp = PitchMax;
for (i = 0:3)
  if (Minp > VadStat.Polp(i+1))
    Minp = VadStat.Polp(i+1);
  end
end

Tm2 = 0;
for (i = 0:3)
  Tm1 = Minp;
  for (j = 0:7)
    if (abs (Tm1 - VadStat.Polp(i+1) <= 3))
      Tm2 = Tm2 + 1;
    end
    Tm1 = Tm1 + Minp;
  end
end

if (Tm2 == 4 || SinDet == 1)
  VadStat.Aen = VadStat.Aen + 2;
else
  VadStat.Aen = VadStat.Aen - 1;
end

if (VadStat.Aen > 6)
  VadStat.Aen = 6;
end
if (VadStat.Aen < 0)
  VadStat.Aen = 0;
end

Enr = 0;
for (i = SubFrLen:Frame-1)
  for (j = 0:LpcOrder-1)
    Acc0 = Acc0 - Dpnt(i-j-1+1) * VadStat.NLpc(j+1);
  end
  Enr = Enr + Acc0 * Acc0;
end

Enr = 0.5 * (Enr / 180);

if (VadStat.Nlev > VadStat.Penr)
  VadStat.Nlev = 0.25 * VadStat.Nlev + 0.75 * VadStat.Penr;
end

if (~VadStat.Aen)
  VadStat.Nlev = VadStat.Nlev * 33 / 32;
else
  VadStat.Nlev = VadStat.Nlev * 2047 / 2048;
end

VadStat.Penr = Enr;

if (VadStat.Nlev < 128)
  VadStat.Nlev = 128;
end
if (VadStat.Nlev > 131071);
  VadStat.Nlev = 131071;
end

[Frac, bexp] = log2 (VadStat.Nlev);
Temp = (floor (Frac * 128) / 64) - 1;
Temp = (1 - Temp) * ScfTab(18 - bexp + 1) + Temp * ScfTab (17 - bexp + 1);
Thresh = (Temp * VadStat.Nlev) / 4096;

if (Thresh > Enr)
  VadState = 0;
end

if (VadState)
  VadStat.Vcnt = VadStat.Vcnt + 1;
  VadStat.Hcnt = VadStat.Hcnt + 1;
else
  VadStat.Vcnt = VadStat.Vcnt - 1;
  if (VadStat.Vcnt < 0)
    VadSTat.Vcnt = 0;
  end
end

if (VadStat.Vcnt >= 2)
  VadStat.Hcnt = 6;
  if (VadStat.Vcnt >= 3)
    VadStat.Vcnt = 3;
  end
end

if (VadStat.Hcnt)
  VadState = 1;
  if (VadStat.Vcnt == 0)
    VadStat.Hcnt = VadStat.Hcnt - 1;
  end
end

VadStat.Polp(0+1) = VadStat.Polp (2+1);
VadStat.Polp(1+1) = VadStat.Polp (3+1);

return

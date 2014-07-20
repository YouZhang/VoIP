function PulseGconvert
% Convert pulse gain table to normalized values

g = load ('C-CodeData/PG24.dat');

g = g / 32768;
save ('PulseG24.dat', 'g', '-ASCII', '-DOUBLE');

Ng = length (g);
for (i = 0:Ng-1)
  for (j = 0:Ng-1)
    k = fix ((i + j) / 2);
    gg(i+1,j+1) = g(k+1);
  end
end

save ('PLCPG24x24.dat', 'gg', '-ASCII', '-DOUBLE');

return

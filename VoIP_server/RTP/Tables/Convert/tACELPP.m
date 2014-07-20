function tACELPP

% See if we can make any sense out of the ACELP pulse repetition tables.

b = load ('../ACBb170.dat');
Pg = load ('../ACELPPg170.dat');
POffs = load ('../ACELPPOffs170.dat');

Nb = size (b, 2);
Ndiff = 0;
Nninf = 0;
for (i = 1:Nb)
  [bmax, imax] = max (b(:,i));
  PO = 3 - POffs(i);
  if (~ isinf (PO))
    Nninf = Nninf + 1;

    E = sum (b(:,i).^2);
    COE = round (sum (b(:,i).^2 .* (1:5)') / E);
    fprintf ('%d: %d %d %d\n', i, PO, COE, imax);

    fprintf ('      %g %g\n', Pg(i), sqrt (E));
    if (COE ~= PO)
      b(:,i)'
      Ndiff = Ndiff + 1;
    end    

  end
end

[Ndiff, Nninf]

return

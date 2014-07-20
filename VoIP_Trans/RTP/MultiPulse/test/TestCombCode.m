function TestCombCode

NGrid = 30;
NpMax = 6;

% Make the combinatoric table
for (n = 0:NGrid)
  for (k = 0:NpMax)
    CTable(n+1,k+1) = nCk(n,k);
  end
end

% Specific example (from G.723.1)
NGrid2 = 2 * NGrid;
P2 = zeros (NGrid2, 1);
I = [59 27 19 51 35 3];
P2(I+1) = 1;
P = P2(2:2:end);
Np = sum (P);
C = MyPPCode (P, Np, CTable);
CC = 199484;

fprintf ('Codes: %d %d\n', C, CC);

% Generate random pulse positions
for (Np = [5, 6])
  Np
  NCode = CTable(NGrid+1,Np+1)
  for (C = 0:NCode-1)
    P = zeros (NGrid, 1);
    P = MyPPDecode (C, Np, NGrid, CTable);
    if (sum (P) ~= Np)
      fprintf ('Incorrect weight for Code: %d\n', C);
    end
    CA = MyPPCode (P, Np, CTable);
    if (C ~= CA)
      fprintf ('Codes differ: %d %d\n', C, CA);
    end
  end
end

return

function C = MyPPCode (P, Np, CTable)

NGrid = length (P);

m = Np;
C = CTable (NGrid+1, Np+1) - 1;
for (n = NGrid-1:-1:0)
  if (P(NGrid-1-n+1) ~= 0)
    C = C - CTable (n+1,m+1);
    m = m - 1;
    if (m == 0)
      break
    end
  end
end

return

function P = MyPPDecode (C, Np, NGrid, CTable)

m = Np;
P = zeros (NGrid, 1);
C = CTable (NGrid+1, Np+1) - 1 - C;
for (n = NGrid-1:-1:0)
  CT = CTable (n+1,m+1);
  if (C >= CT)
    C = C - CT;
    P(NGrid-1-n+1) = 1;
    m = m - 1;
    if (m == 0)
      break
    end
  end
end

return

function C = PPCode (P, Np, CTable)

NGrid = length (P);

j = Np;
C = 0;
for (i = NGrid-1:-1:0)
  if (P(NGrid-1-i+1) == 0)
    C = C + CTable (i+1,j);
  else
    j = j - 1;
    if (j == 0)
      break;
    end
  end
end

return

function P = PPDecode (C, Np, NGrid, CTable)

P = zeros (NGrid, 1);
j = Np;
for (i = NGrid-1:-1:0)
  C = C - CTable (i+1,j);
  if (C < 0)
    C = C + CTable (i+1,j);
    j = j - 1;
    P(NGrid-1-i+1) = 1;
    if (j == 0)
      break;
    end
  end
end

return

function m = nCk (n,k)
if (k <= n)
  m = nchoosek(n,k);
else
  m = 0;
end

return

% Random pulse positions
function P = RandPP (Np, N)

P = zeros (N,1);
P(1:Np) = 1;
I = randperm(N);
P = P(I);

return



    
    
function SumComb

N = 30;
Np = 5;

Sum = 0;
for (k = 1:Np)
  Sum = Sum + nchoosek (N-k,Np-k+1);
end

Sum
nchoosek(N,Np)-1

return

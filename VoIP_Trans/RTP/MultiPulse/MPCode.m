function [MPGridC, MPPosC, MPSignC] = MPCode (Pulseval, MPpar)
% Combined coding of the position codes for the subframes.
%
% The coding is done in two steps. To code the pulse positions, the first
% step gives a combinatoric code for each subframes. These subframe pulse
% position codes are then combined to give 5 values for each frame.

% $Id: MPCode.m,v 1.4 2009/07/12 21:19:49 pkabal Exp $

% Sign codes, grid code, and combinatoric coding for each subframe
NSubframe = length (Pulseval);
for (i = 1:NSubframe)%利用特别的打包技术，对符号和位置进行了不同的封装；
  [MPSignC(i), MPGridC(i), MPPC(i)] = MPBinomCode (i, Pulseval(i), MPpar);
end

% Combine the subframe codes into a group of frame codes
MPPosC = MPFrameCode (MPPC, MPpar);

return

%--------------------
function [MPSignC, MPGridC, MPPC] = MPBinomCode (MPMode, Pulseval, MPpar)
% Form the multipulse pulse sign codes, grid codes, and position codes.

MPGridC = Pulseval.GridI - 1;

% Pulse j is in position m(j) and has gain g(j).
% We need to get the positions in order and then code the signs of the
% gains in those positions.
Np = length (Pulseval.m);
[mS, I] = sort (Pulseval.m);

% A minus gives a 1 and a plus gives a 0
% The first pulse is in the most significant position将这几个比特数打包成特殊的整形数
Signs = (Pulseval.g(I) < 0);
MPSignC = CombineVals (Signs(Np:-1:1), 2);%对脉冲符号进行了这样的打包

% Mark the pulse positions on the grid
Grid = MPpar.Grid{MPMode}{Pulseval.GridI};%取出奇网络或者偶网络
Grid = sort (Grid);   % Sort the grid%按照从小到大排序
N = Grid(end);        % Number of positions needed 所有位置
P = zeros (N,1);
P(mS) = 1;      %将冲激位置都置1
GridP = P(Grid);      % Pulses on the sorted grid 将激励写在排序过的网格上

% Combinatoric coding这是一种数据打包算法，将6个脉冲位置打包成20bit 18bit根据奇偶子帧不同进行
MPPC = PPCode (GridP, Np, MPpar.nCk);

return

%--------------------
function MPPosC = MPFrameCode (MPPC, MPpar)

% The multipulse positions for each subframe are represented with a
% combinatoric code. For subframes 1 and 3, there are 6 pulses in 30
% positions. For subframes 2 and 4, there are 5 pulses in 30 positions.
% The total number of combinations of positions for the individual
% subframes is then 30 choose 6 or 30 choose 5.
%   N(1) = N(3) = C(30,6) = 593775,
%   N(2) = N(4) = C(30,5) = 142506.
% Coding the pulse positions for each subframe separately would require
% 20 + 18 + 20 + 18 = 76 bits. The number of combinations for all 4
% subframes is 2^72 < N(1) N(2) N(3) N(4) < 2^73. This can be coded with
% 73 bits, representing a saving of 3 bits with respect to separate
% coding. If we examine the possibility of coding pairs, the best we
% can do is 74 bits.
%
% The strategy used in G.723.1 is to express the code values for each
% subframe in modulo notation,
%   c(k) = p(k)M(k) + q(k),
% where q(k) = mod(c(k),M(k) and p(k) = floor(c(k)/M(k)). For k=1 and
% k=3, use M(k)=2^16, and for k=2 and k=4, use M(k)=2^14.
%
% Then for k=1 and k=3, q(k) can be coded with 16 bits and for k=2 and k=4,
% q(k) can be coded with 14 bits. For k=1 and k=3, p(k) takes on values
% in the interval [0,8], while for k=2 and k=4, p(k) takes on values in the
% interval [0,5]. The total number of the combinations of the 4 p(k)'s is
% 9 x 6 x 9 x 6 = 5184 which can be coded with 13 bits. This approach
% achieves the 73 bit total.
%
% The procedure in G.723.1 allocates 90 values (more than the minimum 72)
% to code p(1) and p(2), and the the remainder of the 13 bit code to code
% p(3) and p(4) (which can represent up to 91 values).
%
% The coding procedure is as follows.
% (1) Get q(k) for each subframe.
% (2) Get p(k) for each subframe.
% (3) Form a combined value as [p(4) + 9 p(3) + 90 p(2) + 810 p(1)]. This
%     is the first code word (13 bits)
% (4) The next 4 codewords are the q(k) (16, 14, 16, and 14 bits).

ModV = MPpar.ModV;

% Code the p(k)'s
p = floor (MPPC ./ ModV);
Cp = CombineVals (p(end:-1:1), MPpar.pLev);

% Code the q(k)'s
q = mod (MPPC, ModV);

MPPosC = [Cp q];

return

%--------------------
function C = PPCode (P, Np, nCk)%这是一种数据打包算法，将6个脉冲位置打包成20bit 18bit根据奇偶子帧不同进行
% Code positions using a combinatoric code (see below)

NGrid = length (P);

m = Np;
C = nCk(NGrid+1, Np+1) - 1;%31*7的一个码本,根据NGird和Np求和得出一个C=593774
for (n = NGrid-1:-1:0)
  if (P(NGrid-1-n+1) ~= 0) %减去对应位置为1的值,得到一个新的值
    C = C - nCk(n+1,m+1);
    m = m - 1;
    if (m == 0)
      break
    end
  end
end

return

% Combinatorial coding assigns a code. The procedure for doing this
% coding has been reinvented many times, possibly described first in the
% engineering literature by J. P. M. Schalkwijk, "An Algorithm for Source
% Coding", IEEE Trans. Inform. Theory, vol IT-18, pp. 395-399, May 1972.
% The procedure is described slightly differently here.
% Consider a trellis as shown below.
%              (N-3,K)  (N-5,K)
%  (N-1,K) o---o---o---o---o---o---o---o (1,2)
%           \   \   \   \   \   \   \   \
%            \   \   \   \   \   \   \   \
%             \   \   \   \   \   \   \   \
%    (N-2,K-1) o---o---o---o---o---o---o---o (0,1)
%               \   \   \   \   \   \   \   \
%                \   \   \   \   \   \   \
%                 \   \   \   \   \   \   \
%        (N-3,K-2) o---o---o---o---o---o---o (0,0)
%
% Consider the case of N positions and K pulses. The diagram is for the
% case of N=9 and K=2. The nodes are labelled with combinatorial terms
% indicating the position and how many pulses are still to be placed. We
% start at the upper left (position N-1 and K pulses) and end up at the
% lower right. Initialize the code to zero.
% (1) If a pulse appears in the first location, move diagonally down and
%     create a new subproblem with 1 fewer positions and 1 fewer pulses.
%     Add the value at the starting node to the code.
% (2) If no pulse appears in the first location, move horizontally and
%     create a new subproblem with 1 fewer position but the same number of
%     pulses. Leave the code unchanged.
% Some comments:
% (a) All possible pulse placements correspond to paths through the
%     trellis. Each diagonally downward movement indicates the position of
%     a pulse and the value of the code is sum of the nodes when moving
%     diagonally downward.
% (b) The labels on the nodes in the trellis decrease in value as we move
%     either horizontally or diagonally down to the right.
%       (n,k) > (n-1,k-1)  diagonal move [(n-1,k-1) = (n,k)-(n-1,k)]
%       (n,k) > (n-1,k)    horizontal move
%     Thus moving a pulse from one position to another changes the
%     resulting code - moving the pulse to the left increases the value of
%     the code and moving the pulse to the right decreases the code. In
%     fact the codes are in lexicographic order. If we interpret the pulse
%     positions as binary numbers, larger codes indicate a larger binary
%     number.
% (c) The largest code is obtained when the leftmost diagonals are
%     traversed,
%               K
%       Cmax = SUM (N-k,K-k+1) = (N,K) - 1.
%              k=1
% (d) The smallest code is obtained when the rightmost diagonals are
%     traversed.
%       Cmin = 0.
% (e) We need to argue that the codes are unique - each pulse configuration
%     has a different code. Pick a point on a path through the trellis
%     labelled (n-1,k). Now move diagonally down due the present of a
%     pulse. This moves us to the node labelled (n-2,k-1). The subproblem
%     generated at this point will generate codes in the interval
%     [0,(n-1,k)-1). But the amount added by diagonal transition if larger
%     than this by one. This inclusion guarantees that there is a unique
%     mapping from the sum of the values added by the diagonal transitions
%     to the locations of those transitions.
% (f) Since the codes are unique and the range of codes has been determined
%     to be in the interval [0,(N,K)-1], the codes are dense in that
%     interval.
%
% The combinatoric coding in G.723.1 is a variant of the method described
% above. The approach taken involves updating the code for every position.
% In the approach above, the code is updated only when a pulse is
% encountered. Since the number of pulses is less than the number of
% non-pulses, this is more efficient. Furthermore one has the freedom to
% choose the ordering in which to examine the pulse train.
%
% Using the algorithm above and looking from the latest pulse to the
% earliest pulse gives a code, call it C+ that is related to the G.723.1
% code (call it C-) by C- = (N,K)-1 - C+.

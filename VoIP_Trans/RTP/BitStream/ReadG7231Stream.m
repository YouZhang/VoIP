function QC = ReadG7231Stream (FName, Frames)
% Read a byte stream file generated by a ITU-T G.7231 coder,
% returning the code values for selected frames.

% $Id: ReadG7231Stream.m,v 1.5 2009/07/12 21:13:36 pkabal Exp $

if (nargin < 2)
  Frames = [1, Inf];
end

FID = fopen (FName);
if (FID == -1)
  ErrMsg = sprintf ('Cannot open bitstream file: %s', FullName (FName));
  error (ErrMsg);
end
fprintf ('G.723.1 Bitstream file: %s\n', FullName (FName));

IFr = 1;
k = 1;
while (IFr <= Frames(2))%写一个循环，按照字节，不停地读取数据中的字节

  v = fread (FID, 1, 'uchar');%无符号数读进来
  if (isempty (v))
    break;
  end
  BT(1) = v;%读取出第一个值

  % Check the bit rate bits to determine the frame size% (bytes)，检查bit率决定帧的大小
  v = bitand (BT(1), 3);%第一个值和3做与操作获取到工作哦模式
  switch (v)
    case 0    % High rate
      N = 24;
    case 1    % Low rate
      N = 20;
    case 2    % SID frame
      N = 4;
    otherwise % Untransmitted frame
      N = 1;
  end

  if (N > 1)%读取字节数据
    Data = fread (FID, N - 1, 'uint8');
    if (length (Data) ~= N - 1)
      error ('Invalid bitstream file');
    end
    BT(2:N) = Data;
  end

  if (IFr >= Frames(1))
    ByteStream{k} = BT(1:N);%每次给24个字节数据；
    k = k + 1;
  end
  
  IFr = IFr + 1;%index of frame
end

fclose (FID);

% Convert to codes
% 将码数据从字节中提取出来，高速率情况下，一帧读出96个cell，每个cell都是一帧24个byte的数据，192bit
QC = GetQCodes (ByteStream);%相当于逆向将原来这些参数全部都恢复回来；

return

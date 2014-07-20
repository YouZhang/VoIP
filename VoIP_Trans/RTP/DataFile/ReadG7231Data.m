function [VC, isBitStream] = ReadG7231Data (FName)
% Read data for the G.723.1 decoder
% Input data is either from a bitstream file or a Matlab file.

% $Id: ReadG7231Data.m,v 1.7 2009/07/15 17:03:47 pkabal Exp $

% Open the file for a peek at the first 6 characters
fid = fopen (FName, 'r');%读取所有的字节
if (fid == -1)
  error ('G7231Decoder: Cannot open input file');
end
id = char (fread (fid, 6, 'uint8')');%将数据读进来8bit也就是一个字节一个字节读，因为存储的时候也是一个字节一个字节的存的
fclose (fid);
%将id读取进来之后与已知的字符做比对判断是否是数据流
isBitStream = (~ strcmp (id, 'MATLAB'));

% Read the file读取bit流
if (isBitStream)%将参数全部从bit文件中恢复回来
  VC = ReadG7231Stream (FName);
else
  load (FName, '-mat');    % Loads VC
  fprintf ('G723.1 Matlab data file: %s\n', FullName (FName));
end

return

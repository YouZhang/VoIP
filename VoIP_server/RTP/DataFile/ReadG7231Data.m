function [VC, isBitStream] = ReadG7231Data (FName)
% Read data for the G.723.1 decoder
% Input data is either from a bitstream file or a Matlab file.

% $Id: ReadG7231Data.m,v 1.7 2009/07/15 17:03:47 pkabal Exp $

% Open the file for a peek at the first 6 characters
fid = fopen (FName, 'r');%��ȡ���е��ֽ�
if (fid == -1)
  error ('G7231Decoder: Cannot open input file');
end
id = char (fread (fid, 6, 'uint8')');%�����ݶ�����8bitҲ����һ���ֽ�һ���ֽڶ�����Ϊ�洢��ʱ��Ҳ��һ���ֽ�һ���ֽڵĴ��
fclose (fid);
%��id��ȡ����֮������֪���ַ����ȶ��ж��Ƿ���������
isBitStream = (~ strcmp (id, 'MATLAB'));

% Read the file��ȡbit��
if (isBitStream)%������ȫ����bit�ļ��лָ�����
  VC = ReadG7231Stream (FName);
else
  load (FName, '-mat');    % Loads VC
  fprintf ('G723.1 Matlab data file: %s\n', FullName (FName));
end

return

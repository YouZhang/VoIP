function ByteChar = WriteG7231Stream (FName, QC)
% Write a ITU-T G.7231 coder byte stream file, given
% code values frame by frame.
%��֮ǰ����õĸ�֡�Ĳ���ת����bit��
% $Id: WriteG7231Stream.m,v 1.3 2009/07/12 21:13:51 pkabal Exp $

% Convert the codes to a byte stream ת��Ϊ�ֽ���
ByteStream = SetQCodes (QC);

FID = fopen (FName, 'w');
fprintf ('G.723.1 Bitstream file: %s\n', FullName (FName))

NF = length (ByteStream);
for (k = 1:NF)
  fwrite (FID, ByteStream{k}, 'uint8');
end
ByteChar = [];
for i = 1:length(ByteStream)
    temp = num2str(ByteStream{i}');
    temp_len = length(temp);
    if(temp_len == 116)
        temp = ['  ',temp];
    elseif(temp_len == 117)
        temp = [' ',temp];
    end
    ByteChar= [ByteChar,temp];
end
fclose (FID);

return


function [QC,isBitStream] = Read_Data (ByteChar)

isBitStream = 1;
frame_byte_space = 118;
Time_space = length(ByteChar);
mat_char = reshape(ByteChar,frame_byte_space,Time_space/frame_byte_space)';
mat_num = str2num(mat_char);
% BitStrame = {};
for i = 1:size(mat_num,1)
    ByteStream{i} = mat_num(i,:);
end
% for i = 1:length(ByteStream)
%     temp = num2str(ByteStream{i}');
%     ByteChar= [ByteChar,temp];
% end
QC = GetQCodes (ByteStream);

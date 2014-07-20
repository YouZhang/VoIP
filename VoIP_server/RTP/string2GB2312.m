function GB_val = string2GB2312(data_input)
%将目标string变成GB2312编码值，由于中文字符有两位，所以要做对应的补齐，然后在收端也要做一个解码的程序；

[r,c] = size(data_input);
% count = 0;
% count_mat = [];
% for i = 1:r
%     for j = 1:c
%         chinese = isChinese(data_input(i,j));
%         if(chinese)
%             count = count + 1;
%         end
%     end
%     count_mat = [count_mat;count];
%     count = 0;
% end
% delta = max(count_mat);
GB_val = [];
GB_len_mat = [];
for i = 1:r
    GB = unicode2native(data_input(i,:),'GB2312');
    GB_len = length(GB);
    GB_len_mat = [GB_len_mat,GB_len];
end
len_max = max(GB_len_mat);
for i = 1:r 
    GB = unicode2native(data_input(i,:),'GB2312');
    delta = len_max-length(GB);
    GB_temp = padarray(GB,[0,delta],32,'post');
    GB_val = [GB_val;GB_temp];
end



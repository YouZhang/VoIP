function char_cell = GB2string(text_msg)
%%
%中文解码，逐个进行解码判断，大于160的值被认为是中文，与下一个byte结合在一起，进行解码；
% text_temp = str2double(text_msg);
% text_temp = uint(text_msg);

% [row,col] = size(text_temp);
[msg_r,msg_col] = size(text_msg);
step = 5;
j = 1;
char = [];
% char_cell = {};
char_cell = ' ';
c = msg_col/5;

% c = msg_col/step
for i = 1: msg_r
    while(j <= c)
        val = str2double(text_msg(i,5*j-4:5*j));
        if(val >= 160)
            j = j +1;
            if(5*j > msg_col)
                chinese_val = [val,str2double(text_msg(i,5*j-4:end))];
                chinese = native2unicode(chinese_val,'GB2312'); 
                char = [char,chinese];
                j = j + 1;
            else
                chinese_val = [val,str2double(text_msg(i,5*j-4:5*j))];
                chinese = native2unicode(chinese_val,'GB2312'); 
                char = [char,chinese];
                j = j + 1;
            end
        else
            english = native2unicode(val,'GB2312');
            char = [char,english];
            j = j + 1;
        end
        
    end  
    char_cell = connect_text(char_cell,char);
%     char_cell{i} = char;
    char = [];
    j = 1;
end
% connect_text(char)
% for i = 1:msg_r
%     j = 1;
%     while(j <= msg_col)
%         if(text_temp(i,j) >= 160)
%             chinese_val = text_temp(i,j:j+1);
%             chinese = native2unicode(chinese_val,'GB2312'); 
%             
%             j = j + 2;
%         else
%             english = native2unicode(text_temp(i,j),'GB2312');
%             j = j + 1;
%         end
%     end
%     for j = 1:msg_col 
%         if(text_temp(i,j) > 160)
%             chinese_val = text_temp(i,j:j+1);
%             chinese = native2uniocde(chinese_val,'GB2312');
%         else
%             english = naive2unicode(text_temp(i,j),'GB2312');
%             char = [char,english];
%         end
%     end  
% end

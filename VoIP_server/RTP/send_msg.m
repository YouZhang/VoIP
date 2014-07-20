function send_msg(text_msg)
%每8024个bytes分为一组，将每组都存到一个矩阵中去，然后分别发送，确认对方收到再发下一个
[h,l] = size(text_msg);
if(h == 1) 
    Byte_len = length(text_msg)
    % block_mat = [];
    block_len = 8024;
    times = Byte_len / block_len
    i = 1;
    times_char = num2str(floor(times+1));
    % ByteChar = [times_char,'  ',ByteChar]
    server(times_char, 3000,50);
    if(times > 1.0)
        while(i <= times)
            startp = block_len*(i-1)+1;
            endp = block_len*i;
            block_temp = text_msg(startp:endp);
            get = server(block_temp, 3000,50);
            if(get == 1)
                i = i + 1;      %当发送成功则发下一组数据，否则继续发当前数据
            end
        end
        get = server(text_msg(endp+1:Byte_len), 3000,50);
    else 
        get = server(text_msg, 3000,50);
    end
else
    times_char = num2str(h);
    server(times_char, 3000,50);
    for j = 1:h
        get = server(text_msg(j,:),3000,50);
    end
end


function sendto(ByteChar)
%ÿ8024��bytes��Ϊһ�飬��ÿ�鶼�浽һ��������ȥ��Ȼ��ֱ��ͣ�ȷ�϶Է��յ��ٷ���һ��
Byte_len = length(ByteChar)
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
        block_temp = ByteChar(startp:endp);
        [get,client_ip] = server(block_temp, 3000,50);
        if(get == 1)
            i = i + 1;      %�����ͳɹ�����һ�����ݣ������������ǰ����
        end
    end
    server(ByteChar(endp+1:Byte_len), 3000,50);
else 
    server(ByteChar, 3000,50);
end

% if(Byte_len > block_len )
%     startp = block_len*i+1;
%     endp = block_len*i+block_len;
%     block_temp = ByteChar(startp:endp);
%     server(block_temp, 3000,50);
%     i = i +1;
%     if()
% end
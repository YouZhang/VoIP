%%���������ߵ���ϵ�˵���Ϣ�����ڷ������У�ÿ�ε������󣬶����������������Ϣ����ȡ��ϵ�����ݷ�����һֱ���ⷢ�ͣ�
%%ͬʱ�ͻ����˳�ʱ�������������ȷ����Ϣ��ȷ���Ѿ��˳���Ȼ����������������û������ݿ⣬�������ⷢ��
%%��Ȼ���ͻ���ÿ��һ��ʱ����Զ������ϵ����Ϣ�ı��;��֤ͨ�ŵ��ȶ����У�
%����ظ���IP
clear
clc;
output_port = 8989;
contacts_info = 'choose friend';
while(1)
    r = size(contacts_info,1);
    times = num2str(r);
    [get,client_ip] = server(times, output_port, 1000);
    for i = 1:r        
        [get,client_ip] = server(contacts_info(i,:), output_port, 1000);
    end
    [r,c] = size(contacts_info);
    temp = reshape(contacts_info',1,r*c);
    pos = regexp(temp,client_ip,'start');
    if(isempty(pos))
        contacts_info = connect_text(contacts_info,client_ip);
    else
        temp(pos:pos + c-1) = '';
        contacts_info = reshape(temp',c,r-1)';
    end
    pause(0.5);
end
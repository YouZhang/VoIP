%%将所有在线的联系人的信息都存在服务器中，每次点击登入后，都会向服务器接收信息，获取联系人数据服务器一直向外发送；
%%同时客户端退出时会向服务器发送确认信息，确认已经退出，然后服务器更新在线用户的数据库，继续向外发送
%%当然，客户端每隔一段时间会自动检查联系人信息的变更;保证通信的稳定进行；
output_port = 8989;
contacts_info = [];
while(1)
    [get,client_ip] = server(contacts_info, output_port, 50);
    contacts_info = connect_text(contacts_info,client_ip);
end

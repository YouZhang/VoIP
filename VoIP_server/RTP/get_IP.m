function IP = get_IP()
[status,result] = dos('ipconfig');
pos = regexp(result,'IPv4','start');
IP = result(pos+34:pos+48);

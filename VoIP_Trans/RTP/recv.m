function recv(handles,client_ip,ring_data,FS)
pause(1);
% time_past = fix(clock);
data_2 = [];
% client_ip = get(handles.edit4,'String');
data = '';
times_char = client(client_ip, 3000,200);
times = str2double(times_char);
i = 1;

while(i <=times)

    data_temp = client(client_ip, 3000,200);
    data_len = length(data_temp);
    if(data_len>1000)
        data = [data,data_temp];
    else
        data_2 = [data_2;data_temp];
    end
    i = i +1;
end
len = length(data);
if(len>7080)
    
    [sound,fs] = G7231Decoder(data,'out_1.bit','a_x.wav');
    wavplay(ring_data,FS);
    play_show(sound,fs,handles);
    pause(2);
%     pushbutton10_Callback(hObject, eventdata, handles);
%     recv(handles,client_ip,ring_data,FS);
else
    text_before = get(handles.edit3,'String');
    char = GB2string(data_2);
    content_show = connect_text(text_before,char);
    set(handles.edit3,'String',content_show);
    wavplay(ring_data,FS);
%     time_now = fix(clock); 
%     delta_time = time_now(5) - time_past(5);
end
recv(handles,client_ip,ring_data,FS);
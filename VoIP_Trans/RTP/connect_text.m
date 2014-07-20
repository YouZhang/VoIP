function content = connect_text(text_before,msg_disp)

[r_msg,c_msg]= size(msg_disp);
[r_text,c_text] = size(text_before);
if(~r_msg)
   content =  text_before;
elseif(~r_text)
    content = msg_disp;
else
    delta = abs(c_msg-c_text);
    if(delta == 0)
        content = [text_before;msg_disp];
    else
        if(c_msg > c_text) 
            %²¹³ätext;
        %     pad_temp = padarray(text_before,[0,delta],'','post');
            for i = 1:r_text
                for j = 1:delta
                    temp_mat(i,j) = ' ';
                end
            end
            pad_temp = [text_before,temp_mat];
            content = [pad_temp;msg_disp];
        else
            %²¹³ämsg;
        %     pad_temp = padarray(msg_disp,[0,delta],'','post');
            for i = 1:r_msg
                for j = 1:delta
                    temp_mat(i,j) = ' ';
                end
            end
            pad_temp = [msg_disp,temp_mat];
            content = [text_before;pad_temp];
        end
    end
end
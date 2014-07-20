function play_show(y,Fs,handles)
    y_len = length(y);
    t=y_len/Fs;                       %�����źŵ�ʱ�䳤��
    ad= analogoutput('winsound');
    addchannel(ad,[1 2]);
    set(ad,'SampleRate',Fs);               %���ò�����
    if(size(y,2)>1)                       %˫�������ţ�������������ʹ��˫��������
        data1=y(:,1);
        data2=y(:,2);
    else
        data1=y;
        data2=y;
    end
    putdata(ad,[data1 data2]);              %��������������
    % handles.ad=ad; 
    % guidata(hObject,handles) 
    start(ad);                            %���������豸����ȡϵͳʱ��
    T=clock;
    pause(0.1);                          %������ͣ��0.1�� �����һ��ѭ������
    while isrunning(ad)
          time=clock-T;                  %��ȡ�Ѳ��ŵ�ʱ�䲢�������
          s=3600*time(4)+60*time(5)+time(6);
    %       set(handles.slider_timeplan,'value',s/t);%���Ž�������ֵ
    %       set(handles.text_timeleft,'string',round(t-s));%ʣ�ಥ��ʱ������
          if(round(s*Fs+4410)<length(data1))  %��ֹ��󼸴�ѭ���������
              yp=data1(round(s*Fs):round(s*Fs+4410)); %�˼���λ��ͬ�����ݷ�Χ��
    %           plot(handles.axes_rs,yp);         %��Ȼ4410Ϊ���趨�ĳ��ȣ������޸�
%               figure(1);
    %           axis([0 50000 -1 1]);
%               handles.axes3;
%               plot(yp);
%               set(handles.axes3,'YLim',[-1 1],'xlim',[0 4410]);
%               f=linspace(0,Fs/2,2205);
%               yfft = 2*abs( (1/4410)*fft(yp));    %��Ƶ��
% %               figure(2);
%               handles.axes2;
%               bar(f,yfft(1:2205));
%               set(handles.axes2,'xlim',[0 4200]);
              plot_sound(handles,yp)
              plot_freq(handles,Fs,yp);
              drawnow;                     %��������ܹؼ���ˢ������
          end
    end

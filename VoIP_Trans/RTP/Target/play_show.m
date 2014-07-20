function play_show(y,Fs,handles)
    y_len = length(y);
    t=y_len/Fs;                       %声音信号的时间长度
    ad= analogoutput('winsound');
    addchannel(ad,[1 2]);
    set(ad,'SampleRate',Fs);               %设置采样率
    if(size(y,2)>1)                       %双声道播放，单声道数据亦使用双声道播放
        data1=y(:,1);
        data2=y(:,2);
    else
        data1=y;
        data2=y;
    end
    putdata(ad,[data1 data2]);              %往声卡导入数据
    % handles.ad=ad; 
    % guidata(hObject,handles) 
    start(ad);                            %启动声卡设备并获取系统时间
    T=clock;
    pause(0.1);                          %这里暂停了0.1秒 以免第一次循环出错
    while isrunning(ad)
          time=clock-T;                  %获取已播放的时间并换算成秒
          s=3600*time(4)+60*time(5)+time(6);
    %       set(handles.slider_timeplan,'value',s/t);%播放进度条设值
    %       set(handles.text_timeleft,'string',round(t-s));%剩余播放时间设置
          if(round(s*Fs+4410)<length(data1))  %防止最后几次循环数据溢出
              yp=data1(round(s*Fs):round(s*Fs+4410)); %此即定位的同步数据范围，
    %           plot(handles.axes_rs,yp);         %当然4410为我设定的长度，可以修改
%               figure(1);
    %           axis([0 50000 -1 1]);
%               handles.axes3;
%               plot(yp);
%               set(handles.axes3,'YLim',[-1 1],'xlim',[0 4410]);
%               f=linspace(0,Fs/2,2205);
%               yfft = 2*abs( (1/4410)*fft(yp));    %做频谱
% %               figure(2);
%               handles.axes2;
%               bar(f,yfft(1:2205));
%               set(handles.axes2,'xlim',[0 4200]);
              plot_sound(handles,yp)
              plot_freq(handles,Fs,yp);
              drawnow;                     %这个函数很关键，刷新作用
          end
    end

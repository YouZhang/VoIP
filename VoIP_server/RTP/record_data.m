function data_all = record_data(handles,LastTime)
% clc,clear;
% handles = guihandles(gcf);
isRealTime=1; % 是否同步显示
Ai=analoginput('winsound'); % 创建一个模拟信号输入对象
% 添加通道
addchannel(Ai,1:1);
% LastTime=4; % 采样时间
Ai.SampleRate=8000; % 采样频率
Fs = Ai.SampleRate;
Ai.SamplesPerTrigger=Ai.SampleRate*LastTime; % 采样数
start(Ai); % 开启采样

if ~isRealTime % 判断是否同步
% 不同步
    wait(Ai,LastTime+1); % 需要等待录制完
    data=getdata(Ai); % 获取对象中的音频数据
    plot(data); % 绘图了
else
% 同步
    warning off % 当采样数据不够时，取消警告
%     T=clock;
%     pause(0.1);                          %这里暂停了0.1秒 以免第一次循环出错
%     while isrunning(Ai)
%           time=clock-T;                  %获取已播放的时间并换算成秒
%           s=3600*time(4)+60*time(5)+time(6);
%           set(handles.slider_timeplan,'value',s/t);%播放进度条设值
%           set(handles.text_timeleft,'string',round(t-s));%剩余播放时间设置
%           if(round(s*Fs+4410)<Ai.SamplesPerTrigger)  %防止最后几次循环数据溢出
%               data=peekdata(Ai,LastTime*Ai.SampleRate);
%               plot(handles.axes_rs,yp);         %当然4410为我设定的长度，可以修改
%               figure(1);
%               axis([0 50000 -1 1]);
%               handles.axes3;
%               plot(data);
%               set(handles.axes3,'YLim',[-1 1],'xlim',[0 4410]);
%               f=linspace(0,Fs/2,2205);
%               yfft = 2*abs( (1/4410)*fft(data));    %做频谱
% %               figure(2);
%               handles.axes2;
%               bar(yfft);
%               set(handles.axes2,'xlim',[0 4200]);
%               plot_sound(handles,yp)
%               plot_freq(handles,Fs,yp);
%               drawnow;                     %这个函数很关键，刷新作用
%           end
%     end
%     warning on
% end
%%
%原来的显示
    pause(0.4); 
    while isrunning(Ai) % 检查对象是否仍在运行
        data=peekdata(Ai,Ai.SampleRate/2); % 获取对象中的最后Ai.SampleRate个采样数据
        data_all=peekdata(Ai,LastTime*Ai.SampleRate);
        plot_sound(handles,data);
        plot_freq(handles,Fs,data);
% %         plot(data) % 绘制最后Ai.SampleRate个采样数据的图形，因此表现出来就是实时的了
%         f=linspace(0,Ai.SampleRate/2,2205);
%         yfft = 2*abs( (1/4410)*fft(data));    %做频谱
% %         length(yfft);
% %       axes(handles.axes1);
%         bar(f,yfft(1:2205));
% %       set(handles.axes2,'xlim',[0 4200]);

% %         sound_data=getdata(Ai);
         drawnow; % 刷新图像
    end
    warning on
end
% wavwrite()
stop(Ai); % 停止对象
delete(Ai); % 删除对象
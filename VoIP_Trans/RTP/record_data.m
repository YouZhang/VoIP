function data_all = record_data(handles,LastTime)
% clc,clear;
% handles = guihandles(gcf);
isRealTime=1; % �Ƿ�ͬ����ʾ
Ai=analoginput('winsound'); % ����һ��ģ���ź��������
% ���ͨ��
addchannel(Ai,1:1);
% LastTime=4; % ����ʱ��
Ai.SampleRate=8000; % ����Ƶ��
Fs = Ai.SampleRate;
Ai.SamplesPerTrigger=Ai.SampleRate*LastTime; % ������
start(Ai); % ��������

if ~isRealTime % �ж��Ƿ�ͬ��
% ��ͬ��
    wait(Ai,LastTime+1); % ��Ҫ�ȴ�¼����
    data=getdata(Ai); % ��ȡ�����е���Ƶ����
    plot(data); % ��ͼ��
else
% ͬ��
    warning off % ���������ݲ���ʱ��ȡ������
%     T=clock;
%     pause(0.1);                          %������ͣ��0.1�� �����һ��ѭ������
%     while isrunning(Ai)
%           time=clock-T;                  %��ȡ�Ѳ��ŵ�ʱ�䲢�������
%           s=3600*time(4)+60*time(5)+time(6);
%           set(handles.slider_timeplan,'value',s/t);%���Ž�������ֵ
%           set(handles.text_timeleft,'string',round(t-s));%ʣ�ಥ��ʱ������
%           if(round(s*Fs+4410)<Ai.SamplesPerTrigger)  %��ֹ��󼸴�ѭ���������
%               data=peekdata(Ai,LastTime*Ai.SampleRate);
%               plot(handles.axes_rs,yp);         %��Ȼ4410Ϊ���趨�ĳ��ȣ������޸�
%               figure(1);
%               axis([0 50000 -1 1]);
%               handles.axes3;
%               plot(data);
%               set(handles.axes3,'YLim',[-1 1],'xlim',[0 4410]);
%               f=linspace(0,Fs/2,2205);
%               yfft = 2*abs( (1/4410)*fft(data));    %��Ƶ��
% %               figure(2);
%               handles.axes2;
%               bar(yfft);
%               set(handles.axes2,'xlim',[0 4200]);
%               plot_sound(handles,yp)
%               plot_freq(handles,Fs,yp);
%               drawnow;                     %��������ܹؼ���ˢ������
%           end
%     end
%     warning on
% end
%%
%ԭ������ʾ
    pause(0.4); 
    while isrunning(Ai) % �������Ƿ���������
        data=peekdata(Ai,Ai.SampleRate/2); % ��ȡ�����е����Ai.SampleRate����������
        data_all=peekdata(Ai,LastTime*Ai.SampleRate);
        plot_sound(handles,data);
        plot_freq(handles,Fs,data);
% %         plot(data) % �������Ai.SampleRate���������ݵ�ͼ�Σ���˱��ֳ�������ʵʱ����
%         f=linspace(0,Ai.SampleRate/2,2205);
%         yfft = 2*abs( (1/4410)*fft(data));    %��Ƶ��
% %         length(yfft);
% %       axes(handles.axes1);
%         bar(f,yfft(1:2205));
% %       set(handles.axes2,'xlim',[0 4200]);

% %         sound_data=getdata(Ai);
         drawnow; % ˢ��ͼ��
    end
    warning on
end
% wavwrite()
stop(Ai); % ֹͣ����
delete(Ai); % ɾ������
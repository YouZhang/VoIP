function plot_freq(handles,Fs,yp)
f=linspace(0,Fs/2,2205);
yfft = 2*abs( (1/4410)*fft(yp));    %×öÆµÆ×
%figure(2);
axes(handles.axes1);
% handles.axes1
bar(f,yfft(1:2205));
set(handles.axes1,'xlim',[0 4200]);
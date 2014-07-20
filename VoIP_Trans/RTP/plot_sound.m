function plot_sound(handles,sound)
    axes(handles.axes2);
%     handles.axes2
    plot(sound);
    set(handles.axes2,'YLim',[-1 1],'xlim',[0 4410]);
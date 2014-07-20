function varargout = server_gui(varargin)
% SERVER_GUI MATLAB code for server_gui.fig
%      SERVER_GUI, by itself, creates a new SERVER_GUI or raises the existing
%      singleton*.
%
%      H = SERVER_GUI returns the handle to a new SERVER_GUI or the handle to
%      the existing singleton*.
%
%      SERVER_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SERVER_GUI.M with the given input arguments.
%
%      SERVER_GUI('Property','Value',...) creates a new SERVER_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before server_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to server_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help server_gui

% Last Modified by GUIDE v2.5 29-Dec-2013 20:38:23

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @server_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @server_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before server_gui is made visible.
function server_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to server_gui (see VARARGIN)

% Choose default command line output for server_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes server_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = server_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



%%
%��������
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global message;
global seconds;
% if(seconds)
% judge_mat = isnan(seconds);
if(isempty(seconds)||length(seconds)>3)
    set(handles.edit2,'string','��ѡ��¼��ʱ�䣡');
else
    cla(handles.axes2);
    cla(handles.axes1);
    s = str2double(seconds);
    message = G7231Coder ('test.wav','out_3.bit',handles,s);
    sendto(message);   
end


% % --- Executes during object creation, after setting all properties.
function pushbutton3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


%%
%�༭���֣���ȡ��������
function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
global data_input;
data_input = get(hObject,'String');


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
%���Ͷ���
% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data_input;
global ID;
global client_ip;
global ring_data;
global FS;
% global send;

% time_min = fix(clock);
if(isempty(ID) || isempty(client_ip))
    content_show = '����������ID,ѡ��Է���IP��';
    set(handles.edit3,'String',content_show);
    set(handles.edit2,'String','');
else
    time_now = fix(clock);
    time_now = num2str(time_now');
    T = [time_now(1,:) '.' time_now(2,:) '.' time_now(3,:) '  ' time_now(4,:) ':' time_now(5,:) ':' time_now(6,:)];
    user = [T '**' ID '**˵��'];
    msg_disp = connect_text(user,data_input);
    set(handles.edit2,'String','');
    text_before = get(handles.edit3,'String');
    content_show = connect_text(text_before,msg_disp);

    set(handles.edit3,'String',content_show);
    set(handles.edit2,'String','');
    GB_val = string2GB2312(msg_disp);
    GB_val = int2str(GB_val);
   
    set(handles.edit2,'String','���ڷ���');
    send_msg(GB_val);
    set(handles.edit2,'String','���ͳɹ�');
end

recv(handles,client_ip,ring_data,FS);

%%
%��ʾ��������
function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
%��½
% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global press;
global ID;
global contents;
% server_host = '192.168.4.133';
% server_host = '192.168.137.167';
% server_host = '59.79.92.71';
% server_host = '192.168.254.84';
server_host = '192.168.191.9';
server_port = 8989;

if(isempty(ID))
    set(handles.edit3,'string','����������ID��');
    return;
end
my_IP = get_IP();
IP_len = length(my_IP);
contents = cellstr(get(handles.choose_friend,'String'));
if(press)
    user = [];
    l = length(contents);
    if(~l)
        l = l+2;
    end
    space = repmat(' ',[l,1]);
    %%
    set(handles.edit3,'string','���ڵ�½�����Ե�Ƭ��~');
    %���շ������������ݣ�IP;
    user_num = client(server_host, server_port, 20);
    % set(handles.choose_friend,'string',[contacts_new]);
    user_num = str2double(user_num);
    i = 1;

    while(i <=user_num)
        user_temp = client(server_host, server_port,3);
        user = [user;user_temp];
        i = i +1;
    end

    i = 1;
    [r,c] = size(user);
    if(IP_len == c)
        while(i <=r)
            pos = regexp(user(i,:),my_IP,'start');
            if(~isempty(pos))
                user(i,:) = [];
                i = i -1;
                r = r -1;
            end
            i = i + 1;
        end
    end
    user = connect_text(user,space(1:l-r,:));
    
    set(handles.choose_friend,'string',user);
    if(r <=1)
        set(handles.edit3,'string','����ɹ�����Ǹ��û�к�������,���Ժ����鿴����~');
    else
        set(handles.edit3,'string','��ϲ��½�ɹ���ѡ����ѿ�ʼ����ɣ�'); 
    end
    set(handles.pushbutton10,'string','�˳�'); 
    press = press -1;
else
    set(handles.edit3,'string','�����˳������Ժ�~'); 
    user_num = client(server_host, server_port, 20);
    user_num = str2double(user_num);
    i = 1;
    while(i <=user_num)
        client(server_host, server_port,3);
        i = i +1;
    end
    if(user_num)
        set(handles.edit3,'string','�ɹ��˳���'); 
%         clear all;
    else
        set(handles.edit3,'string','�������쳣��'); 
%         clear all;
    end
    set(handles.pushbutton10,'string','��½'); 
    press = press +1;
end



%%
%����Է���IP��ɾ����
function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
% global client_ip;
% global ring_data;
% global FS;
% client_ip = get(handles.edit4,'String');
% [ring_data,FS] = wavread('ring.wav');

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
%��ȡID
function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
global ID;
global press;
ID = get(hObject,'String');
if(isempty(ID))
    press = 0;
else
    press = 1;
    set(handles.pushbutton10,'string','��½');
end

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
%��ȡ¼��ʱ��
% --- Executes on selection change in record_time.
function record_time_Callback(hObject, eventdata, handles)
% hObject    handle to record_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns record_time contents as cell array
%        contents{get(hObject,'Value')} returns selected item from record_time
global seconds;
LastTime = cellstr(get(hObject,'String'));
seconds = LastTime{get(hObject,'Value')};

% --- Executes during object creation, after setting all properties.
function record_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to record_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
%ѡ�����
% --- Executes on selection change in choose_friend.
function choose_friend_Callback(hObject, eventdata, handles)
% hObject    handle to choose_friend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns choose_friend contents as cell array
%        contents{get(hObject,'Value')} returns selected item from choose_friend
global client_ip;
global contents;
global ring_data;
global FS;
contents = cellstr(get(hObject,'String'));
client_ip = contents{get(hObject,'Value')};
[ring_data,FS] = wavread('ring.wav');

recv(handles,client_ip,ring_data,FS);

% --- Executes during object creation, after setting all properties.
function choose_friend_CreateFcn(hObject, eventdata, handles)
% hObject    handle to choose_friend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
%�˳�
% --- Executes on button press in quit.
function quit_Callback(hObject, eventdata, handles)
% hObject    handle to quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

button = questdlg('�Ƿ�ȷ���˳�����','�ر�ȷ��','��','��','��');
if strcmp(button,'��')
    delete(hObject);
else
    return
end
clear all;
close(gcf);
% [get,client_ip] = server(message, output_port, )

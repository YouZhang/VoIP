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

% Last Modified by GUIDE v2.5 29-Dec-2013 12:37:01

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
%发送语音
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global message;
global seconds;
cla(handles.axes2);
cla(handles.axes1);
s = str2double(seconds);
message = G7231Coder ('test.wav','out_3.bit',handles,s);
sendto(message);


% % --- Executes during object creation, after setting all properties.
function pushbutton3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


%%
%编辑框
function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
global data_input;
data_input = get(hObject,'String');


% data_input = str2double(data_input);


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
%发送短信
% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data_input;
global ID;
global client_ip;
global send;

time_min = fix(clock);
if(isempty(ID) || isempty(client_ip))
    content_show = '请输入您的ID和对方的IP';
    set(handles.edit3,'String',content_show);
    set(handles.edit2,'String','');
else
    time_now = fix(clock);
    time_now = num2str(time_now');
    T = [time_now(1,:) '.' time_now(2,:) '.' time_now(3,:) '  ' time_now(4,:) ':' time_now(5,:) ':' time_now(6,:)];
    user = [T '**' ID '**说：'];
    msg_disp = connect_text(user,data_input);
    set(handles.edit2,'String','');
    text_before = get(handles.edit3,'String');
    content_show = connect_text(text_before,msg_disp);

    set(handles.edit3,'String',content_show);
    set(handles.edit2,'String','');
    GB_val = string2GB2312(msg_disp);
    GB_val = int2str(GB_val);
   
    set(handles.edit2,'String','正在发送');
    send_msg(GB_val);
    set(handles.edit2,'String','发送成功');
end
pushbutton10_Callback(hObject, eventdata, handles);  

%%
%显示
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
%登陆
% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data;
global client_ip;
global fs;
global FS;
global ring_data;
% global ID;
server_host = '192.168.4.135';
server_port = 8989;
% my_IP = get_IP();
% my_profile = [my_IP,ID];
% get = server(my_profile, 8989, 30);
% set(handles.edit3,'String','正在登陆，请稍等...');
% while(get ~= 1)
%     get = server(my_profile, 8989, 30);
% end
% set(handles.edit3,'String','登入成功！请查看在线好友，开始聊天吧！');
%%
%接收服务器来的数据，IP;
contacts = client(server_host, server_port, 20);
% get(handles.choose_friend,'String');
set(handles.choose_friend,'string',['1';'2']);
% text_before = get(handles.edit3,'String');
char = GB2string(info);
content_show = connect_text(text_before,char);
set(handles.edit3,'String',content_show);
wavplay(ring_data,FS);
time_now = fix(clock); 
delta_time = time_now(5) - time_past(5);

pause(12);
time_past = fix(clock);
data_2 = [];
client_ip = get(handles.edit4,'String');
data = '';
times_char = client(client_ip, 3000);
times = str2double(times_char);
i = 1;

while(i <=times)

    data_temp = client(client_ip, 3000,3);
    data_len = length(data_temp);
    if(data_len>3000)
        data = [data,data_temp];
    else
        data_2 = [data_2;data_temp];
    end
    i = i +1;
end
len = length(data);
if(len>8024)
    
    [sound,fs] = G7231Decoder(data,'out_1.bit','a_x.wav');
    wavplay(ring_data,FS);
    play_show(sound,fs,handles);
    pause(2*times);
    pushbutton10_Callback(hObject, eventdata, handles);
else
    text_before = get(handles.edit3,'String');
    char = GB2string(data_2);
    content_show = connect_text(text_before,char);
    set(handles.edit3,'String',content_show);
    wavplay(ring_data,FS);
    time_now = fix(clock); 
    delta_time = time_now(5) - time_past(5);
    if(delta_time >= 5 )
        set(handles.edit3,'String','超时，为了安全，请重新登入');
    else
        pushbutton10_Callback(hObject, eventdata, handles);
    end
end


function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
global client_ip;
global ring_data;
global FS;
client_ip = get(handles.edit4,'String');
[ring_data,FS] = wavread('ring.wav');

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



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
global ID;
ID = get(hObject,'String');

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


% --- Executes on selection change in choose_friend.
function choose_friend_Callback(hObject, eventdata, handles)
% hObject    handle to choose_friend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns choose_friend contents as cell array
%        contents{get(hObject,'Value')} returns selected item from choose_friend


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


% --- Executes on button press in quit.
function quit_Callback(hObject, eventdata, handles)
% hObject    handle to quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

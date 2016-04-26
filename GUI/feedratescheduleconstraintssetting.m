function varargout = feedratescheduleconstraintssetting(varargin)
% 设置各项约束的具体值
% 如果设置成功，那么输出将会是具体的约束值，他们存放在结构体中，如果设置失败，则会返回值0

% Edit the above text to modify the response to help feedratescheduleconstraintssetting

% Last Modified by GUIDE v2.5 27-Jan-2015 14:29:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @feedratescheduleconstraintssetting_OpeningFcn, ...
                   'gui_OutputFcn',  @feedratescheduleconstraintssetting_OutputFcn, ...
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


% --- Executes just before feedratescheduleconstraintssetting is made visible.
function feedratescheduleconstraintssetting_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to feedratescheduleconstraintssetting (see VARARGIN)

% Choose default command line output for feedratescheduleconstraintssetting
handles.output = hObject;

% 将传入的参数保存起来
handles.constrsel = varargin{1};

% 根据选择，将选择部分可编辑，其他不可编辑
if handles.constrsel.dynconstrsel == 1
	set(handles.maxfeeddyn_edit, 'enable', 'on');
	set(handles.maxaccdyn_edit, 'enable', 'on');
	set(handles.maxjerkdyn_edit, 'enable', 'on');
else
	set(handles.maxfeeddyn_edit, 'enable', 'off');
	set(handles.maxaccdyn_edit, 'enable', 'off');
	set(handles.maxjerkdyn_edit, 'enable', 'off');
end

if handles.constrsel.geoconstrsel == 1
	set(handles.maxgeometryerr_edit, 'enable', 'on');
else
	set(handles.maxgeometryerr_edit, 'enable', 'off');
end

if handles.constrsel.oriconstrsel == 1
	set(handles.maxangularvelocity_edit, 'enable', 'on');
	set(handles.maxangularacc_edit, 'enable', 'on');
	set(handles.maxangularjerk_edit, 'enable', 'on');
else
	set(handles.maxangularvelocity_edit, 'enable', 'off');
	set(handles.maxangularacc_edit, 'enable', 'off');
	set(handles.maxangularjerk_edit, 'enable', 'off');
end

if handles.constrsel.driconstrsel == 1
	set(handles.Xmaxvelocity_edit, 'enable', 'on');
	set(handles.Xmaxacc_edit, 'enable', 'on');
	set(handles.Xmaxjerk_edit, 'enable', 'on');
	
	set(handles.Ymaxvelocity_edit, 'enable', 'on');
	set(handles.Ymaxacc_edit, 'enable', 'on');
	set(handles.Ymaxjerk_edit, 'enable', 'on');
	
	set(handles.Zmaxvelocity_edit, 'enable', 'on');
	set(handles.Zmaxacc_edit, 'enable', 'on');
	set(handles.Zmaxjerk_edit, 'enable', 'on');
	
	set(handles.Amaxvelocity_edit, 'enable', 'on');
	set(handles.Amaxacc_edit, 'enable', 'on');
	set(handles.Amaxjerk_edit, 'enable', 'on');
	
	set(handles.Cmaxvelocity_edit, 'enable', 'on');
	set(handles.Cmaxacc_edit, 'enable', 'on');
	set(handles.Cmaxjerk_edit, 'enable', 'on');
else
	set(handles.Xmaxvelocity_edit, 'enable', 'off');
	set(handles.Xmaxacc_edit, 'enable', 'off');
	set(handles.Xmaxjerk_edit, 'enable', 'off');
	
	set(handles.Ymaxvelocity_edit, 'enable', 'off');
	set(handles.Ymaxacc_edit, 'enable', 'off');
	set(handles.Ymaxjerk_edit, 'enable', 'off');
	
	set(handles.Zmaxvelocity_edit, 'enable', 'off');
	set(handles.Zmaxacc_edit, 'enable', 'off');
	set(handles.Zmaxjerk_edit, 'enable', 'off');
	
	set(handles.Amaxvelocity_edit, 'enable', 'off');
	set(handles.Amaxacc_edit, 'enable', 'off');
	set(handles.Amaxjerk_edit, 'enable', 'off');
	
	set(handles.Cmaxvelocity_edit, 'enable', 'off');
	set(handles.Cmaxacc_edit, 'enable', 'off');
	set(handles.Cmaxjerk_edit, 'enable', 'off');
end

if handles.constrsel.forconstrsel == 1
	set(handles.maxcuttingforce_edit, 'enable', 'on');
else
	set(handles.maxcuttingforce_edit, 'enable', 'off');
end

% Update handles structure
guidata(hObject, handles);
uiwait;

% UIWAIT makes feedratescheduleconstraintssetting wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = feedratescheduleconstraintssetting_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

if isfield(handles, 'output')
    handles.output.error = 0;
    varargout{1} = handles.output;
else
    varargout.error = 1;
end
delete(hObject);

% --- Executes on button press in setok_pushbutton.
function setok_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to setok_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 获取动力学约束
constr.dynconstr.maxvelo = str2double(get(handles.maxfeeddyn_edit, 'string'));
constr.dynconstr.maxacce = str2double(get(handles.maxaccdyn_edit, 'string'));
constr.dynconstr.maxjerk = str2double(get(handles.maxjerkdyn_edit, 'string'));

% 获取轮廓误差约束
constr.geoconstr = str2double(get(handles.maxgeometryerr_edit, 'string'));

% 获取刀轴转速约束
constr.oriconstr.maxvelo = str2double(get(handles.maxangularvelocity_edit, 'string'));
constr.oriconstr.maxacce = str2double(get(handles.maxangularacc_edit, 'string'));
constr.oriconstr.maxjerk = str2double(get(handles.maxangularjerk_edit, 'string'));

% 获取各轴伺服能力约束
constr.driconstr.X.maxvelo = str2double(get(handles.Xmaxvelocity_edit, 'string'));
constr.driconstr.X.maxacce = str2double(get(handles.Xmaxacc_edit, 'string'));
constr.driconstr.X.maxjerk = str2double(get(handles.Xmaxjerk_edit, 'string'));

constr.driconstr.Y.maxvelo = str2double(get(handles.Ymaxvelocity_edit, 'string'));
constr.driconstr.Y.maxacce = str2double(get(handles.Ymaxacc_edit, 'string'));
constr.driconstr.Y.maxjerk = str2double(get(handles.Ymaxjerk_edit, 'string'));

constr.driconstr.Z.maxvelo = str2double(get(handles.Zmaxvelocity_edit, 'string'));
constr.driconstr.Z.maxacce = str2double(get(handles.Zmaxacc_edit, 'string'));
constr.driconstr.Z.maxjerk = str2double(get(handles.Zmaxjerk_edit, 'string'));

constr.driconstr.A.maxvelo = str2double(get(handles.Amaxvelocity_edit, 'string'));
constr.driconstr.A.maxacce = str2double(get(handles.Amaxacc_edit, 'string'));
constr.driconstr.A.maxjerk = str2double(get(handles.Amaxjerk_edit, 'string'));

constr.driconstr.C.maxvelo = str2double(get(handles.Cmaxvelocity_edit, 'string'));
constr.driconstr.C.maxacce = str2double(get(handles.Cmaxacc_edit, 'string'));
constr.driconstr.C.maxjerk = str2double(get(handles.Cmaxjerk_edit, 'string'));

% 获取切削力约束
constr.forconstr = str2double(get(handles.maxcuttingforce_edit, 'string'));

handles.output = constr;
guidata(hObject, handles);
uiresume;


function maxcuttingforce_edit_Callback(hObject, eventdata, handles)
% hObject    handle to maxcuttingforce_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxcuttingforce_edit as text
%        str2double(get(hObject,'String')) returns contents of maxcuttingforce_edit as a double


% --- Executes during object creation, after setting all properties.
function maxcuttingforce_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxcuttingforce_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxangularvelocity_edit_Callback(hObject, eventdata, handles)
% hObject    handle to maxangularvelocity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxangularvelocity_edit as text
%        str2double(get(hObject,'String')) returns contents of maxangularvelocity_edit as a double


% --- Executes during object creation, after setting all properties.
function maxangularvelocity_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxangularvelocity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxangularacc_edit_Callback(hObject, eventdata, handles)
% hObject    handle to maxangularacc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxangularacc_edit as text
%        str2double(get(hObject,'String')) returns contents of maxangularacc_edit as a double


% --- Executes during object creation, after setting all properties.
function maxangularacc_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxangularacc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxangularjerk_edit_Callback(hObject, eventdata, handles)
% hObject    handle to maxangularjerk_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxangularjerk_edit as text
%        str2double(get(hObject,'String')) returns contents of maxangularjerk_edit as a double


% --- Executes during object creation, after setting all properties.
function maxangularjerk_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxangularjerk_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxgeometryerr_edit_Callback(hObject, eventdata, handles)
% hObject    handle to maxgeometryerr_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxgeometryerr_edit as text
%        str2double(get(hObject,'String')) returns contents of maxgeometryerr_edit as a double


% --- Executes during object creation, after setting all properties.
function maxgeometryerr_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxgeometryerr_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxfeeddyn_edit_Callback(hObject, eventdata, handles)
% hObject    handle to maxfeeddyn_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxfeeddyn_edit as text
%        str2double(get(hObject,'String')) returns contents of maxfeeddyn_edit as a double


% --- Executes during object creation, after setting all properties.
function maxfeeddyn_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxfeeddyn_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxaccdyn_edit_Callback(hObject, eventdata, handles)
% hObject    handle to maxaccdyn_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxaccdyn_edit as text
%        str2double(get(hObject,'String')) returns contents of maxaccdyn_edit as a double


% --- Executes during object creation, after setting all properties.
function maxaccdyn_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxaccdyn_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxjerkdyn_edit_Callback(hObject, eventdata, handles)
% hObject    handle to maxjerkdyn_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxjerkdyn_edit as text
%        str2double(get(hObject,'String')) returns contents of maxjerkdyn_edit as a double


% --- Executes during object creation, after setting all properties.
function maxjerkdyn_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxjerkdyn_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cmaxvelocity_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Cmaxvelocity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cmaxvelocity_edit as text
%        str2double(get(hObject,'String')) returns contents of Cmaxvelocity_edit as a double


% --- Executes during object creation, after setting all properties.
function Cmaxvelocity_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cmaxvelocity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cmaxacc_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Cmaxacc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cmaxacc_edit as text
%        str2double(get(hObject,'String')) returns contents of Cmaxacc_edit as a double


% --- Executes during object creation, after setting all properties.
function Cmaxacc_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cmaxacc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cmaxjerk_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Cmaxjerk_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cmaxjerk_edit as text
%        str2double(get(hObject,'String')) returns contents of Cmaxjerk_edit as a double


% --- Executes during object creation, after setting all properties.
function Cmaxjerk_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cmaxjerk_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Amaxvelocity_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Amaxvelocity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Amaxvelocity_edit as text
%        str2double(get(hObject,'String')) returns contents of Amaxvelocity_edit as a double


% --- Executes during object creation, after setting all properties.
function Amaxvelocity_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Amaxvelocity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Amaxacc_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Amaxacc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Amaxacc_edit as text
%        str2double(get(hObject,'String')) returns contents of Amaxacc_edit as a double


% --- Executes during object creation, after setting all properties.
function Amaxacc_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Amaxacc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Amaxjerk_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Amaxjerk_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Amaxjerk_edit as text
%        str2double(get(hObject,'String')) returns contents of Amaxjerk_edit as a double


% --- Executes during object creation, after setting all properties.
function Amaxjerk_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Amaxjerk_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Zmaxvelocity_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Zmaxvelocity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Zmaxvelocity_edit as text
%        str2double(get(hObject,'String')) returns contents of Zmaxvelocity_edit as a double


% --- Executes during object creation, after setting all properties.
function Zmaxvelocity_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Zmaxvelocity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Zmaxacc_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Zmaxacc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Zmaxacc_edit as text
%        str2double(get(hObject,'String')) returns contents of Zmaxacc_edit as a double


% --- Executes during object creation, after setting all properties.
function Zmaxacc_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Zmaxacc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Zmaxjerk_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Zmaxjerk_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Zmaxjerk_edit as text
%        str2double(get(hObject,'String')) returns contents of Zmaxjerk_edit as a double


% --- Executes during object creation, after setting all properties.
function Zmaxjerk_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Zmaxjerk_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ymaxvelocity_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Ymaxvelocity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ymaxvelocity_edit as text
%        str2double(get(hObject,'String')) returns contents of Ymaxvelocity_edit as a double


% --- Executes during object creation, after setting all properties.
function Ymaxvelocity_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ymaxvelocity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ymaxacc_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Ymaxacc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ymaxacc_edit as text
%        str2double(get(hObject,'String')) returns contents of Ymaxacc_edit as a double


% --- Executes during object creation, after setting all properties.
function Ymaxacc_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ymaxacc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ymaxjerk_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Ymaxjerk_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ymaxjerk_edit as text
%        str2double(get(hObject,'String')) returns contents of Ymaxjerk_edit as a double


% --- Executes during object creation, after setting all properties.
function Ymaxjerk_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ymaxjerk_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Xmaxvelocity_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Xmaxvelocity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Xmaxvelocity_edit as text
%        str2double(get(hObject,'String')) returns contents of Xmaxvelocity_edit as a double


% --- Executes during object creation, after setting all properties.
function Xmaxvelocity_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xmaxvelocity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Xmaxacc_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Xmaxacc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Xmaxacc_edit as text
%        str2double(get(hObject,'String')) returns contents of Xmaxacc_edit as a double


% --- Executes during object creation, after setting all properties.
function Xmaxacc_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xmaxacc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Xmaxjerk_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Xmaxjerk_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Xmaxjerk_edit as text
%        str2double(get(hObject,'String')) returns contents of Xmaxjerk_edit as a double


% --- Executes during object creation, after setting all properties.
function Xmaxjerk_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xmaxjerk_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

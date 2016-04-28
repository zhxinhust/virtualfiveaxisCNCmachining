function varargout = FiveAxisVirtualCNCSystem(varargin)
% FIVEAXISVIRTUALCNCSYSTEM MATLAB code for FiveAxisVirtualCNCSystem.fig
%      FIVEAXISVIRTUALCNCSYSTEM, by itself, creates a new FIVEAXISVIRTUALCNCSYSTEM or raises the existing
%      singleton*.
%
%      H = FIVEAXISVIRTUALCNCSYSTEM returns the handle to a new FIVEAXISVIRTUALCNCSYSTEM or the handle to
%      the existing singleton*.
%
%      FIVEAXISVIRTUALCNCSYSTEM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIVEAXISVIRTUALCNCSYSTEM.M with the given input arguments.
%
%      FIVEAXISVIRTUALCNCSYSTEM('Property','Value',...) creates a new FIVEAXISVIRTUALCNCSYSTEM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FiveAxisVirtualCNCSystem_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FiveAxisVirtualCNCSystem_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows onlFy one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FiveAxisVirtualCNCSystem

% Last Modified by GUIDE v2.5 29-Feb-2016 22:20:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FiveAxisVirtualCNCSystem_OpeningFcn, ...
                   'gui_OutputFcn',  @FiveAxisVirtualCNCSystem_OutputFcn, ...
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
% 添加文件目录，因为函数分模块放置，这里添加目录以能查找到相关的函数
addpath('..\Feedrate Schedule\');
addpath('..\Feedrate Schedule\Sshapefeedrateschedule');
addpath('..\Feedrate Schedule\Timeoptimalfeedrateschedule');
addpath('..\Interpolation\');
addpath('..\PostProcessing\');
addpath('..\ToolPathSmoothing\DualQuaternionApproximationWithDominantPoints\');
addpath('..\ToolPathSmoothing\DualQuaternionInterpolation\');
addpath('..\ToolPathSmoothing\FourSplineInterpolation_Yuen\');
addpath('..\ToolPathSmoothing\ThreeSplineInterpolation_Fleisig\');
addpath('..\ToolPathSmoothing\TwoSplineInterpolation_Langeron\');
addpath('..\Common\');
addpath('..\Resource');
addpath('..\Interpolation\secondorderTaylorinterp');


% End initialization code - DO NOT EDIT


% --- Executes just before FiveAxisVirtualCNCSystem is made visible.
function FiveAxisVirtualCNCSystem_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FiveAxisVirtualCNCSystem (see VARARGIN)

% Choose default command line output for FiveAxisVirtualCNCSystem


handles.fontsizelabel = 15;
handles.fontsize = 14;
handles.linewidth = 1.5;

handles.output = hObject;
%% 刀路光顺模块初始化
handles.smoothpath.method = 1;

%% 速度规划模块初始化
handles.feedrateschedule.method = 2;

%% 插补计算模块初始化
handles.interp.method = 2;

%% 表示设置进度，主要是为了方便保存以及下面的下一步提示
handles.step = 0;



machinetoolfig = imread('双转台.bmp');
% machinetoolfig = imread('AC双摆头模型.bmp');
axes(handles.machinetoolconfig_axes);
imshow(machinetoolfig);
handles.machinetype = 1; 

set(handles.pathsmoothpic_axes, 'position', [21, 9, 687, 238]);
smoothapathfig = imread('特征点选择的对偶四元数拟合.jpg');
axes(handles.pathsmoothpic_axes);
imagesc(smoothapathfig);

axis off

set(handles.feedrateschedulingmethod_axis, 'position', [30, 19, 705, 265]);
axes(handles.feedrateschedulingmethod_axis);
feedrateschedulefig = imread('时间最优速度规划.bmp');
imagesc(feedrateschedulefig);
axis off

axes(handles.interp_axes);
interpfig = imread('二阶泰勒.bmp');
imagesc(interpfig);
axis off

axes(handles.hustlogo_axes);
interpfig = imread('合成校标.jpg');
imagesc(interpfig);
axis off


% Update handles structure
guidata(hObject, handles);
set(handles.Axesmoverangesetting_panel, 'position', [4.6, 14, 55, 14.5]);
set(handles.rotarytablesetting_uipanel, 'position', [4.2, 29, 55, 6.85], 'visible', 'on');
set(handles.rotaryspindlesetting_uipanel, 'position', [4.2, 29, 55, 4.8], 'visible', 'off');
set(handles.Axesmoverangesetting_panel, 'position', [4.6, 14, 55, 14.5]);
% UIWAIT makes FiveAxisVirtualCNCSystem wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FiveAxisVirtualCNCSystem_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function Help_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function OpenProject_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function SaveProject_Callback(hObject, eventdata, handles)
% 保存菜单
if handles.step > 0
	% 大于0，则表示已经完成了机床结构配置
    saveproject.step = handles.step;	% 保存当前进度
	saveproject.machinetype = handles.machinetype;	% 保存机床类型
	% 根据机床结构，保存结构相关的参数
	if handles.machinetype == 1
		saveproject.rotarytable = handles.rotarytable;
	elseif handles.machinetype == 2
		saveproject.rotaryspindle = handles.rotaryspindle;
	end
	saveproject.axesmoverangesetting = handles.axesmoverangesetting;
	
	if handles.step > 1
		% 说明已经完成了读取刀路文件
		saveproject.linearpath = handles.linearpath;
		
		if handles.step > 2
			% 说明已经完成了刀路光顺
			saveproject.smoothpath = handles.smoothpath;
		end
	end
end

% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)

% --- Executes on button press in interpolation_togglebutton.
function interpolation_togglebutton_Callback(hObject, eventdata, handles)


% 模拟选项卡的效果，实际上就是多面板切换显示，按键文字加粗且字体增大
set(handles.machinetoolconfig_togglebutton, 'Value', 0, 'backgroundcolor', [0.8 0.8 0.8], 'fontweight', 'normal', 'fontsize', 10);
set(handles.toolpath_togglebutton, 'Value', 0, 'backgroundcolor', [0.8 0.8 0.8], 'fontweight', 'normal', 'fontsize', 10);
set(handles.toolpathsmooth_togglebutton, 'Value', 0, 'backgroundcolor', [0.8 0.8 0.8], 'fontweight', 'normal', 'fontsize', 10);
set(handles.feedrateschedule_togglebutton, 'Value', 0, 'backgroundcolor', [0.8 0.8 0.8], 'fontweight', 'normal', 'fontsize', 10);
set(handles.interpolation_togglebutton, 'Value', 1, 'backgroundcolor', [0.941 0.941 0.941], 'fontweight', 'bold', 'fontsize', 12);

set(handles.machinetoolconfig_panel,  'visible', 'off');
set(handles.toolpath_panel,  'visible', 'off');
set(handles.toolpathsmooth_panel,  'visible', 'off');
set(handles.feedrateschedule_panel,  'visible', 'off');
set(handles.interpolation_panel,  'visible', 'on');

drawnow expose       
% Hint: get(hObject,'Value') returns toggle state of interpolation_togglebutton


% --- Executes on button press in feedrateschedule_togglebutton.
function feedrateschedule_togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to feedrateschedule_togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 模拟选项卡的效果，实际上就是多面板切换显示，按键文字加粗且字体增大
set(handles.machinetoolconfig_togglebutton, 'Value', 0, 'backgroundcolor', [0.8 0.8 0.8], 'fontweight', 'normal', 'fontsize', 10);
set(handles.toolpath_togglebutton, 'Value', 0, 'backgroundcolor', [0.8 0.8 0.8], 'fontweight', 'normal', 'fontsize', 10);
set(handles.toolpathsmooth_togglebutton, 'Value', 0, 'backgroundcolor', [0.8 0.8 0.8], 'fontweight', 'normal', 'fontsize', 10);
set(handles.feedrateschedule_togglebutton, 'Value', 1, 'backgroundcolor', [0.941 0.941 0.941], 'fontweight', 'bold', 'fontsize', 12);
set(handles.interpolation_togglebutton, 'Value', 0, 'backgroundcolor', [0.8 0.8 0.8], 'fontweight', 'normal', 'fontsize', 10);

set(handles.machinetoolconfig_panel,  'visible', 'off');
set(handles.toolpath_panel,  'visible', 'off');
set(handles.toolpathsmooth_panel,  'visible', 'off');
set(handles.feedrateschedule_panel,  'visible', 'on');
set(handles.interpolation_panel,  'visible', 'off');

drawnow expose       
% Hint: get(hObject,'Value') returns toggle state of feedrateschedule_togglebutton


% --- Executes on button press in toolpath_togglebutton.
function toolpath_togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to toolpath_togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 模拟选项卡的效果，实际上就是多面板切换显示，按键文字加粗且字体增大
set(handles.machinetoolconfig_togglebutton, 'Value', 0, 'backgroundcolor', [0.8 0.8 0.8], 'fontweight', 'normal', 'fontsize', 10);
set(handles.toolpath_togglebutton, 'Value', 1, 'backgroundcolor', [0.941 0.941 0.941], 'fontweight', 'bold', 'fontsize', 12);
set(handles.toolpathsmooth_togglebutton, 'Value', 0, 'backgroundcolor', [0.8 0.8 0.8], 'fontweight', 'normal', 'fontsize', 10);
set(handles.feedrateschedule_togglebutton, 'Value', 0, 'backgroundcolor', [0.8 0.8 0.8], 'fontweight', 'normal', 'fontsize', 10);
set(handles.interpolation_togglebutton, 'Value', 0, 'backgroundcolor', [0.8 0.8 0.8], 'fontweight', 'normal', 'fontsize', 10);

set(handles.machinetoolconfig_panel,  'visible', 'off');
set(handles.toolpath_panel,  'visible', 'on');
set(handles.toolpathsmooth_panel,  'visible', 'off');
set(handles.feedrateschedule_panel,  'visible', 'off');
set(handles.interpolation_panel,  'visible', 'off');

drawnow expose       
% Hint: get(hObject,'Value') returns toggle state of toolpath_togglebutton


% --- Executes on button press in toolpathsmooth_togglebutton.
function toolpathsmooth_togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to toolpathsmooth_togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 模拟选项卡的效果，实际上就是多面板切换显示，按键文字加粗且字体增大
set(handles.machinetoolconfig_togglebutton, 'Value', 0, 'backgroundcolor', [0.8 0.8 0.8], 'fontweight', 'normal', 'fontsize', 10);
set(handles.toolpath_togglebutton, 'Value', 0, 'backgroundcolor', [0.8 0.8 0.8], 'fontweight', 'normal', 'fontsize', 10);
set(handles.toolpathsmooth_togglebutton, 'Value', 1, 'backgroundcolor', [0.941 0.941 0.941], 'fontweight', 'bold', 'fontsize', 12);
set(handles.feedrateschedule_togglebutton, 'Value', 0, 'backgroundcolor', [0.8 0.8 0.8], 'fontweight', 'normal', 'fontsize', 10);
set(handles.interpolation_togglebutton, 'Value', 0, 'backgroundcolor', [0.8 0.8 0.8], 'fontweight', 'normal', 'fontsize', 10);

set(handles.machinetoolconfig_panel,  'visible', 'off');
set(handles.toolpath_panel,  'visible', 'off');
set(handles.toolpathsmooth_panel,  'visible', 'on');
set(handles.feedrateschedule_panel,  'visible', 'off');
set(handles.interpolation_panel,  'visible', 'off');

drawnow expose       
% Hint: get(hObject,'Value') returns toggle state of toolpathsmooth_togglebutton



function opentoolpathfilename_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function opentoolpathfilename_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in opentoolpathfile_pushbutton.
function opentoolpathfile_pushbutton_Callback(hObject, eventdata, handles)

% 打开读取文件对话框，这里设置文件过滤器
[filename, pahtname, filerindex] = uigetfile({'*.txt;*.cl;*.mat'}, '选择路径文件',  '../Data/Input/');

% 如果读取文件失败，则直接退出，并弹出失败提示消息框
try
    data = importdata([pahtname filename]); % 加载数据
catch err
    if filename ~= 0
        % 失败则抛出错误消息
        h = msgbox(err.message, '读取文件失败');
        ah = get( h, 'CurrentAxes' );  
        ch = get( ah, 'Children' );  
        set( ch, 'fontname', '微软雅黑'); 
        set(handles.pathfilenotification_text, 'string', '打开路径文件失败，请重新加载刀具路径文件。');
    end
    return;
end

% 将读取到的刀具路径名保存下来
handles.linearpath.filename = [pahtname filename];

set(handles.opentoolpathfilename_edit, 'string', [pahtname filename])


% data = importdata([pahtname filename]); % 加载数据

% 如果只有一个数据点，那么说明文件中含有字符，则另外读取文件的方式进行读取
if size(data, 1) == 1
    % 读取文件中含有'GOTO\'字符的数据
    ATPfile = fopen([pahtname filename], 'r');
    rowNum = 1;
    while ~feof(ATPfile)
        fscanf(ATPfile, '%c', 5);             %读取每行前面的GOTO/  
        data2(rowNum, 1:6) = fscanf(ATPfile, '%f,%f,%f,%f,%f,%f');%读取坐标值
        rowNum = rowNum + 1;
    end
    fclose(ATPfile);
    handles.linearpath.data = data2;
    noticestr = ['读取到刀路文件包含 ' num2str(size(data2, 1)) ' 个刀位点'];
else
    handles.linearpath.data = data;
    noticestr = ['读取到刀路文件包含 ' num2str(size(data, 1)) ' 个刀位点'];
end

handles.step = 2;	% 刀路读取完成，保存信息
noticestr = [noticestr, '。 下一步进行刀路光顺。'];
handles.noticestring = noticestr;	% 保存提示信息

% set(handles.pathfilenotification_text, 'string', noticestr);
set(handles.notification_text, 'string', noticestr);
guidata(hObject,handles);

% 这些控件只有在读取到刀具路径后才能使用
% set(handles.linearpathprevier_pushbutton, 'enable', 'on');
set(handles.linearpathfileopen_pushbutton, 'enable', 'on');
set(handles.smoothcal_pushbutton, 'enable', 'on');

tooltip = handles.linearpath.data(:, 1:3);
toolrfp = handles.linearpath.data(:, 1:3) + 10 * handles.linearpath.data(:, 4:6);
axes(handles.showinputpath_axes);
plot3(tooltip(:, 1), tooltip(:, 2), tooltip(:, 3));
hold on;
plot3(toolrfp(:, 1), toolrfp(:, 2), toolrfp(:, 3), 'r');

for i = 1:size(tooltip, 1)
    plot3([tooltip(i, 1), toolrfp(i, 1)], [tooltip(i, 2), toolrfp(i, 2)], [tooltip(i, 3), toolrfp(i, 3)]);
end
% set(gca, 'fontsize', 20);



% --- Executes on button press in linearpathprevier_pushbutton.
function linearpathprevier_pushbutton_Callback(hObject, eventdata, handles)
tooltip = handles.linearpath.data(:, 1:3);
toolrfp = handles.linearpath.data(:, 1:3) + 10 * handles.linearpath.data(:, 4:6);
figure;
plot3(tooltip(:, 1), tooltip(:, 2), tooltip(:, 3));
hold on;
plot3(toolrfp(:, 1), toolrfp(:, 2), toolrfp(:, 3), 'r');

for i = 1:size(tooltip, 1)
    plot3([tooltip(i, 1), toolrfp(i, 1)], [tooltip(i, 2), toolrfp(i, 2)], [tooltip(i, 3), toolrfp(i, 3)]);
end
set(gca, 'fontsize', 20);
title('线性刀具路径');

% --- Executes on button press in linearpathfileopen_pushbutton.
function linearpathfileopen_pushbutton_Callback(hObject, eventdata, handles)

currentfold = cd;   % 获取当前路径
% system('notepad handles.linearpath.filename &');
str = ['dos(' '''notepad ' handles.linearpath.filename ' &'');'];
eval(str);          % 调用windows自带的记事本软件打开文本
cd(currentfold);    % 由于调用notepad.exe后目录会切换到system32中去，这里又切换回来

function edit2_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)

rmpath('..\Feedrate Schedule\');
rmpath('..\Interpolation\');
rmpath('..\PostProcessing\');
rmpath('..\ToolPathSmoothing\DualQuaternionApproximationWithDominantPoints\');
rmpath('..\ToolPathSmoothing\DualQuaternionInterpolation\');
rmpath('..\ToolPathSmoothing\FourSplineInterpolation_Yuen\');
rmpath('..\ToolPathSmoothing\ThreeSplineInterpolation_Fleisig\');
rmpath('..\ToolPathSmoothing\TwoSplineInterpolation_Langeron\');
rmpath('..\Common\');


% --- Executes on button press in smoothcal_pushbutton.
function smoothcal_pushbutton_Callback(hObject, eventdata, handles)

set(handles.notification_text, 'string',  '计算中，请稍等...');
%set(handles.pathsmoothingnotice_text, 'string', '计算中，请稍等...');
drawnow expose       
t1 = tic;
% 根据不同的设置，调用不同的光顺算法

noticestring = ' ';

% 采用try catch来捕捉异常，避免程序跑死而不知道
try
    if handles.smoothpath.method == 1
        %% 特征点选择的对偶四元数逼近方法

        % 获取特征点选择算法中需要用到的5个阈值
        curvaturethr_dpselection = str2double(get(handles.curvaturedominantselect_edit, 'string'));
        tipchordthr_dpselection = str2double(get(handles.tooltipdominantselect_edit, 'string'));
        orientationchordthr_dpselection = str2double(get(handles.toolotrientationdominantselect_edit, 'string'));
        tipiterativeaccuracy_dpselection = str2double(get(handles.tooltipiterativeaccuracy_edit, 'string'));
        orientationiterativeaccuracy_spselection = str2double(get(handles.toolorientationiterativeaccuracy_edit, 'string'));
        
        if isnan(curvaturethr_dpselection) || isnan(tipchordthr_dpselection) || isnan(orientationchordthr_dpselection) || isnan(tipiterativeaccuracy_dpselection) || isnan(orientationiterativeaccuracy_spselection)
            error('请输入正确的参数');
        end
        parameterizationmethod = get(handles.parameterizationmethod_popupmenu, 'value');    % 参数化方法
        splineorder = get(handles.curveorder_popupmenu, 'value') + 1;           % 拟合阶数
		
		% 保存设置的参数，方便保存工程用
		handles.smoothpath.dpselection.curvaturethr_dpselection = curvaturethr_dpselection;
		handles.smoothpath.dpselection.tipchordthr_dpselection = tipchordthr_dpselection;
		handles.smoothpath.dpselection.orientationchordthr_dpselection = orientationchordthr_dpselection;
% 		handles.smoothpath.dpselection.
		
		
        % 调用特征点选择的对偶四元数刀路拟合算法
        [CQ, U, errtip, errorie, tip0, vector0] = dualquaternionapproximationwithdominantpoints...
        (handles.linearpath.data, splineorder, curvaturethr_dpselection, tipchordthr_dpselection, orientationchordthr_dpselection,...
        tipiterativeaccuracy_dpselection, orientationiterativeaccuracy_spselection, parameterizationmethod);

        % 保存拟合误差
        handles.smoothpath.dualquatpath.errtip = errtip;
        handles.smoothpath.dualquatpath.errorie = errorie;

        % 保存控制对偶四元数
        handles.smoothpath.dualquatpath.dualquatspline.controlp = CQ;
        handles.smoothpath.dualquatpath.dualquatspline.knotvector = U;
        handles.smoothpath.dualquatpath.dualquatspline.splineorder = splineorder;

        % 保存对偶四元数要用到的初始刀尖点和刀轴向量
        handles.smoothpath.dualquatpath.tip0 = tip0;
        handles.smoothpath.dualquatpath.vector0 = vector0;

        set(handles.showothers_pushbutton, 'string', '刀尖和刀轴矢量');
        noticestring = '使用基于特征点选择的对偶四元数拟合方法';
        feedrateschedulingnoticestring = '请先设置约束值';
        
    elseif handles.smoothpath.method == 2
        %% 对偶四元数插值方法
        parameterizationmethod = get(handles.parameterizationmethod_popupmenu, 'value');    % 参数化方法
        splineorder = get(handles.curveorder_popupmenu, 'value') + 1;           % 拟合阶数

        % 对对偶四元数进行插值，得到控制四元数和节点矢量
        [CQ, U, tip0, vector0] = dualquaternioninterpolation(handles.linearpath.data, splineorder, parameterizationmethod);

        % 保存控制对偶四元数
        handles.smoothpath.dualquatpath.dualquatspline.controlp = CQ;
        handles.smoothpath.dualquatpath.dualquatspline.knotvector = U;
        handles.smoothpath.dualquatpath.dualquatspline.splineorder = splineorder;

        % 保存对偶四元数要用到的初始刀尖点和刀轴向量
        handles.smoothpath.dualquatpath.tip0 = tip0;
        handles.smoothpath.dualquatpath.vector0 = vector0;

        set(handles.showothers_pushbutton, 'string', '刀尖和刀轴矢量');
        noticestring = '使用对偶四元数插值方法';
        feedrateschedulingnoticestring = '请先设置约束值';
    
    elseif handles.smoothpath.method == 3
        %% 四样条插值方法
        [Q, U, polycoef, startl, sublen, B, W, LW, WQ] = foursplineinterp(handles.linearpath.data);

        % 刀尖点样条曲线
        handles.smoothpath.foursplineinterpath.tipspline.controlp = Q;
        handles.smoothpath.foursplineinterpath.tipspline.knotvector = U;
        handles.smoothpath.foursplineinterpath.tipspline.splineorder = 5;

        % 刀尖点l-u曲线
        handles.smoothpath.foursplineinterpath.feedcorrectionspline.A = polycoef;
        handles.smoothpath.foursplineinterpath.feedcorrectionspline.startl = startl;
        handles.smoothpath.foursplineinterpath.feedcorrectionspline.sublength = sublen;

        % 刀轴矢量样条曲线
        handles.smoothpath.foursplineinterpath.orientationspline.controlp = B;
        handles.smoothpath.foursplineinterpath.orientationspline.knotvector = W;
        handles.smoothpath.foursplineinterpath.orientationspline.splineorder = 5;

        % 刀轴矢量重新参数化曲线
        handles.smoothpath.foursplineinterpath.orientationreparam.LW = LW;
        handles.smoothpath.foursplineinterpath.orientationreparam.WQ = WQ;

        set(handles.showothers_pushbutton, 'string', '绘制四条曲线');
        noticestring = '使用四样条插值方法';
        feedrateschedulingnoticestring = '暂不支持此格式的刀具路径';
        
    elseif handles.smoothpath.method == 4
        %% 三样条插值方法
        [L, C, V, D, u, h] = threesplineinterp(handles.linearpath.data);

        handles.smoothpath.threesplineinterppath.tipspline.L = L;
        handles.smoothpath.threesplineinterppath.tipspline.C = C;

        handles.smoothpath.threesplineinterppath.orientationspline.V = V;
        handles.smoothpath.threesplineinterppath.orientationspline.D = D;

        handles.smoothpath.threesplineinterppath.reparam.u = u;
        handles.smoothpath.threesplineinterppath.reparam.h = h;

        set(handles.showothers_pushbutton, 'string', '绘制三条曲线');
        noticestring = '使用三样条插值方法';
        feedrateschedulingnoticestring = '暂不支持此格式的刀具路径';
        
    elseif handles.smoothpath.method == 5
        %% 双样条插值方法
        toollength = str2double(get(handles.tipreferencedist_edit, 'string'));  % 两点距离
        splineorder = get(handles.splineorder_popupmenu, 'value') + 1;              % 样条阶数
        
        if isnan(toollength)
            error('请输入正确的参数');
        end
        
        [CQ, U] = dualsplineinterp(handles.linearpath.data, splineorder, toollength);

        % 保存计算得到的数据
        handles.smoothpath.dualsplinepath.pathspline.controlp = CQ;
        handles.smoothpath.dualsplinepath.pathspline.knotvector = U;
        handles.smoothpath.dualsplinepath.pathspline.splineorder = splineorder;

        handles.smoothpath.dualsplinepath.toollength = toollength;

        set(handles.showothers_pushbutton, 'string', '等距误差');
        noticestring = '使用双样条插值方法';
        feedrateschedulingnoticestring = '暂不支持此格式的刀具路径';
    end
 
    set(handles.showlinearpath_pushbutton, 'enable', 'on');
    set(handles.showsplinepath_pushbutton, 'enable', 'on');
    set(handles.showlinearandsplinepath_pushbutton, 'enable', 'on');

    if handles.smoothpath.method == 1
        set(handles.showfittingerror_pushbutton, 'enable', 'on');
    else
        set(handles.showfittingerror_pushbutton, 'enable', 'off');
    end
    set(handles.showcurvature_pushbutton, 'enable', 'on');
    set(handles.showothers_pushbutton, 'enable', 'on');
    set(handles.savesmoothpath_pushbutton, 'enable', 'on');
    set(handles.smoothreport_pushbutton, 'enable', 'on');
    handles.smoothpath.caltime = toc(t1);      % 统计计算时间
	
	handles.noticestring = [noticestring, '光顺刀路完毕, 用时 ', num2str(handles.smoothpath.caltime), 's。 下一步进行速度规划'];
	set(handles.notification_text, 'string', handles.noticestring);
 %   set(handles.pathsmoothingnotice_text, 'string', [noticestring, '光顺刀路完毕, 用时 ', num2str(handles.smoothpath.caltime), 's']); 
    set(handles.feedrateschedulenotification_text, 'string', feedrateschedulingnoticestring);
	handles.step = 3;
catch exception
    % 提示出错
    msgbox(exception.message, '计算出错');
	set(handles.notification_text, 'string', '刀路光顺计算出错，请重新选择光顺方法和设定参数！');
    % set(handles.pathsmoothingnotice_text, 'string', '计算出错！'); 
%     rethrow(exception);
end



guidata(hObject,handles);   % 更新数据

% --- Executes on button press in showlinearpath_pushbutton.
function showlinearpath_pushbutton_Callback(hObject, eventdata, handles)

% 显示线性刀具路径
noticestr = get(handles.pathsmoothingnotice_text, 'string');
set(handles.pathsmoothingnotice_text, 'string', '计算中，请稍等...');

tip = handles.linearpath.data(:, 1:3);
rp = tip + 10 * handles.linearpath.data(:, 4:6);

figure('units','normalized','position',[0.1,0.1,0.5,0.5]);

plot3(tip(:, 1), tip(:, 2), tip(:, 3));
hold on;
plot3(rp(:, 1), rp(:, 2), rp(:, 3));
set(gca, 'fontsize', 20, 'fontname', '微软雅黑');
title('线性刀具路径');

set(handles.pathsmoothingnotice_text, 'string', '线性刀路显示完毕');
guidata(hObject,handles);   % 更新数据

% --- Executes on button press in showsplinepath_pushbutton.
function showsplinepath_pushbutton_Callback(hObject, eventdata, handles)

noticestr = get(handles.pathsmoothingnotice_text, 'string');
set(handles.pathsmoothingnotice_text, 'string', '计算中，请稍等...');
drawnow expose       
if handles.smoothpath.method == 1 || handles.smoothpath.method == 2
    %% 特征点选择的对偶四元数逼近方法或对偶四元数插值方法
    du = 0.001;
    tip2 = handles.smoothpath.dualquatpath.tip0 + 10 * handles.smoothpath.dualquatpath.vector0;
    i = 1;
    for u = 0:du:1
        DeBoorP = DeBoorCoxNurbsCal(u, handles.smoothpath.dualquatpath.dualquatspline, 0);	% 计算德布尔点以及一二阶导矢
        curvepr(i, :) = TransformViaQ(tip2, DeBoorP(1, :));
        curvept(i, :) = TransformViaQ(handles.smoothpath.dualquatpath.tip0, DeBoorP(1, :));
        i = i + 1;
    end
    figure('units','normalized','position',[0.1,0.1,0.5,0.5]);
    plot3(curvept(:, 1), curvept(:, 2), curvept(:, 3));
    hold on;
    plot3(curvepr(:, 1), curvepr(:, 2), curvepr(:, 3));
    title('拟合后的刀具路径');
    set(gca, 'fontsize', 20, 'fontname', '微软雅黑');
    
    
elseif handles.smoothpath.method == 3
    %% 四样条插值方法
	slindex = 1;
	swindex = 1;
	pnum = 1;
    for s = 0:0.1:handles.smoothpath.foursplineinterpath.orientationreparam.LW(end, 1)
		% 先找到s所在的区间段
		if s > handles.smoothpath.foursplineinterpath.feedcorrectionspline.startl(slindex)...
				+ handles.smoothpath.foursplineinterpath.feedcorrectionspline.sublength(slindex)
			slindex = slindex + 1;
		end
		u = CaculateuWhithl(s,...
				handles.smoothpath.foursplineinterpath.feedcorrectionspline.A(slindex, :),...
				handles.smoothpath.foursplineinterpath.feedcorrectionspline.startl(slindex),...
				handles.smoothpath.foursplineinterpath.feedcorrectionspline.sublength(slindex));
		
		% 求刀尖点坐标
		curvept(pnum, :) = DeBoorCoxNurbsCal(u, handles.smoothpath.foursplineinterpath.tipspline, 0);
		
		if s > handles.smoothpath.foursplineinterpath.orientationreparam.LW(swindex + 1, 1)
			swindex = swindex + 1;
		end
		
		% 求对应的刀轴矢量参数w
		r = (s - handles.smoothpath.foursplineinterpath.orientationreparam.LW(swindex, 1))...
		/ (handles.smoothpath.foursplineinterpath.orientationreparam.LW(swindex + 1, 1)...
		- handles.smoothpath.foursplineinterpath.orientationreparam.LW(swindex, 1));
		
		w = 0;
		for i = 0:1:7
			w = w + factorial(7) / factorial(i) / factorial(7 - i) * (1 - r)^(7 - i) * r^i *...
			handles.smoothpath.foursplineinterpath.orientationreparam.WQ(8 * (swindex - 1) + 1 + i);
        end
		
		orien = DeBoorCoxNurbsCal(w, handles.smoothpath.foursplineinterpath.orientationspline, 0);
		
		I = sin(orien(1)) * cos(orien(2));
		J = sin(orien(1)) * sin(orien(2));
		K = cos(orien(1));
		
		curvepr(pnum, :) = curvept(pnum, :) + 10 * [I J K];
		
		pnum = pnum + 1;
    end
    figure('units','normalized','position',[0.1,0.1,0.5,0.5]);
    plot3(curvept(:, 1), curvept(:, 2), curvept(:, 3));
    hold on;
    plot3(curvepr(:, 1), curvepr(:, 2), curvepr(:, 3));
    title('拟合后的刀具路径');
    set(gca, 'fontsize', 20, 'fontname', '微软雅黑');
    
elseif handles.smoothpath.method == 4
    %% 三样条插值方法
    L = handles.smoothpath.threesplineinterppath.tipspline.L;
    C = handles.smoothpath.threesplineinterppath.tipspline.C;
    
    V = handles.smoothpath.threesplineinterppath.orientationspline.V;
    D = handles.smoothpath.threesplineinterppath.orientationspline.D;
    
    u = handles.smoothpath.threesplineinterppath.reparam.u;
    h = handles.smoothpath.threesplineinterppath.reparam.h;
    
    ds = 0.1;
    pnum = 1;
    %     for u = 0:0.01:L(i)
%         quinticSplineP(quiNum, :) = C(1, :, i) + C(2, :, i) * u + C(3, :, i) * u^2 + C(4, :, i) * u^3 + C(5, :, i) * u^4 + C(6, :, i) * u^5;
%         quiNum = quiNum + 1;
%     end

    lacc = zeros(1, length(L) + 1);
%     dacc = zeros(1, length(L));
    for i = 1:length(L)
        lacc(i + 1) = lacc(i) + L(i);
        dacc(i) = sum(D(1:i));
        for s = 0:ds:L(i)
            curvept(pnum, :) = C(1, :, i) + C(2, :, i) * s + C(3, :, i) * s^2 + C(4, :, i) * s^3 + C(5, :, i) * s^4 + C(6, :, i) * s^5;
            v = (u(i + 1) * s^2 + L(i) / D(i) * (u(i + 1) * h(i) + u(i) * h(i + 1)) * s * (L(i) - s) + u(i) * (L(i) - s)^2) / (s^2 + L(i) / D(i) * (h(i) + h(i + 1)) * s * (L(i) - s) + (L(i) - s)^2) - u(i);
            tvector(pnum, :) = QuinticSphericalBezier(V(1, :, i), V(2, :, i), V(3, :, i), V(4, :, i) , V(5, :, i), V(6, :, i), D(i), v);
            
            curvepr(pnum, :) = curvept(pnum, :) + 10 * tvector(pnum, :);
            pnum = pnum + 1;
        end
    end
    

    figure('units','normalized','position',[0.1,0.1,0.5,0.5]);
    plot3(curvept(:, 1), curvept(:, 2), curvept(:, 3));
    hold on;
    plot3(curvepr(:, 1), curvepr(:, 2), curvepr(:, 3), 'r');
    
elseif handles.smoothpath.method == 5
    %% 双样条插值方法
    du = 0.001;
    i = 1;
    for u = 0:du:1
        DeBoorP = DeBoorCoxNurbsCal(u, handles.smoothpath.dualsplinepath.pathspline, 0);	% 计算德布尔点以及一二阶导矢
        curvept(i, :) = DeBoorP(1:3);
        curvepr(i, :) = DeBoorP(4:6);
        i = i + 1;
    end
    
    figure('units','normalized','position',[0.1,0.1,0.5,0.5]);
    plot3(curvept(:, 1), curvept(:, 2), curvept(:, 3));
    hold on;
    plot3(curvepr(:, 1), curvepr(:, 2), curvepr(:, 3), 'r');
end


set(handles.pathsmoothingnotice_text, 'string', '拟合后的刀路显示完毕');
guidata(hObject,handles);   % 更新数据

% --- Executes on button press in showlinearandsplinepath_pushbutton.
function showlinearandsplinepath_pushbutton_Callback(hObject, eventdata, handles)

noticestr = get(handles.pathsmoothingnotice_text, 'string');
set(handles.pathsmoothingnotice_text, 'string', '计算中，请稍等...');
drawnow expose       

tip = handles.linearpath.data(:, 1:3);
rp = tip + 10 * handles.linearpath.data(:, 4:6);

if handles.smoothpath.method == 1 | handles.smoothpath.method == 2
    %% 特征点选择的对偶四元数逼近方法或对偶四元数插值方法
    du = 0.001;
    tip2 = handles.smoothpath.dualquatpath.tip0 + 10 * handles.smoothpath.dualquatpath.vector0;
    i = 1;
    for u = 0:du:1
        DeBoorP = DeBoorCoxNurbsCal(u, handles.smoothpath.dualquatpath.dualquatspline, 0);	% 计算德布尔点以及一二阶导矢
        curvepr(i, :) = TransformViaQ(tip2, DeBoorP(1, :));
        curvept(i, :) = TransformViaQ(handles.smoothpath.dualquatpath.tip0, DeBoorP(1, :));
        i = i + 1;
    end
    figure('units','normalized','position',[0.1,0.1,0.5,0.5]);
    plot3(curvept(:, 1), curvept(:, 2), curvept(:, 3));
    hold on;
    plot3(curvepr(:, 1), curvepr(:, 2), curvepr(:, 3));

    
    
elseif handles.smoothpath.method == 3
    %% 四样条插值方法
	slindex = 1;
	swindex = 1;
	pnum = 1;
    ds = 0.01;
    for s = 0:ds:handles.smoothpath.foursplineinterpath.orientationreparam.LW(end, 1)
		% 先找到s所在的区间段
		if s > handles.smoothpath.foursplineinterpath.feedcorrectionspline.startl(slindex)...
				+ handles.smoothpath.foursplineinterpath.feedcorrectionspline.sublength(slindex)
			slindex = slindex + 1;
		end
		u = CaculateuWhithl(s,...
				handles.smoothpath.foursplineinterpath.feedcorrectionspline.A(slindex, :),...
				handles.smoothpath.foursplineinterpath.feedcorrectionspline.startl(slindex),...
				handles.smoothpath.foursplineinterpath.feedcorrectionspline.sublength(slindex));
		if u < 0
            u = 0;
        end
        
        if u > 1
            u = 1;
        end
        
		% 求刀尖点坐标
		curvept(pnum, :) = DeBoorCoxNurbsCal(u, handles.smoothpath.foursplineinterpath.tipspline, 0);
		
		if s > handles.smoothpath.foursplineinterpath.orientationreparam.LW(swindex + 1, 1)
			swindex = swindex + 1;
		end
		
		% 求对应的刀轴矢量参数w
		r = (s - handles.smoothpath.foursplineinterpath.orientationreparam.LW(swindex, 1))...
		/ (handles.smoothpath.foursplineinterpath.orientationreparam.LW(swindex + 1, 1)...
		- handles.smoothpath.foursplineinterpath.orientationreparam.LW(swindex, 1));
		
		w = 0;
		for i = 0:1:7
			w = w + factorial(7) / factorial(i) / factorial(7 - i) * (1 - r)^(7 - i) * r^i *...
			handles.smoothpath.foursplineinterpath.orientationreparam.WQ(8 * (swindex - 1) + 1 + i);
        end
        
        if w < 0
            w = 0;
        end
        if w > 1
            w = 1;
        end
        
		orien = DeBoorCoxNurbsCal(w, handles.smoothpath.foursplineinterpath.orientationspline, 0);
		
		I = sin(orien(1)) * cos(orien(2));
		J = sin(orien(1)) * sin(orien(2));
		K = cos(orien(1));
		
		curvepr(pnum, :) = curvept(pnum, :) + 10 * [I J K];
		
		pnum = pnum + 1;
    end
    figure('units','normalized','position',[0.1,0.1,0.5,0.5]);
    plot3(curvept(:, 1), curvept(:, 2), curvept(:, 3));
    hold on;
    plot3(curvepr(:, 1), curvepr(:, 2), curvepr(:, 3));
    title('拟合后的刀具路径');
    set(gca, 'fontsize', 20, 'fontname', '微软雅黑');
    
elseif handles.smoothpath.method == 4
    %% 三样条插值方法
    L = handles.smoothpath.threesplineinterppath.tipspline.L;
    C = handles.smoothpath.threesplineinterppath.tipspline.C;
    
    V = handles.smoothpath.threesplineinterppath.orientationspline.V;
    D = handles.smoothpath.threesplineinterppath.orientationspline.D;
    
    u = handles.smoothpath.threesplineinterppath.reparam.u;
    h = handles.smoothpath.threesplineinterppath.reparam.h;
    
    ds = 0.1;
    pnum = 1;
    %     for u = 0:0.01:L(i)
%         quinticSplineP(quiNum, :) = C(1, :, i) + C(2, :, i) * u + C(3, :, i) * u^2 + C(4, :, i) * u^3 + C(5, :, i) * u^4 + C(6, :, i) * u^5;
%         quiNum = quiNum + 1;
%     end

    lacc = zeros(1, length(L) + 1);
%     dacc = zeros(1, length(L));
    for i = 1:length(L)
        lacc(i + 1) = lacc(i) + L(i);
        dacc(i) = sum(D(1:i));
        for s = 0:ds:L(i)
            su = s / (L(i));
            curvept(pnum, :) = C(1, :, i) + C(2, :, i) * s + C(3, :, i) * s^2 + C(4, :, i) * s^3 + C(5, :, i) * s^4 + C(6, :, i) * s^5;
            v = (u(i + 1) * s^2 + L(i) / D(i) * (u(i + 1) * h(i) + u(i) * h(i + 1)) * s * (L(i) - s) + u(i) * (L(i) - s)^2) / (s^2 + L(i) / D(i) * (h(i) + h(i + 1)) * s * (L(i) - s) + (L(i) - s)^2) - u(i);
            tvector(pnum, :) = QuinticSphericalBezier(V(1, :, i), V(2, :, i), V(3, :, i), V(4, :, i) , V(5, :, i), V(6, :, i), D(i), v);
            
            curvepr(pnum, :) = curvept(pnum, :) + 10 * tvector(pnum, :);
            
            sarray(pnum) = lacc(i) + s;
            varray(pnum) = u(i) + v;
            pnum = pnum + 1;
        end
    end
    


    figure('units','normalized','position',[0.1,0.1,0.5,0.5]);
    plot3(curvept(:, 1), curvept(:, 2), curvept(:, 3));
    hold on;
    plot3(curvepr(:, 1), curvepr(:, 2), curvepr(:, 3));
    
elseif handles.smoothpath.method == 5
    %% 双样条插值方法
    du = 0.001;
    i = 1;
    for u = 0:du:1
        DeBoorP = DeBoorCoxNurbsCal(u, handles.smoothpath.dualsplinepath.pathspline, 0);	% 计算德布尔点以及一二阶导矢
        curvept(i, :) = DeBoorP(1:3);
        curvepr(i, :) = DeBoorP(4:6);
        i = i + 1;
    end
    
    figure('units','normalized','position',[0.1,0.1,0.5,0.5]);
    plot3(curvept(:, 1), curvept(:, 2), curvept(:, 3));
    hold on;
    plot3(curvepr(:, 1), curvepr(:, 2), curvepr(:, 3));
end
title('拟合后的刀具路径和线性刀具路径');
set(gca, 'fontsize', 20, 'fontname', '微软雅黑');
plot3(tip(:, 1), tip(:, 2), tip(:, 3), 'r');
plot3(rp(:, 1), rp(:, 2), rp(:, 3), 'r');

set(handles.pathsmoothingnotice_text, 'string', '线性刀路和拟合后的刀路显示完毕');
guidata(hObject,handles);   % 更新数据

% --- Executes on button press in showcurvature_pushbutton.
function showcurvature_pushbutton_Callback(hObject, eventdata, handles)

set(handles.pathsmoothingnotice_text, 'string', '计算中，请稍等...');
drawnow expose       
i = 1;
if handles.smoothpath.method == 1 || handles.smoothpath.method == 2
    %% 特征点选择的对偶四元数逼近方法和对偶四元数插值方法
    du = 0.001;
    
    for u = 0:du:1
        DeBoorP = DeBoorCoxNurbsCal(u, handles.smoothpath.dualquatpath.dualquatspline, 2);	% 计算德布尔点以及一二阶导矢
        [der1, der2] = DerCalFromQ(handles.smoothpath.dualquatpath.tip0, DeBoorP(2, :), DeBoorP(3, :), DeBoorP(1, :));    % 求一二阶导矢
        curvatureNurbs(i) = norm(cross(der1, der2)) / norm(der1)^3;                        % 根据曲率公式求曲率
        i = i + 1;
    end
    
elseif handles.smoothpath.method == 3
    %% 四样条插值方法
    pNum = 1;
    du = 0.001;
    for u = 0:du:1
        DeBoorP = DeBoorCoxNurbsCal(u, handles.smoothpath.foursplineinterpath.tipspline, 2);
        curvatureNurbs(pNum) = norm(cross(DeBoorP(2, :), DeBoorP(3, :))) / norm(DeBoorP(2, :))^3;
        pNum = pNum + 1;
    end
    
elseif handles.smoothpath.method == 4
    %% 三样条插值方法
    curvatureNurbs = caculateCurvature(handles.smoothpath.threesplineinterppath.tipspline.L, handles.smoothpath.threesplineinterppath.tipspline.C);
    
elseif handles.smoothpath.method == 5
    %% 双样条插值方法
    du = 0.001;
    pNum = 1;
    for u = 0:du:1
        DeBoorP = DeBoorCoxNurbsCal(u, handles.smoothpath.dualsplinepath.pathspline, 2);	% 计算德布尔点以及一二阶导矢
        curvatureNurbs(pNum) = norm(cross(DeBoorP(2, 1:3), DeBoorP(3, 1:3))) / norm(DeBoorP(2, 1:3))^3;
        pNum = pNum + 1;
    end
  
end
figure('units','normalized','position',[0.1,0.1,0.5,0.5]);
plot(curvatureNurbs);
title('刀尖点曲率', 'fontsize', 20);
set(gca, 'fontsize', 20, 'fontname', '微软雅黑');
set(handles.pathsmoothingnotice_text, 'string', '刀尖点曲率显示完毕');
guidata(hObject,handles);   % 更新数据

% --- Executes on button press in showfittingerror_pushbutton.
function showfittingerror_pushbutton_Callback(hObject, eventdata, handles)


% 绘制拟合误差
fontsize = 20;

figure('units','normalized','position',[0.05,0.1,0.9,0.7]);
subplot(1,2,1);
plot(handles.smoothpath.dualquatpath.errtip);  % 绘制刀尖点的拟合误差
title('tool tip error(mm)','fontsize',fontsize);
set(gca, 'fontsize', fontsize);
subplot(1,2,2);
plot(handles.smoothpath.dualquatpath.errorie);  % 绘制刀尖点的拟合误差
title('tool orientation error (°)','fontsize',fontsize)
set(gca, 'fontsize', fontsize);

% --- Executes on button press in showothers_pushbutton.
function showothers_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to showothers_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.pathsmoothingnotice_text, 'string', '计算中，请稍等...');
drawnow expose       

if handles.smoothpath.method == 1 || handles.smoothpath.method == 2
    %% 分别绘制刀尖点轨迹和刀轴矢量
    du = 0.001;
    i = 1;
    v0dual = [0 handles.smoothpath.dualquatpath.vector0];
    for u = 0:du:1
        DeBoorP = DeBoorCoxNurbsCal(u, handles.smoothpath.dualquatpath.dualquatspline, 0);	% 计算德布尔点以及一二阶导矢
        curvepr(i, :) = TransformViaQ(handles.smoothpath.dualquatpath.tip0, DeBoorP(1, :));
        vectorarr(i, :) = quatmultiply(quatmultiply(DeBoorP(1, 1:4), v0dual), quatconj(DeBoorP(1, 1:4)));
        i = i + 1;
    end
    
    % 绘制刀尖点曲线
    figure('units','normalized','position',[0.05,0.1,0.9,0.7]);
    subplot(1,2,1);
    plot3(curvepr(:, 1), curvepr(:, 2), curvepr(:, 3));
    set(gca, 'fontsize', 20);
    hold on;
    plot3(handles.linearpath.data(:, 1), handles.linearpath.data(:, 2), handles.linearpath.data(:, 3), '*');    % 绘制处拟合前的离散点
    
    % 绘制刀轴矢量曲线
    subplot(1,2,2);
    plot3(vectorarr(:, 2), vectorarr(:, 3), vectorarr(:, 4));
    set(gca, 'fontsize', 20);
    hold on;
    [x, y, z] = sphere;
    mesh(x, y, z);      % 绘制出球面网格
    plot3(handles.linearpath.data(:, 4), handles.linearpath.data(:, 5), handles.linearpath.data(:, 6), '*');    % 绘制拟合前的离散点
    set(handles.pathsmoothingnotice_text, 'string', '刀尖和刀轴矢量轨迹绘制完毕');
    
elseif handles.smoothpath.method == 3
    %% 如果是四样条曲线插值算法，绘制四条曲线
    slindex = 1;
	swindex = 1;
    ds = 0.01;
    pnum = 1;
    for s = 0:ds:handles.smoothpath.foursplineinterpath.orientationreparam.LW(end, 1)
		% 先找到s所在的区间段
		if s > handles.smoothpath.foursplineinterpath.feedcorrectionspline.startl(slindex)...
				+ handles.smoothpath.foursplineinterpath.feedcorrectionspline.sublength(slindex)
			slindex = slindex + 1;
		end
		uarray(pnum) = CaculateuWhithl(s,...
				handles.smoothpath.foursplineinterpath.feedcorrectionspline.A(slindex, :),...
				handles.smoothpath.foursplineinterpath.feedcorrectionspline.startl(slindex),...
				handles.smoothpath.foursplineinterpath.feedcorrectionspline.sublength(slindex));
		
		if s > handles.smoothpath.foursplineinterpath.orientationreparam.LW(swindex + 1, 1)
			swindex = swindex + 1;
		end
		
		% 求对应的刀轴矢量参数w
		r = (s - handles.smoothpath.foursplineinterpath.orientationreparam.LW(swindex, 1))...
		/ (handles.smoothpath.foursplineinterpath.orientationreparam.LW(swindex + 1, 1)...
		- handles.smoothpath.foursplineinterpath.orientationreparam.LW(swindex, 1));
		
		warray(pnum) = 0;
		for i = 0:1:7
			warray(pnum) = warray(pnum) + factorial(7) / factorial(i) / factorial(7 - i) * (1 - r)^(7 - i) * r^i *...
			handles.smoothpath.foursplineinterpath.orientationreparam.WQ(8 * (swindex - 1) + 1 + i);
        end
        pnum = pnum + 1;
    end
    
    pnum = 1;
    du = 0.001;
    for u = 0:du:1
        % 求刀尖点坐标
        curvept(pnum, :) = DeBoorCoxNurbsCal(u, handles.smoothpath.foursplineinterpath.tipspline, 0);
        orien = DeBoorCoxNurbsCal(u, handles.smoothpath.foursplineinterpath.orientationspline, 0);
        I = sin(orien(1)) * cos(orien(2));
		J = sin(orien(1)) * sin(orien(2));
		K = cos(orien(1));
        tvector(pnum, :) = [I, J, K];
        
        pnum = pnum + 1;
    end
    s = 0:ds:handles.smoothpath.foursplineinterpath.orientationreparam.LW(end, 1);
    
    % 绘制刀尖点轨迹曲线
    figure('units','normalized','position',[0.05,0.1,0.9,0.8]);
    subplot(2, 2, 1);
    plot3(curvept(:, 1), curvept(:, 2), curvept(:, 3));
    hold on;
    plot3(handles.linearpath.data(:, 1), handles.linearpath.data(:, 2), handles.linearpath.data(:, 3), '*');    % 绘制处拟合前的离散点
    
    % 绘制刀轴矢量球面曲线
    subplot(2, 2, 2);
    plot3(tvector(:, 1), tvector(:, 2), tvector(:, 3));
    hold on;
    [x, y, z] = sphere;
    mesh(x, y, z);      % 绘制出球面网格
    plot3(handles.linearpath.data(:, 4), handles.linearpath.data(:, 5), handles.linearpath.data(:, 6), '*');    % 绘制拟合前的离散点
    
    % 绘制l-u曲线
    subplot(2, 2, 3);
    plot(s, uarray);
    title('l-u曲线');
    
    % 绘制l-w曲线
    subplot(2, 2, 4);
    plot(s, warray);
    title('l-w曲线');
    
    set(handles.pathsmoothingnotice_text, 'string', '刀尖、刀轴矢量轨迹、l-u曲线和l-w曲线绘制完毕');
    
elseif handles.smoothpath.method == 4
    %% 如果是三样条曲线插值算法，绘制三条曲线
        %% 三样条插值方法
    L = handles.smoothpath.threesplineinterppath.tipspline.L;
    C = handles.smoothpath.threesplineinterppath.tipspline.C;
    
    V = handles.smoothpath.threesplineinterppath.orientationspline.V;
    D = handles.smoothpath.threesplineinterppath.orientationspline.D;
    
    u = handles.smoothpath.threesplineinterppath.reparam.u;
    h = handles.smoothpath.threesplineinterppath.reparam.h;
    
    ds = 0.1;
    pnum = 1;
    %     for u = 0:0.01:L(i)
%         quinticSplineP(quiNum, :) = C(1, :, i) + C(2, :, i) * u + C(3, :, i) * u^2 + C(4, :, i) * u^3 + C(5, :, i) * u^4 + C(6, :, i) * u^5;
%         quiNum = quiNum + 1;
%     end

    lacc = zeros(1, length(L) + 1);
%     dacc = zeros(1, length(L));
    for i = 1:length(L)
        lacc(i + 1) = lacc(i) + L(i);
        dacc(i) = sum(D(1:i));
        for s = 0:ds:L(i)
            su = s / (L(i));
            curvept(pnum, :) = C(1, :, i) + C(2, :, i) * s + C(3, :, i) * s^2 + C(4, :, i) * s^3 + C(5, :, i) * s^4 + C(6, :, i) * s^5;
            v = (u(i + 1) * s^2 + L(i) / D(i) * (u(i + 1) * h(i) + u(i) * h(i + 1)) * s * (L(i) - s) + u(i) * (L(i) - s)^2) / (s^2 + L(i) / D(i) * (h(i) + h(i + 1)) * s * (L(i) - s) + (L(i) - s)^2) - u(i);
            tvector(pnum, :) = QuinticSphericalBezier(V(1, :, i), V(2, :, i), V(3, :, i), V(4, :, i) , V(5, :, i), V(6, :, i), D(i), v);
            
            curvepr(pnum, :) = curvept(pnum, :) + 10 * tvector(pnum, :);
            
            sarray(pnum) = lacc(i) + s;
            varray(pnum) = u(i) + v;
            pnum = pnum + 1;
        end
    end
    
    tip = handles.linearpath.data(:, 1:3);

    figure('units','normalized','position',[0.1,0.1,0.9,0.7]);
    subplot(2, 2, 1);
    plot3(curvept(:, 1), curvept(:, 2), curvept(:, 3));
    hold on;
    plot3(tip(:, 1), tip(:, 2), tip(:, 3), 'r');
%     plot3(tip(:, 1), tip(:, 2), tip(:, 3), '*');
    title('刀尖点曲线');
    
    subplot(2, 2, 2);
    plot3(tvector(:, 1), tvector(:, 2), tvector(:, 3));
    hold on;
    [x, y, z] = sphere;
    mesh(x, y, z);      % 绘制出球面网格
    plot3(handles.linearpath.data(:, 4), handles.linearpath.data(:, 5), handles.linearpath.data(:, 6), 'r');
%     plot3(handles.linearpath.data(:, 4), handles.linearpath.data(:, 5), handles.linearpath.data(:, 6), '*');
    title('刀轴矢量曲线');
    
    subplot(2, 1, 2);
    plot(sarray, varray);
    hold on;
    plot(lacc, u, 'r');
    title('参数同步曲线');
    
%     xcc = 50;
%     ycc = 50;
%     width = 400;
%     height= 300;
%     
%     figure('Position',[xcc, ycc, width, height]);
%     plot3(curvept(:, 1), curvept(:, 2), curvept(:, 3), 'linewidth', 1.5);
%     set(gca, 'fontsize', 15);
%     xlabel('X');
%     ylabel('Y');
%     zlabel('Z');
%     
%     figure('Position',[xcc, ycc, width, height]);
%     plot3(tvector(:, 1), tvector(:, 2), tvector(:, 3), 'linewidth', 3);
%     hold on;
%     [x, y, z] = sphere;
%     c = ones(size(x, 1), size(x, 2));
%     a = c * 0.8;
%     h = mesh(x, y, z);      % 绘制出球面网格
%     set(h,'EdgeColor','k','MarkerEdgecolor','r','MarkerFacecolor','r')
%     set(gca, 'fontsize', 15);
%     
%     figure('Position',[xcc, ycc, width + 100, height]);
%     plot(sarray, varray, 'linewidth', 3);
%     set(gca, 'fontsize', 15);
%     xlabel('l');
%     ylabel('u');
    
    
elseif handles.smoothpath.method == 5
    du = 0.001;
    pnum = 1;
    for u = 0:du:1
        DeBoorP = DeBoorCoxNurbsCal(u, handles.smoothpath.dualsplinepath.pathspline, 1);	% 计算德布尔点以及一二阶导矢
        lengtherror(pnum) = norm(DeBoorP(1, 1:3) - DeBoorP(1, 4:6)) - handles.smoothpath.dualsplinepath.toollength;
        pnum = pnum + 1;
    end
    figure('units','normalized','position',[0.1,0.1,0.6,0.5]);
    plot(lengtherror);
end


% --- Executes on button press in savesmoothpath_pushbutton.
function savesmoothpath_pushbutton_Callback(hObject, eventdata, handles)

noticestr = get(handles.pathsmoothingnotice_text, 'string');
set(handles.pathsmoothingnotice_text, 'string', '计算中，请稍等...');
drawnow expose       

% 先判断文件夹寸存不存在，如果不存在则创建文件夹
dirc = ['..\Data\Output\' datestr(now, 29) ];
if exist([dirc '\smoothpath'], 'dir') == 0
    mkdir(dirc, 'smoothpath');
end

if handles.smoothpath.method == 1 || handles.smoothpath.method == 2
%% 特征点选择的对偶四元数逼近方法和对偶四元数插值方法    
    
    % 查找当前存在的文件，添加编号使文件不重名
    fnum = 1;
    fdir = [dirc '\smoothpath\dualquatappropath' datestr(now, 29) '-' num2str(fnum, 0) '.txt'];
    while(exist(fdir, 'file') ~= 0)
        fnum = fnum + 1;
        fdir = [dirc '\smoothpath\dualquatappropath' datestr(now, 29) '-' num2str(fnum, 0) '.txt'];
    end
    
    % 弹出对话框，选择保存的目录和文件名
    [filename, pahtname, filerindex] = uiputfile({'*.txt'}, '保存光顺后的路径文件',  fdir);
   
    
    try
        % 创建文件
        wfile = fopen([pahtname filename], 'w+');
    catch err
        % 失败则抛出初五错误消息
        if pahtname ~= 0
            h = msgbox(err.message, '保存失败');
            ah = get( h, 'CurrentAxes' );  
            ch = get( ah, 'Children' );  
            set( ch, 'fontname', '微软雅黑'); 
        end
        return;
    end
    
    % 保存初始点
    fprintf(wfile, '初始点坐标: [%f %f %f]\n\n', handles.smoothpath.dualquatpath.tip0(1), handles.smoothpath.dualquatpath.tip0(2), handles.smoothpath.dualquatpath.tip0(3));
    % 保存初始向量
    fprintf(wfile, '初始向量: [%f %f %f]\n\n', handles.smoothpath.dualquatpath.vector0(1), handles.smoothpath.dualquatpath.vector0(2), handles.smoothpath.dualquatpath.vector0(3));
    % 保存样条阶数
    fprintf(wfile, '样条阶数： %2.0f\n\n', handles.smoothpath.dualquatpath.dualquatspline.splineorder);
    
    % 保存节点向量
    fprintf(wfile, '节点向量\n U = [');
    for i = 1:length(handles.smoothpath.dualquatpath.dualquatspline.knotvector)
        fprintf(wfile, '%f, ', handles.smoothpath.dualquatpath.dualquatspline.knotvector(i));
        if mod(i, 10) == 0
            fprintf(wfile, '...\n');
        end
    end
    fprintf(wfile, '];\n\n');
    
    % 保存控制对偶四元数
    fprintf(wfile, '控制对偶四元数\n CQ = [ ... \n');
    for i = 1:size(handles.smoothpath.dualquatpath.dualquatspline.controlp, 1)
        for j = 1:size(handles.smoothpath.dualquatpath.dualquatspline.controlp, 2)
            fprintf(wfile, '%f ', handles.smoothpath.dualquatpath.dualquatspline.controlp(i, j));
        end
        fprintf(wfile, '\n');
    end
    fprintf(wfile, '];\n');
    
    fclose(wfile);
    msgbox(['光顺后的路径文件保存在' pahtname filename], '光顺后的路径文件保存成功');

elseif handles.smoothpath.method == 3
%% 四样条插值方法      
    
    % 查找当前存在的文件，添加编号使文件不重名
    fnum = 1;
    fdir = [dirc '\smoothpath\foursplineinterp' datestr(now, 29) '-' num2str(fnum, 0) '.txt'];
    while(exist(fdir, 'file') ~= 0)
        fnum = fnum + 1;
        fdir = [dirc '\smoothpath\foursplineinterp' datestr(now, 29) '-' num2str(fnum, 0) '.txt'];
    end
    
    % 弹出对话框，选择保存的目录和文件名
    [filename, pahtname, filerindex] = uiputfile({'*.txt'}, '保存光顺后的路径文件',  fdir);
    
    try
        % 创建文件
        wfile = fopen([pahtname filename], 'w+');
    catch err
        % 失败则抛出初五错误消息
        if pahtname ~= 0
            h = msgbox(err.message, '保存失败');
            ah = get( h, 'CurrentAxes' );  
            ch = get( ah, 'Children' );  
            set( ch, 'fontname', '微软雅黑'); 
        end
        return;
    end
    
    % 写入内容
    fprintf(wfile, '\n\n----------------------刀尖点曲线--------------------------\n\n');
    fprintf(wfile, '样条阶数: %2.0f \n\n', handles.smoothpath.foursplineinterpath.tipspline.splineorder);
    % 保存节点向量
    fprintf(wfile, '节点向量\n U = [');
    for i = 1:length(handles.smoothpath.foursplineinterpath.tipspline.knotvector)
        fprintf(wfile, '%f, ', handles.smoothpath.foursplineinterpath.tipspline.knotvector(i));
        if mod(i, 10) == 0
            fprintf(wfile, '...\n');
        end
    end
    fprintf(wfile, '];\n\n');
    
    % 保存控制点
    fprintf(wfile, '控制顶点\n Q = [ ... \n');
    for i = 1:size(handles.smoothpath.foursplineinterpath.tipspline.controlp)
        for j = 1:3
            fprintf(wfile, '%f ', handles.smoothpath.foursplineinterpath.tipspline.controlp(i, j));
        end
        fprintf(wfile, '\n');
    end
    fprintf(wfile, '];\n\n');
    
    fprintf(wfile, '\n\n----------------------刀尖l-u曲线参数--------------------------\n\n');
    fprintf(wfile, '弧长分段点：\n');
    for i = 1:length(handles.smoothpath.foursplineinterpath.feedcorrectionspline.startl)
        fprintf(wfile, '%f ', handles.smoothpath.foursplineinterpath.feedcorrectionspline.startl(i));
    end
    fprintf(wfile, '%f\n\n', handles.smoothpath.foursplineinterpath.orientationreparam.LW(end, 1));
    fprintf(wfile, '多项式系数：\n');
    
    for i = 1:size(handles.smoothpath.foursplineinterpath.feedcorrectionspline.A, 1)
        for j = 1:size(handles.smoothpath.foursplineinterpath.feedcorrectionspline.A, 2)
            fprintf(wfile, '%f ', handles.smoothpath.foursplineinterpath.feedcorrectionspline.A(i, j));
        end
        fprintf(wfile, '\n');
    end
    
    fprintf(wfile, '\n\n----------------------轴矢量曲线--------------------------\n\n');
    fprintf(wfile, '样条阶数: %2.0f \n\n', handles.smoothpath.foursplineinterpath.orientationspline.splineorder);
    % 保存节点向量
    fprintf(wfile, '节点向量\n U = [');
    for i = 1:length(handles.smoothpath.foursplineinterpath.orientationspline.knotvector)
        fprintf(wfile, '%f, ', handles.smoothpath.foursplineinterpath.orientationspline.knotvector(i));
        if mod(i, 10) == 0
            fprintf(wfile, '...\n');
        end
    end
    fprintf(wfile, '];\n\n');
    
    % 保存控制点
    fprintf(wfile, '控制顶点\n Q = [ ... \n');
    for i = 1:size(handles.smoothpath.foursplineinterpath.orientationspline.controlp)
        for j = 1:2
            fprintf(wfile, '%f ', handles.smoothpath.foursplineinterpath.orientationspline.controlp(i, j));
        end
        fprintf(wfile, '\n');
    end
    fprintf(wfile, '];\n\n');
    
    fprintf(wfile, '\n\n----------------------轴矢量l-w曲线参数--------------------------\n\n');
    fprintf(wfile, '分段点：\n');
    for i = 1:size(handles.smoothpath.foursplineinterpath.orientationreparam.LW, 1)
        fprintf(wfile, '%f ', handles.smoothpath.foursplineinterpath.orientationreparam.LW(i, 1));
        if mod(i, 10) == 0
            fprintf(wfile, '...\n');
        end
    end
    
    fprintf(wfile, '\n\n多项式系数：\n');
    for i = 1:size(handles.smoothpath.foursplineinterpath.orientationreparam.WQ, 1) / 8
        for j = 1:8
            fprintf(wfile, '%f ', handles.smoothpath.foursplineinterpath.orientationreparam.WQ(8 * (i - 1) + j));
        end
        fprintf(wfile, '...\n');
    end
    
    
    % 关闭文件并提示
    fclose(wfile);
    h = msgbox(['光顺后的路径文件保存在' pahtname filename], '光顺后的路径文件保存成功');
    ah = get( h, 'CurrentAxes' );  
    ch = get( ah, 'Children' );  
    set( ch, 'fontname', '微软雅黑'); 
    
    
elseif handles.smoothpath.method == 4
    %% 三样条插值方法
    % 查找当前存在的文件，添加编号使文件不重名
    fnum = 1;
    fdir = [dirc '\smoothpath\threesplineinterp' datestr(now, 29) '-' num2str(fnum, 0) '.txt'];
    while(exist(fdir, 'file') ~= 0)
        fnum = fnum + 1;
        fdir = [dirc '\smoothpath\threesplineinterp' datestr(now, 29) '-' num2str(fnum, 0) '.txt'];
    end
    
    % 弹出对话框，选择保存的目录和文件名
    [filename, pahtname, filerindex] = uiputfile({'*.txt'}, '保存光顺后的路径文件',  fdir);
    
    try
        % 创建文件
        wfile = fopen([pahtname filename], 'w+');
    catch err
        % 失败则抛出初五错误消息
        if pahtname ~= 0
            h = msgbox(err.message, '保存失败');
            ah = get( h, 'CurrentAxes' );  
            ch = get( ah, 'Children' );  
            set( ch, 'fontname', '微软雅黑'); 
        end
        return;
    end
    
    % 写入内容
    fprintf(wfile, '\n\n----------------------刀尖点曲线--------------------------\n\n');
    
    L = handles.smoothpath.threesplineinterppath.tipspline.L;
    C = handles.smoothpath.threesplineinterppath.tipspline.C;
    
    V = handles.smoothpath.threesplineinterppath.orientationspline.V;
    D = handles.smoothpath.threesplineinterppath.orientationspline.D;
    
    u = handles.smoothpath.threesplineinterppath.reparam.u;
    h = handles.smoothpath.threesplineinterppath.reparam.h;
    
    fprintf(wfile, 'L = [...\n');
    for i = 1:length(L)
        fprintf(wfile, '%f ', L(i));
    end
    fprintf(wfile, '\n]\n\nC = [...\n');
    
    for i = 1:size(C, 3)
        for j = 1:size(C, 2)
            for k = 1:size(C, 1)
                fprintf(wfile, '%f ', C(k, j, i));
            end
            fprintf(wfile, '\n');
        end
    end
    
    fprintf(wfile, ']\n\n----------------------刀轴矢量曲线--------------------------\n\nD = [...\n');
    for i = 1:length(D)
        fprintf(wfile, '%f ', D(i));
    end
    
    fprintf(wfile, ']\n\nV = [...\n');
    for i = 1:size(V, 3)
        for j = 1:size(V, 2)
            for k = 1:size(V, 1)
                fprintf(wfile, '%f ', V(k, j, i));
            end
            fprintf(wfile, '\n');
        end
    end
    
    fprintf(wfile, ']\n\n----------------------参数同步曲线--------------------------\n\nu = [...\n');
    for i = 1:length(u)
        fprintf(wfile, '%f ', u(i));
    end
    
    fprintf(wfile, ']\n\nh = [...\n');
    for i = 1:length(h)
        fprintf(wfile, '%f ', h(i));
    end
    fprintf(wfile, '\n]');
    
    fclose(wfile);
    
elseif handles.smoothpath.method == 5
    %% 双样条插值方法
    % 查找当前存在的文件，添加编号使文件不重名
    fnum = 1;
    fdir = [dirc '\smoothpath\dualsplineinterppath' datestr(now, 29) '-' num2str(fnum, 0) '.txt'];
    while(exist(fdir, 'file') ~= 0)
        fnum = fnum + 1;
        fdir = [dirc '\smoothpath\dualsplineinterppath' datestr(now, 29) '-' num2str(fnum, 0) '.txt'];
    end
    
    % 弹出对话框，选择保存的目录和文件名
    [filename, pahtname, filerindex] = uiputfile({'*.txt'}, '保存光顺后的路径文件',  fdir);
   
    
    try
        % 创建文件
        wfile = fopen([pahtname filename], 'w+');
    catch err
        % 失败则抛出初五错误消息
        if pahtname ~= 0
            h = msgbox(err.message, '保存失败');
            ah = get( h, 'CurrentAxes' );  
            ch = get( ah, 'Children' );  
            set( ch, 'fontname', '微软雅黑'); 
        end
        return;
    end
    % 保存刀具长度
    fprintf(wfile, '刀具长度： %2.4f\n\n', handles.smoothpath.dualsplinepath.toollength);
    % 保存样条阶数
    fprintf(wfile, '样条阶数： %2.0f\n\n', handles.smoothpath.dualsplinepath.pathspline.splineorder);
    
    % 保存节点向量
    fprintf(wfile, '节点向量\n U = [');
    for i = 1:length(handles.smoothpath.dualsplinepath.pathspline.knotvector)
        fprintf(wfile, '%f, ', handles.smoothpath.dualsplinepath.pathspline.knotvector(i));
        if mod(i, 10) == 0
            fprintf(wfile, '...\n');
        end
    end
    fprintf(wfile, '];\n\n');
    
    % 保存控制点坐标
    fprintf(wfile, '控制点\n CQ = [ ... \n');
    for i = 1:size(handles.smoothpath.dualsplinepath.pathspline.controlp)
        for j = 1:6
            fprintf(wfile, '%f ', handles.smoothpath.dualsplinepath.pathspline.controlp(i, j));
        end
        fprintf(wfile, '\n');
    end
    fprintf(wfile, '];\n');
    
    fclose(wfile);
    msgbox(['光顺后的路径文件保存在' pahtname filename], '光顺后的路径文件保存成功');
end

set(handles.pathsmoothingnotice_text, 'string', '文件保存完毕');
guidata(hObject,handles);   % 更新数据

% --- Executes on button press in smoothreport_pushbutton.
function smoothreport_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to smoothreport_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.smoothpath.method == 1
    % 特征点选择的对偶四元数逼近方法


elseif handles.smoothpath.method == 2
    % 对偶四元数插值方法

    
elseif handles.smoothpath.method == 3
    % 四样条插值方法

    
elseif handles.smoothpath.method == 4
    % 三样条插值方法

    
elseif handles.smoothpath.method == 5
    % 双样条插值方法
  
end


function curvaturedominantselect_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function curvaturedominantselect_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tooltipdominantselect_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function tooltipdominantselect_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function toolotrientationdominantselect_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function toolotrientationdominantselect_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in parameterizationmethod_popupmenu.
function parameterizationmethod_popupmenu_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function parameterizationmethod_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in curveorder_popupmenu.
function curveorder_popupmenu_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function curveorder_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tooltipiterativeaccuracy_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function tooltipiterativeaccuracy_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function toolorientationiterativeaccuracy_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function toolorientationiterativeaccuracy_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function smoothmethod_uipanel_CreateFcn(hObject, eventdata, handles)
% 初始化时设置好默认参数
% 将路径光顺算法设置为对偶四元数逼近方法
handles.smoothpath.method = 1;
guidata(hObject,handles);

% --- Executes when selected object is changed in smoothmethod_uipanel.
function smoothmethod_uipanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject即为选中的句柄，根据句柄就可以知道是哪个单选框被选中了
% 根据光顺方法的不同的选择，调整参数设置组的位置可可视属性

guidata(hObject,handles);
if hObject == handles.dualquatappr_radiobutton
    set(handles.approximationparam_panel, 'position', [3.6 24.4 138.5 6.7], 'visible', 'on');
    set(handles.curveparam_panel, 'position', [3.6 19.2 138.5 4.7], 'visible', 'on');
    set(handles.dualsplineparameter_uipanel, 'visible', 'off');
    
    % 将路径光顺算法设置为对偶四元数逼近方法
    handles.smoothpath.method = 1;
    pathsmoothingmethodintroductionstring = '本课题组提出的基于特征点选择的对偶四元数拟合方法';
    
    set(handles.pathsmoothpic_axes, 'position', [21, 9, 687, 238]);
    smoothapathfig = imread('特征点选择的对偶四元数拟合.jpg');
    axes(handles.pathsmoothpic_axes);
    imagesc(smoothapathfig);

    axis off
    
    
elseif hObject == handles.duaquatinterp_radiobutton
    set(handles.approximationparam_panel, 'visible', 'off');
    set(handles.curveparam_panel, 'position', [3.6 25.2 138.5 5.3], 'visible', 'on');
    set(handles.dualsplineparameter_uipanel, 'visible', 'off');
    
    set(handles.pathsmoothpic_axes, 'position', [21, 9, 800, 310]);
    smoothapathfig = imread('对偶四元数插值.bmp');
    axes(handles.pathsmoothpic_axes);
    imshow(smoothapathfig);

    axis off
    
    % 将路径光顺算法设置为对偶四元数插值方法
    handles.smoothpath.method = 2;
    pathsmoothingmethodintroductionstring = 'Bi, Q., et al., An algorithm to generate compact dual NURBS tool path with equal distance for 5-Axis NC machining, in Intelligent Robotics and Applications. 2010, Springer. p. 553-564.';
elseif hObject == handles.foursplineinterp_radiobutton 
    set(handles.approximationparam_panel, 'visible', 'off');
    set(handles.curveparam_panel, 'visible', 'off');
    set(handles.dualsplineparameter_uipanel, 'visible', 'off');
    
    set(handles.pathsmoothpic_axes, 'position', [21, 9, 687, 380]);
    smoothapathfig = imread('四样条拟合.bmp');
    axes(handles.pathsmoothpic_axes);
    imshow(smoothapathfig);

    axis off
    
    % 将路径光顺算法设置为四样条插值方法
    handles.smoothpath.method = 3;
    pathsmoothingmethodintroductionstring = 'Yuen, A., K. Zhang and Y. Altintas, Smooth trajectory generation for five-axis machine tools. International Journal of Machine Tools and Manufacture, 2013. 71(0): p. 11-19.';
elseif hObject == handles.threesplineinterp_radiobutton
    set(handles.approximationparam_panel, 'visible', 'off');
    set(handles.curveparam_panel, 'visible', 'off');
    set(handles.dualsplineparameter_uipanel, 'visible', 'off');
    
    % 将路径光顺算法设置为三条插值方法
    handles.smoothpath.method = 4;
    pathsmoothingmethodintroductionstring = 'Fleisig, R.V. and A.D. Spence, A constant feed and reduced angular acceleration interpolation algorithm for multi-axis machining. Computer-Aided Design, 2001. 33(1): p. 1 - 15.';

    set(handles.pathsmoothpic_axes, 'position', [21, 9, 687, 390]);
    smoothapathfig = imread('三样条插值光顺.jpg');
    axes(handles.pathsmoothpic_axes);
    imshow(smoothapathfig);

    axis off
    
elseif hObject == handles.dualsplineinterp_radiobutton 
    set(handles.approximationparam_panel, 'visible', 'off');
    set(handles.curveparam_panel, 'visible', 'off');
    set(handles.dualsplineparameter_uipanel, 'position', [3.6 25.5 138.5 5], 'visible', 'on');
    
    % 将路径光顺算法设置为双条插值方法
    handles.smoothpath.method = 5;
    pathsmoothingmethodintroductionstring = 'Langeron, J.M., et al., A new format for 5-axis tool path computation, using Bspline curves. Computer-Aided Design, 2004. 36(12): p. 1219-1229.';
    
    set(handles.pathsmoothpic_axes, 'position', [21, 9, 687, 310]);
    smoothapathfig = imread('双B样条拟合.bmp');
    axes(handles.pathsmoothpic_axes);
    imshow(smoothapathfig);

    axis off
    
end

set(handles.pathsmoothmethodintroduction_text, 'string', pathsmoothingmethodintroductionstring);
guidata(hObject,handles);
drawnow expose       


function tipreferencedist_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function tipreferencedist_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in splineorder_popupmenu.
function splineorder_popupmenu_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function splineorder_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in tooltipconstraint_checkbox.
function tooltipconstraint_checkbox_Callback(hObject, eventdata, handles)

% --- Executes on button press in toolorientationconstraint_checkbox.
function toolorientationconstraint_checkbox_Callback(hObject, eventdata, handles)

% --- Executes on button press in driveconstraint_checkbox.
function driveconstraint_checkbox_Callback(hObject, eventdata, handles)

% --- Executes on button press in cuttingforceconstraint_checkbox.
function cuttingforceconstraint_checkbox_Callback(hObject, eventdata, handles)

% --- Executes on button press in constraintssetting_pushbutton.
function constraintssetting_pushbutton_Callback(hObject, eventdata, handles)
% 获取所选择的约束状态
handles.constraints.selection.dynconstrsel = get(handles.tooltipconstraint_checkbox, 'value');
handles.constraints.selection.geoconstrsel = get(handles.geometryconstraint_checkbox, 'value');
handles.constraints.selection.oriconstrsel = get(handles.toolorientationconstraint_checkbox, 'value');
handles.constraints.selection.driconstrsel = get(handles.driveconstraint_checkbox, 'value');
handles.constraints.selection.forconstrsel = get(handles.cuttingforceconstraint_checkbox, 'value');

try
    % 打开具体参数设置子界面
    handles.constraints.settings = feedratescheduleconstraintssetting(handles.constraints.selection);
    guidata(hObject, handles);      % 更新数据
    
    if isfield(handles.smoothpath, 'dualquatpath') == 1 &&...
            (handles.smoothpath.method == 1 || handles.smoothpath.method == 2) &&...
            handles.constraints.settings.error == 0
        set(handles.feedrateschedulenotification_text, 'string', '约束设置完成，可以进行速度规划。');
        set(handles.feedrateschedule_pushbutton, 'enable', 'on');
    elseif (handles.smoothpath.method ~= 1 && handles.smoothpath.method ~= 2)
        set(handles.feedrateschedulenotification_text, 'string', '约束设置完成，但目前仅支持对偶四元数格式的刀路，您光顺得到的刀路格式暂不支持！请重新选择刀路光顺方法');
    end
    
catch err
    msgbox(err.message, '读取文件失败');
    rethrow(err);
end


% --- Executes on button press in feedrateschedule_pushbutton.
function feedrateschedule_pushbutton_Callback(hObject, eventdata, handles)

% 保存插补周期，这里的数据在进行速度规划时需要用到
handles.interpolationperiod = str2double(get(handles.interpolationperiod_edit, 'string')) / 1000;

set(handles.notification_text, 'string', '正在进行速度规划，请稍等...');
drawnow expose       

% 2015-9-14 未读取速度规划方法单选框，出现错误，特在规划前读取一下所选择的方法。
if get(handles.Sschedule_radiobutton, 'value') == 1
    % 方法1，进行S形速度规划
    handles.feedrateschedule.method = 1;
    handles.feedrateschedule.sshapeschedule = sshapefeedratescheduling(handles.constraints, handles.smoothpath, handles.interpolationperiod);
elseif get(handles.timeoptimschedule_radiobutton, 'value') == 1
    % 方法2，时间最优速度规划，具体参见ICIRA2015 《An Adaptive Feedrate Scheduling Method with Multi-Constraints for Five-Axis Machine Tools》
    handles.feedrateschedule.method = 2;
    if handles.smoothpath.method == 1 || handles.smoothpath.method == 2
        % 如果是对偶四元数格式的刀路，采用如下速度规划方法
        handles.feedrateschedule.timeoptimschedule = dualpathtimeoptimalfeedrateschedule(handles.constraints, handles.smoothpath.dualquatpath, handles.interpolationperiod, handles.machinetype);
    end
end
set(handles.interpcal_pushbutton, 'enable', 'on');
if handles.feedrateschedule.method == 1
    % 计算S形速度规划的结果
    handles.feedrateschedule.scheduleresult = calscheduleresult(handles.feedrateschedule.sshapeschedule, handles.smoothpath, handles.interpolationperiod);
elseif handles.feedrateschedule.method == 2
    
else
    
end

% 只有在速度规划之后，查看规划结果按键才能使用
set(handles.showFext_pushbutton, 'enable', 'on');
set(handles.showFsch_pushbutton, 'enable', 'on');
set(handles.showFdri_pushbutton, 'enable', 'on');
set(handles.showAsch_pushbutton, 'enable', 'on');
set(handles.showAdri_pushbutton, 'enable', 'on');
set(handles.showJsch_pushbutton, 'enable', 'on');
set(handles.showJdri_pushbutton, 'enable', 'on');
set(handles.savefeedrateschedule_pushbutton, 'enable', 'on');
set(handles.notification_text, 'string', '速度规划结束。 下一步进行插补计算。');
handles.step = 4;
handles.noticestring = '速度规划结束。 下一步进行插补计算。';
guidata(hObject, handles);      % 更新数据



% --- Executes on button press in geometryconstraint_checkbox.
function geometryconstraint_checkbox_Callback(hObject, eventdata, handles)

% --- Executes when selected object is changed in uipanel27.
function uipanel27_SelectionChangeFcn(hObject, eventdata, handles)
if hObject == handles.Sschedule_radiobutton
    handles.feedrateschedule.method = 1;
    set(handles.driveconstraint_checkbox, 'enable', 'off', 'value', 0);
    
    set(handles.feedrateschedulingmethod_axis, 'position', [30, 19, 705, 265]);
    axes(handles.feedrateschedulingmethod_axis);
    feedrateschedulefig = imread('S型速度规划.bmp');
    imshow(feedrateschedulefig);
    axis off
    
elseif hObject == handles.timeoptimschedule_radiobutton
    handles.feedrateschedule.method = 2;
    set(handles.driveconstraint_checkbox, 'enable', 'on', 'value', 1);
    
    set(handles.feedrateschedulingmethod_axis, 'position', [30, 19, 705, 265]);
    axes(handles.feedrateschedulingmethod_axis);
    feedrateschedulefig = imread('时间最优速度规划.bmp');
    imshow(feedrateschedulefig);
    axis off
else
    handles.feedrateschedule.method = 3;
end
guidata(hObject, handles);
    



function interpolationperiod_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function interpolationperiod_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in showFext_pushbutton.
function showFext_pushbutton_Callback(hObject, eventdata, handles)
figure('units','normalized','position',[0.1,0.1,0.5,0.5]);
if get(handles.Sschedule_radiobutton, 'value') == 1
    % 如果采用的S形速度规划方法
    plot(handles.feedrateschedule.scheduleresult.t, handles.feedrateschedule.scheduleresult.feedLimit);
    ylim([0 max(handles.feedrateschedule.scheduleresult.feedLimit)+10]);
    hold on;
    plot(handles.feedrateschedule.scheduleresult.t, handles.feedrateschedule.scheduleresult.sVelProfilePlan, 'r');
elseif get(handles.timeoptimschedule_radiobutton, 'value') == 1
    % 如果采用时间最优的速度规划方法
    % 绘制速度极值曲线
    plot(handles.feedrateschedule.timeoptimschedule.scheduledresult.u, handles.feedrateschedule.timeoptimschedule.scheduledresult.velolimtline, 'r', 'linewidth', handles.linewidth);
    hold on;
    
    % 作为比较比较，将规划曲线也绘制出来
    for i = 1:size(handles.feedrateschedule.timeoptimschedule.scheduledresult.u, 1)
        feedp(i) = DeBoorCoxNurbsCal(handles.feedrateschedule.timeoptimschedule.scheduledresult.u(i), handles.feedrateschedule.timeoptimschedule.feedratespline, 0);
    end
    plot(handles.feedrateschedule.timeoptimschedule.scheduledresult.u, feedp, '--b', 'linewidth', handles.linewidth);
end
h = legend('速度极值曲线', '速度规划曲线');
set(h,'Orientation','horizon');
set(gca, 'fontsize', handles.fontsize);
ylabel('速度 (mm/s)', 'fontsize', handles.fontsizelabel);
xlabel('参数 u', 'fontsize', handles.fontsizelabel);


% --- Executes on button press in showFsch_pushbutton.
function showFsch_pushbutton_Callback(hObject, eventdata, handles)

figure('units','normalized','position',[0.1,0.1,0.5,0.5]);

if get(handles.Sschedule_radiobutton, 'value') == 1
    plot(handles.feedrateschedule.scheduleresult.t, handles.feedrateschedule.scheduleresult.sVelProfilePlan);
    ylim([0 max(handles.feedrateschedule.scheduleresult.sVelProfilePlan)+10]);
elseif get(handles.timeoptimschedule_radiobutton, 'value') == 1
    % 如果采用时间最优的速度规划方法
    % 绘制速度极值曲线
    plot(handles.feedrateschedule.timeoptimschedule.scheduledresult.u, handles.feedrateschedule.timeoptimschedule.scheduledresult.velolimtline, 'r', 'linewidth', handles.linewidth);
    hold on;
    
    % 作为比较比较，将规划曲线也绘制出来
    for i = 1:size(handles.feedrateschedule.timeoptimschedule.scheduledresult.u, 1)
        feedp(i) = DeBoorCoxNurbsCal(handles.feedrateschedule.timeoptimschedule.scheduledresult.u(i, 1), handles.feedrateschedule.timeoptimschedule.feedratespline, 0);
    end
    plot(handles.feedrateschedule.timeoptimschedule.scheduledresult.u, feedp, '--b', 'linewidth', handles.linewidth);
    h = legend('速度极值曲线', '速度规划曲线');
    set(h,'Orientation','horizon');
    set(gca, 'fontsize', handles.fontsize);
    ylabel('速度 (mm/s)', 'fontsize', handles.fontsizelabel);
    xlabel('参数 u', 'fontsize', handles.fontsizelabel);
end





% --- Executes on button press in showFdri_pushbutton.
function showFdri_pushbutton_Callback(hObject, eventdata, handles)
% 显示规划的各轴速度曲线
if get(handles.Sschedule_radiobutton, 'value') == 1
    
elseif get(handles.timeoptimschedule_radiobutton, 'value') == 1
    figure('units','normalized','position',[0.1,0.1, 0.6, 0.4]);
    % 绘制平动轴的速度曲线
    subplot(1,2,1);
    plot(handles.feedrateschedule.timeoptimschedule.scheduledresult.u, handles.feedrateschedule.timeoptimschedule.scheduledresult.VX, 'linewidth', 1.5);
    hold on;
    plot(handles.feedrateschedule.timeoptimschedule.scheduledresult.u, handles.feedrateschedule.timeoptimschedule.scheduledresult.VY, 'r', 'linewidth', 1.5);
    plot(handles.feedrateschedule.timeoptimschedule.scheduledresult.u, handles.feedrateschedule.timeoptimschedule.scheduledresult.VZ, 'g', 'linewidth', 1.5);
    h = legend('X轴', 'Y轴', 'Z轴');
    set(h,'Orientation','horizon');
    set(gca, 'fontsize', handles.fontsize);
    ylabel('速度 (mm/s)', 'fontsize', handles.fontsizelabel);
    xlabel('参数 u', 'fontsize', handles.fontsizelabel);
    ymax = max([max(handles.feedrateschedule.timeoptimschedule.scheduledresult.VX), max(handles.feedrateschedule.timeoptimschedule.scheduledresult.VY), max(handles.feedrateschedule.timeoptimschedule.scheduledresult.VZ)]);
    ymin = min([min(handles.feedrateschedule.timeoptimschedule.scheduledresult.VX), min(handles.feedrateschedule.timeoptimschedule.scheduledresult.VY), min(handles.feedrateschedule.timeoptimschedule.scheduledresult.VZ)]);
    ylim([ymin * 1.1, ymax* 1.6]);
    grid on;
    
    % 绘制旋转轴的速度曲线
    subplot(1, 2, 2);
    plot(handles.feedrateschedule.timeoptimschedule.scheduledresult.u, handles.feedrateschedule.timeoptimschedule.scheduledresult.VA, 'linewidth', 1.5);
    hold on;
    plot(handles.feedrateschedule.timeoptimschedule.scheduledresult.u, handles.feedrateschedule.timeoptimschedule.scheduledresult.VC, 'r', 'linewidth', 1.5);
    h = legend('A轴', 'C轴');
    set(h,'Orientation','horizon');
    set(gca, 'fontsize', 15);
    ylabel('速度 (rad/s)', 'fontsize', handles.fontsizelabel);
    xlabel('参数 u', 'fontsize', handles.fontsizelabel);
    ymax = max([max(handles.feedrateschedule.timeoptimschedule.scheduledresult.VA), max(handles.feedrateschedule.timeoptimschedule.scheduledresult.VC)]);
    ymin = min([min(handles.feedrateschedule.timeoptimschedule.scheduledresult.VA), min(handles.feedrateschedule.timeoptimschedule.scheduledresult.VC)]);
    ylim([ymin * 1.1, ymax* 1.4]);
    grid on;
end


% --- Executes on button press in showAsch_pushbutton.
% 显示规划的刀尖点加速度曲线
function showAsch_pushbutton_Callback(hObject, eventdata, handles)
figure('units','normalized','position',[0.1,0.1,0.5,0.5]);
if get(handles.Sschedule_radiobutton, 'value') == 1
    % S形规划方法
    plot(handles.feedrateschedule.scheduleresult.t, handles.feedrateschedule.scheduleresult.sAccPlan);
    ylim([0 max(handles.feedrateschedule.scheduleresult.sAccPlan)+100]); 
elseif get(handles.timeoptimschedule_radiobutton, 'value') == 1
    % 时间最优规划
    plot(handles.feedrateschedule.timeoptimschedule.scheduledresult.u(1:length(handles.feedrateschedule.timeoptimschedule.scheduledresult.tipA)), handles.feedrateschedule.timeoptimschedule.scheduledresult.tipA, 'linewidth', 1.5);
    h = legend('加速度规划值');
    set(h,'Orientation','horizon');
    set(gca, 'fontsize', 15);
    ylabel('加速度 (mm/s^2)', 'fontsize', handles.fontsizelabel);
    xlabel('参数 u', 'fontsize', handles.fontsizelabel);
    ymax = max(handles.feedrateschedule.timeoptimschedule.scheduledresult.tipA);
    ymin = min(handles.feedrateschedule.timeoptimschedule.scheduledresult.tipA);
    ylim([ymin * 1.1, ymax* 1.3]);
    grid on;
end



% --- Executes on button press in showAdri_pushbutton.
function showAdri_pushbutton_Callback(hObject, eventdata, handles)
% 显示规划的各轴速度曲线
if get(handles.Sschedule_radiobutton, 'value') == 1
    
elseif get(handles.timeoptimschedule_radiobutton, 'value') == 1
    figure('units','normalized','position',[0.1,0.1, 0.6, 0.4]);
    % 绘制平动轴的速度曲线
    subplot(1,2,1);
    plot(handles.feedrateschedule.timeoptimschedule.scheduledresult.u(1:length(handles.feedrateschedule.timeoptimschedule.scheduledresult.AX)), handles.feedrateschedule.timeoptimschedule.scheduledresult.AX, 'linewidth', 1.5);
    hold on;
    plot(handles.feedrateschedule.timeoptimschedule.scheduledresult.u(1:length(handles.feedrateschedule.timeoptimschedule.scheduledresult.AX)), handles.feedrateschedule.timeoptimschedule.scheduledresult.AY, 'r', 'linewidth', 1.5);
    plot(handles.feedrateschedule.timeoptimschedule.scheduledresult.u(1:length(handles.feedrateschedule.timeoptimschedule.scheduledresult.AX)), handles.feedrateschedule.timeoptimschedule.scheduledresult.AZ, 'g', 'linewidth', 1.5);
    h = legend('X轴', 'Y轴', 'Z轴');
    set(h,'Orientation','horizon');
    set(gca, 'fontsize', handles.fontsize);
    ylabel('加速度 (mm/s^2)', 'fontsize', handles.fontsizelabel);
    xlabel('参数 u', 'fontsize', handles.fontsizelabel);
    ymax = max([max(handles.feedrateschedule.timeoptimschedule.scheduledresult.AX), max(handles.feedrateschedule.timeoptimschedule.scheduledresult.AY), max(handles.feedrateschedule.timeoptimschedule.scheduledresult.AZ)]);
    ymin = min([min(handles.feedrateschedule.timeoptimschedule.scheduledresult.AX), min(handles.feedrateschedule.timeoptimschedule.scheduledresult.AY), min(handles.feedrateschedule.timeoptimschedule.scheduledresult.AZ)]);
    ylim([ymin * 1.1, ymax* 1.6]);
    grid on;
    
    % 绘制旋转轴的速度曲线
    subplot(1, 2, 2);
    plot(handles.feedrateschedule.timeoptimschedule.scheduledresult.u(1:length(handles.feedrateschedule.timeoptimschedule.scheduledresult.AX)), handles.feedrateschedule.timeoptimschedule.scheduledresult.AA, 'linewidth', 1.5);
    hold on;
    plot(handles.feedrateschedule.timeoptimschedule.scheduledresult.u(1:length(handles.feedrateschedule.timeoptimschedule.scheduledresult.AX)), handles.feedrateschedule.timeoptimschedule.scheduledresult.AC, 'r', 'linewidth', 1.5);
    h = legend('A轴', 'C轴');
    set(h,'Orientation','horizon');
    set(gca, 'fontsize', 15);
    ylabel('加速度 (rad/s^2)', 'fontsize', handles.fontsizelabel);
    xlabel('参数 u', 'fontsize', handles.fontsizelabel);
    ymax = max([max(handles.feedrateschedule.timeoptimschedule.scheduledresult.AA), max(handles.feedrateschedule.timeoptimschedule.scheduledresult.AC)]);
    ymin = min([min(handles.feedrateschedule.timeoptimschedule.scheduledresult.AA), min(handles.feedrateschedule.timeoptimschedule.scheduledresult.AC)]);
    ylim([ymin * 1.1, ymax* 1.4]);
    grid on;
end


% --- Executes on button press in showJsch_pushbutton.
function showJsch_pushbutton_Callback(hObject, eventdata, handles)
figure('units','normalized','position',[0.1,0.1,0.5,0.5]);

if get(handles.Sschedule_radiobutton, 'value') == 1
    % S形规划方法
    plot(handles.feedrateschedule.scheduleresult.t, handles.feedrateschedule.scheduleresult.sJerkPlan);
elseif get(handles.timeoptimschedule_radiobutton, 'value') == 1
    % 时间最优规划
    plot(handles.feedrateschedule.timeoptimschedule.scheduledresult.u(1:length(handles.feedrateschedule.timeoptimschedule.scheduledresult.tipJ)), handles.feedrateschedule.timeoptimschedule.scheduledresult.tipJ, 'linewidth', 1.5);
    h = legend('跃度规划值');
    set(h,'Orientation','horizon');
    set(gca, 'fontsize', 15);
    ylabel('跃度 (mm/s^3)', 'fontsize', handles.fontsizelabel);
    xlabel('参数 u', 'fontsize', handles.fontsizelabel);
    ymax = max(handles.feedrateschedule.timeoptimschedule.scheduledresult.tipJ);
    ymin = min(handles.feedrateschedule.timeoptimschedule.scheduledresult.tipJ);
    ylim([ymin * 1.1, ymax* 1.3]);
    grid on;
end

% --- Executes on button press in showJdri_pushbutton.
function showJdri_pushbutton_Callback(hObject, eventdata, handles)
if get(handles.Sschedule_radiobutton, 'value') == 1
    
elseif get(handles.timeoptimschedule_radiobutton, 'value') == 1
    figure('units','normalized','position',[0.1,0.1, 0.6, 0.4]);
    % 绘制平动轴的跃度曲线
    subplot(1,2,1);
    plot(handles.feedrateschedule.timeoptimschedule.scheduledresult.u(1:length(handles.feedrateschedule.timeoptimschedule.scheduledresult.JX)), handles.feedrateschedule.timeoptimschedule.scheduledresult.JX, 'linewidth', 1.5);
    hold on;
    plot(handles.feedrateschedule.timeoptimschedule.scheduledresult.u(1:length(handles.feedrateschedule.timeoptimschedule.scheduledresult.JX)), handles.feedrateschedule.timeoptimschedule.scheduledresult.JY, 'r', 'linewidth', 1.5);
    plot(handles.feedrateschedule.timeoptimschedule.scheduledresult.u(1:length(handles.feedrateschedule.timeoptimschedule.scheduledresult.JX)), handles.feedrateschedule.timeoptimschedule.scheduledresult.JZ, 'g', 'linewidth', 1.5);
    h = legend('X轴', 'Y轴', 'Z轴');
    set(h,'Orientation','horizon', 'box', 'off');
    set(gca, 'fontsize', handles.fontsize);
    ylabel('跃度 (mm/s^3)', 'fontsize', handles.fontsizelabel);
    xlabel('参数 u', 'fontsize', handles.fontsizelabel);
    ymax = max([max(handles.feedrateschedule.timeoptimschedule.scheduledresult.JX), max(handles.feedrateschedule.timeoptimschedule.scheduledresult.JY), max(handles.feedrateschedule.timeoptimschedule.scheduledresult.JZ)]);
    ymin = min([min(handles.feedrateschedule.timeoptimschedule.scheduledresult.JX), min(handles.feedrateschedule.timeoptimschedule.scheduledresult.JY), min(handles.feedrateschedule.timeoptimschedule.scheduledresult.JZ)]);
    ylim([ymin * 1.1, ymax* 1.6]);
    grid on;
    
    % 绘制旋转轴的速度曲线
    subplot(1, 2, 2);
    plot(handles.feedrateschedule.timeoptimschedule.scheduledresult.u(1:length(handles.feedrateschedule.timeoptimschedule.scheduledresult.JX)), handles.feedrateschedule.timeoptimschedule.scheduledresult.JA, 'linewidth', 1.5);
    hold on;
    plot(handles.feedrateschedule.timeoptimschedule.scheduledresult.u(1:length(handles.feedrateschedule.timeoptimschedule.scheduledresult.JX)), handles.feedrateschedule.timeoptimschedule.scheduledresult.JC, 'r', 'linewidth', 1.5);
    h = legend('A轴', 'C轴');
    set(h,'Orientation','horizon', 'box', 'off');
    set(gca, 'fontsize', 15);
    ylabel('跃度 (rad/s^3)', 'fontsize', handles.fontsizelabel);
    xlabel('参数 u', 'fontsize', handles.fontsizelabel);
    ymax = max([max(handles.feedrateschedule.timeoptimschedule.scheduledresult.JA), max(handles.feedrateschedule.timeoptimschedule.scheduledresult.JC)]);
    ymin = min([min(handles.feedrateschedule.timeoptimschedule.scheduledresult.JA), min(handles.feedrateschedule.timeoptimschedule.scheduledresult.JC)]);
    ylim([ymin * 1.1, ymax* 1.4]);
    grid on;
end

% --- Executes on button press in savefeedrateschedule_pushbutton.
function savefeedrateschedule_pushbutton_Callback(hObject, eventdata, handles)

% --- Executes on button press in interpcal_pushbutton.

function interpcal_pushbutton_Callback(hObject, eventdata, handles)
%% 速度规划功能模块
set(handles.notification_text, 'string', '正在进行插补计算，请稍等......');
drawnow;

if handles.feedrateschedule.method == 1
    % 采用s型速度规划方法
    
elseif handles.feedrateschedule.method == 2
    % 采用时间最优速度规划方法
    if handles.smoothpath.method == 1 || handles.smoothpath.method == 2
        % 对于对偶四元数格式的刀路进行插补计算
        interpresult = dualquaternionspathsecondTaylorinterp(handles.feedrateschedule.timeoptimschedule.feedratespline, handles.smoothpath.dualquatpath, handles.interpolationperiod, handles.machinetype);
    else
        
    end
    % 将插补得到的结果保存在handles结构体中
    handles.interpresult = interpresult;
else
    % 其他方法
    
end
set(handles.notification_text, 'string', '插补计算结束。');
handles.step = 5;

% 插补结束，显示结果的按键使能
set(handles.showvelo_pushbutton, 'enable', 'on');
set(handles.showaxesvel_pushbutton, 'enable', 'on');
set(handles.showacc_pushbutton, 'enable', 'on');
set(handles.showaxesacc_pushbutton, 'enable', 'on');
set(handles.showaxesjerk_pushbutton, 'enable', 'on');
set(handles.showactualjerk_pushbutton, 'enable', 'on');
set(handles.saveinterpresult_pushbutton, 'enable', 'on');
set(handles.postprocess_pushbutton, 'enable', 'on');
guidata(hObject, handles);

% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)

% --- Executes on button press in showvelo_pushbutton.
function showvelo_pushbutton_Callback(hObject, eventdata, handles)

figure('units','normalized','position',[0.1,0.1,0.5,0.5]);

if handles.interp.method == 1
    
elseif handles.interp.method == 2
    
    plot((1:length(handles.interpresult.actualf)) * handles.interpolationperiod, handles.interpresult.actualf, 'linewidth', 1.5);

    h = legend('插补刀尖点实际速度');
    set(h,'Orientation','horizon');
    set(gca, 'fontsize', 15);
    ylabel('速度 (mm/s)', 'fontsize', handles.fontsizelabel);
    xlabel('时间 (s)', 'fontsize', handles.fontsizelabel);
    ymax = max(handles.interpresult.actualf);
    ymin = min(handles.interpresult.actualf);
    ylim([ymin * 1.1, ymax* 1.3]);
    xlim([0, length(handles.interpresult.actualf) * handles.interpolationperiod]);
    grid on;
else
    
end

% --- Executes on button press in showaxesvel_pushbutton.
function showaxesvel_pushbutton_Callback(hObject, eventdata, handles)


if handles.interp.method == 1
    
elseif handles.interp.method == 2
    figure('units','normalized','position',[0.1,0.1, 0.7, 0.4]);
    % 绘制平动轴的速度曲线
    subplot(1,2,1);
    plot((1:length(handles.interpresult.actualf)) * handles.interpolationperiod, handles.interpresult.schedulMV(:, 3), 'linewidth', 1.5);
    hold on;
    plot((1:length(handles.interpresult.actualf)) * handles.interpolationperiod, handles.interpresult.schedulMV(:, 4), 'r', 'linewidth', 1.5);
    plot((1:length(handles.interpresult.actualf)) * handles.interpolationperiod, handles.interpresult.schedulMV(:, 5), 'g', 'linewidth', 1.5);
    h = legend('X轴', 'Y轴', 'Z轴');
    set(h,'Orientation','horizon');
    set(gca, 'fontsize', handles.fontsize);
    ylabel('速度 (mm/s)', 'fontsize', handles.fontsizelabel);
    xlabel('时间 (s)', 'fontsize', handles.fontsizelabel);
    ymax = max([max(handles.interpresult.schedulMV(:, 3)), max(handles.interpresult.schedulMV(:, 4)), max(handles.interpresult.schedulMV(:, 5))]);
    ymin = min([min(handles.interpresult.schedulMV(:, 3)), min(handles.interpresult.schedulMV(:, 4)), min(handles.interpresult.schedulMV(:, 5))]);
    ylim([ymin * 1.1, ymax* 1.6]);
    xlim([0, length(handles.interpresult.actualf) * handles.interpolationperiod]);
    grid on;
    
    % 绘制旋转轴的速度曲线
    subplot(1, 2, 2);
    plot((1:length(handles.interpresult.actualf)) * handles.interpolationperiod, handles.interpresult.schedulMV(:, 1), 'linewidth', 1.5);
    hold on;
    plot((1:length(handles.interpresult.actualf)) * handles.interpolationperiod, handles.interpresult.schedulMV(:, 2), 'r', 'linewidth', 1.5);
    h = legend('A轴', 'C轴');
    set(h,'Orientation','horizon');
    set(gca, 'fontsize', 15);
    ylabel('速度 (rad/s)', 'fontsize', handles.fontsizelabel);
    xlabel('时间 (s)', 'fontsize', handles.fontsizelabel);
    ymax = max([max(handles.interpresult.schedulMV(:, 1)), max(handles.interpresult.schedulMV(:, 2))]);
    ymin = min([min(handles.interpresult.schedulMV(:, 1)), min(handles.interpresult.schedulMV(:, 2))]);
    ylim([ymin * 1.1, ymax* 1.4]);
    xlim([0, length(handles.interpresult.actualf) * handles.interpolationperiod]);
    grid on;
else
    
end

% --- Executes on button press in showacc_pushbutton.
function showacc_pushbutton_Callback(hObject, eventdata, handles)
% 绘制切向加速度曲线
if handles.interp.method == 1
    
elseif handles.interp.method == 2
    figure('units','normalized','position',[0.1,0.1, 0.5, 0.4]);
    
    % 求实际刀尖点加速度
    actualacc = zeros(length(handles.interpresult.actualf) - 1, 1);
    
    for i = 1:length(handles.interpresult.actualf) - 1
        actualacc(i) = (handles.interpresult.actualf(i + 1) - handles.interpresult.actualf(i)) / handles.interpolationperiod;
    end
    plot((1:length(actualacc)) * handles.interpolationperiod, actualacc, 'linewidth', 1.5);

    h = legend('尖点实际加速度');
    set(h,'Orientation','horizon');
    set(gca, 'fontsize', 15);
    ylabel('加速度 (mm/s^2)', 'fontsize', handles.fontsizelabel);
    xlabel('时间 (s)', 'fontsize', handles.fontsizelabel);
    ymax = max(actualacc);
    ymin = min(actualacc);
    ylim([ymin * 1.1, ymax* 1.3]);
    xlim([0, length(actualacc) * handles.interpolationperiod]);
    grid on;
else
    
end


% --- Executes on button press in showaxesacc_pushbutton.
function showaxesacc_pushbutton_Callback(hObject, eventdata, handles)
if handles.interp.method == 1
    
elseif handles.interp.method == 2
    actualMA = zeros(length(handles.interpresult.actualf) - 1, 5);
    
    for i = 1:length(handles.interpresult.actualf) - 1
        actualMA(i, :) = (handles.interpresult.actualMV(i + 1, :) - handles.interpresult.actualMV(i, :)) / handles.interpolationperiod;
    end
    figure('units','normalized','position',[0.1,0.1, 0.7, 0.4]);
    % 绘制平动轴的加速度曲线
    subplot(1,2,1);
    plot((1:(length(handles.interpresult.actualf) - 1)) * handles.interpolationperiod, actualMA(:, 3), 'linewidth', 1.5);
    hold on;
    plot((1:(length(handles.interpresult.actualf) - 1)) * handles.interpolationperiod, actualMA(:, 4), 'r', 'linewidth', 1.5);
    plot((1:(length(handles.interpresult.actualf) - 1)) * handles.interpolationperiod, actualMA(:, 5), 'g', 'linewidth', 1.5);
    h = legend('X轴', 'Y轴', 'Z轴');
    set(h,'Orientation','horizon');
    set(gca, 'fontsize', handles.fontsize);
    ylabel('加速度 (mm/s^2)', 'fontsize', handles.fontsizelabel);
    xlabel('时间 (s)', 'fontsize', handles.fontsizelabel);
    ymax = max([max(actualMA(:, 3)), max(actualMA(:, 4)), max(actualMA(:, 5))]);
    ymin = min([min(actualMA(:, 3)), min(actualMA(:, 4)), min(actualMA(:, 5))]);
    ylim([ymin * 1.1, ymax* 1.6]);
    xlim([0, length(handles.interpresult.actualf) * handles.interpolationperiod]);
    grid on;
    
    % 绘制旋转轴的加速度曲线
    subplot(1, 2, 2);
    plot((1:(length(handles.interpresult.actualf) - 1)) * handles.interpolationperiod, actualMA(:, 1), 'linewidth', 1.5);
    hold on;
    plot((1:(length(handles.interpresult.actualf) - 1)) * handles.interpolationperiod, actualMA(:, 2), 'r', 'linewidth', 1.5);
    h = legend('A轴', 'C轴');
    set(h,'Orientation','horizon');
    set(gca, 'fontsize', 15);
    ylabel('加速度 (rad/s^2)', 'fontsize', handles.fontsizelabel);
    xlabel('时间 (s)', 'fontsize', handles.fontsizelabel);
    ymax = max([max(actualMA(:, 1)), max(actualMA(:, 2))]);
    ymin = min([min(actualMA(:, 1)), min(actualMA(:, 2))]);
    ylim([ymin * 1.1, ymax* 1.4]);
    xlim([0, length(handles.interpresult.actualf) * handles.interpolationperiod]);
    grid on;
else
    
end


% --- Executes on button press in pushbutton31.
function pushbutton31_Callback(hObject, eventdata, handles)

% --- Executes on button press in showaxesjerk_pushbutton.
function showaxesjerk_pushbutton_Callback(hObject, eventdata, handles)
% 绘制各轴实际跃度曲线
if handles.interp.method == 1
    
elseif handles.interp.method == 2
    actualMJ = zeros(length(handles.interpresult.actualf) - 2, 5);
    
    for i = 1:length(handles.interpresult.actualf) - 2
        actualMJ(i, :) = (handles.interpresult.actualMV(i + 2, :) - 2 * handles.interpresult.actualMV(i + 1, :) + handles.interpresult.actualMV(i, :)) / handles.interpolationperiod ^ 2;
    end
    figure('units','normalized','position',[0.1,0.1, 0.7, 0.4]);
    % 绘制平动轴的加速度曲线
    subplot(1,2,1);
    plot((5:(length(handles.interpresult.actualf) - 2)) * handles.interpolationperiod, actualMJ(5:end, 3), 'linewidth', 1.5);
    hold on;
    plot((5:(length(handles.interpresult.actualf) - 2)) * handles.interpolationperiod, actualMJ(5:end, 4), 'r', 'linewidth', 1.5);
    plot((5:(length(handles.interpresult.actualf) - 2)) * handles.interpolationperiod, actualMJ(5:end, 5), 'g', 'linewidth', 1.5);
    h = legend('X轴', 'Y轴', 'Z轴');
    set(h,'Orientation','horizon');
    set(gca, 'fontsize', handles.fontsize);
    ylabel('跃度 (mm/s^3)', 'fontsize', handles.fontsizelabel);
    xlabel('时间 (s)', 'fontsize', handles.fontsizelabel);
    ymax = max([max(actualMJ(5:end, 3)), max(actualMJ(5:end, 4)), max(actualMJ(5:end, 5))]);
    ymin = min([min(actualMJ(5:end, 3)), min(actualMJ(5:end, 4)), min(actualMJ(5:end, 5))]);
    ylim([ymin * 1.1, ymax* 1.6]);
    xlim([0, length(handles.interpresult.actualf) * handles.interpolationperiod]);
    grid on;
    
    % 绘制旋转轴的加速度曲线
    subplot(1, 2, 2);
    plot((5:(length(handles.interpresult.actualf) - 2)) * handles.interpolationperiod, actualMJ(5:end, 1), 'linewidth', 1.5);
    hold on;
    plot((5:(length(handles.interpresult.actualf) - 2)) * handles.interpolationperiod, actualMJ(5:end, 2), 'r', 'linewidth', 1.5);
    h = legend('A轴', 'C轴');
    set(h,'Orientation','horizon');
    set(gca, 'fontsize', 15);
    ylabel('跃度 (rad/s^3)', 'fontsize', handles.fontsizelabel);
    xlabel('时间 (s)', 'fontsize', handles.fontsizelabel);
    ymax = max([max(actualMJ(5:end, 1)), max(actualMJ(5:end, 2))]);
    ymin = min([min(actualMJ(5:end, 1)), min(actualMJ(5:end, 2))]);
    ylim([ymin * 1.1, ymax* 1.4]);
    xlim([0, length(handles.interpresult.actualf) * handles.interpolationperiod]);
    grid on;
else
    
end

% --- Executes on button press in pushbutton33.
function pushbutton33_Callback(hObject, eventdata, handles)

% --- Executes on button press in interpPoutput_checkbox.
function interpPoutput_checkbox_Callback(hObject, eventdata, handles)

% --- Executes on button press in interpVoutput_checkbox.
function interpVoutput_checkbox_Callback(hObject, eventdata, handles)

% --- Executes on button press in interpAoutput_checkbox.
function interpAoutput_checkbox_Callback(hObject, eventdata, handles)

% --- Executes on button press in threevectoroutput_checkbox.
function threevectoroutput_checkbox_Callback(hObject, eventdata, handles)

% --- Executes on button press in interpKoutput_checkbox.
function interpKoutput_checkbox_Callback(hObject, eventdata, handles)

% --- Executes on button press in interpToutput_checkbox.
function interpToutput_checkbox_Callback(hObject, eventdata, handles)

% --- Executes on button press in machinetoolconfig_togglebutton.
function machinetoolconfig_togglebutton_Callback(hObject, eventdata, handles)

set(handles.machinetoolconfig_togglebutton, 'Value', 1, 'backgroundcolor', [0.941 0.941 0.941], 'fontweight', 'bold', 'fontsize', 12);
set(handles.toolpath_togglebutton, 'Value', 0, 'backgroundcolor', [0.8 0.8 0.8], 'fontweight', 'normal', 'fontsize', 10);
set(handles.toolpathsmooth_togglebutton, 'Value', 0, 'backgroundcolor', [0.8 0.8 0.8], 'fontweight', 'normal', 'fontsize', 10);
set(handles.feedrateschedule_togglebutton, 'Value', 0, 'backgroundcolor', [0.8 0.8 0.8], 'fontweight', 'normal', 'fontsize', 10);
set(handles.interpolation_togglebutton, 'Value', 0, 'backgroundcolor', [0.8 0.8 0.8], 'fontweight', 'normal', 'fontsize', 10);

set(handles.machinetoolconfig_panel,  'visible', 'on');
set(handles.toolpath_panel,  'visible', 'off');
set(handles.toolpathsmooth_panel,  'visible', 'off');
set(handles.feedrateschedule_panel,  'visible', 'off');
set(handles.interpolation_panel,  'visible', 'off');

drawnow expose       

% Hint: get(hObject,'Value') returns toggle state of machinetoolconfig_togglebutton


% --- Executes during object creation, after setting all properties.
function configurationselection_uipanel_CreateFcn(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function machinetoolconfig_axes_CreateFcn(hObject, eventdata, handles)
% handles.machinetoolconfig_axes = hObject;
% machinetoolfig = imread('双转台.bmp');
% % machinetoolfig = imread('AC双摆头模型.bmp');
% axes(hObject);
% imshow(machinetoolfig);
% handles.machinetype = 1;    % 初始化机床类型
% guidata(hObject, handles);  % 2015-09-11将此放于机床类型初始化之前，程序出错

% Hint: place code in OpeningFcn to populate machinetoolconfig_axes


% --- Executes during object creation, after setting all properties.
function machinetoolconfig_panel_CreateFcn(hObject, eventdata, handles)
% 在面板初始化的时候将机床类型设为1，这样可以保证不出错
handles.machinetype = 1;
guidata(hObject,handles);

% --- Executes when selected object is changed in configurationselection_uipanel.
function configurationselection_uipanel_SelectionChangeFcn(hObject, eventdata, handles)
% 根据选择绘制相应的机床图片
axes(handles.machinetoolconfig_axes);
if hObject == handles.rotarytable_radiobutton
    machinetoolfig = imread('双转台.bmp');
    imshow(machinetoolfig);
    set(handles.rotarytablesetting_uipanel, 'position', [4.2, 29, 55, 6.85], 'visible', 'on');
    set(handles.rotaryspindlesetting_uipanel, 'position', [4.2, 29, 55, 4.8], 'visible', 'off');
    set(handles.Axesmoverangesetting_panel, 'position', [4.6, 14, 55, 14.5]);
    handles.machinetype = 1;
elseif hObject == handles.rotaryspindle_radiobutton
    machinetoolfig = imread('AC双摆头模型.bmp');
    imshow(machinetoolfig);
    set(handles.rotarytablesetting_uipanel, 'position', [4.2, 29, 55, 6.85], 'visible', 'off');
    set(handles.rotaryspindlesetting_uipanel, 'position', [4.2, 30.9, 55, 4.8], 'visible', 'on');
    set(handles.Axesmoverangesetting_panel, 'position', [4.6, 16, 55, 14.5]);
    handles.machinetype = 2;
end
guidata(hObject,handles);

% --- Executes on button press in machineconfigsettingok_pushbutton.
function machineconfigsettingok_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to machineconfigsettingok_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 确定设定的机床参数
if handles.machinetype == 1
    Lz = str2double(get(handles.rotarytableLz_edit, 'string'));
    Ly = str2double(get(handles.rotarytableLy_edit, 'string'));
    handles.rotarytable.Lz = Lz;
    handles.rotarytable.Ly = Ly;
    noticstring = ['已成功设置机床为双转台结构，Z方向偏置Lz为 ', get(handles.rotarytableLz_edit, 'string'), ' mm，Y方向偏置Ly为 ', get(handles.rotarytableLy_edit, 'string'), ' mm'];

elseif handles.machinetype == 2
    L = str2double(get(handles.rotaryspindleL_edit, 'string'));
    handles.rotaryspindle.L = L;
    noticstring = ['已成功设置机床为双摆头结构，Z方向偏置L为 ', get(handles.rotaryspindleL_edit, 'string'), ' mm'];
end
handles.axesmoverangesetting.xlow = str2double(get(handles.Xlimitlow_edit, 'string'));
handles.axesmoverangesetting.xup = str2double(get(handles.Xlimithigh_edit, 'string'));

handles.axesmoverangesetting.ylow = str2double(get(handles.Ylimitlow_edit, 'string'));
handles.axesmoverangesetting.yup = str2double(get(handles.Ylimithigh_edit, 'string'));

handles.axesmoverangesetting.zlow = str2double(get(handles.Zlimitlow_edit, 'string'));
handles.axesmoverangesetting.zup = str2double(get(handles.Zlimithigh_edit, 'string'));

handles.axesmoverangesetting.alow = str2double(get(handles.Alimitlow_edit, 'string'));
handles.axesmoverangesetting.aup = str2double(get(handles.Alimithigh_edit, 'string'));

handles.axesmoverangesetting.clow = str2double(get(handles.Climitlow_edit, 'string'));
handles.axesmoverangesetting.cup = str2double(get(handles.Climithigh_edit, 'string'));

handles.step = 1;	% 机床配置完成，记录进度
noticstring = [noticstring, '。 下一步请添加刀路'];
set(handles.notification_text, 'string', noticstring);
handles.noticestring = noticstring;

guidata(hObject,handles);



function rotarytableLz_edit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function rotarytableLz_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function rotarytableLy_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function rotarytableLy_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rotaryspindleL_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function rotaryspindleL_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit30_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit30_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function machinetoolconfig_axes_ButtonDownFcn(hObject, eventdata, handles)


function uipanel27_CreateFcn(hObject, eventdata, handles)



function Xlimitlow_edit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function Xlimitlow_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Xlimithigh_edit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function Xlimithigh_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ylimitlow_edit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function Ylimitlow_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ylimithigh_edit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function Ylimithigh_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Zlimitlow_edit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function Zlimitlow_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Zlimithigh_edit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function Zlimithigh_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Alimitlow_edit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function Alimitlow_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Alimithigh_edit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function Alimithigh_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Climitlow_edit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function Climitlow_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Climithigh_edit_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function Climithigh_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in uipanel38.
function uipanel38_SelectionChangeFcn(hObject, eventdata, handles)


if get(handles.firsttalorinterp_radiobutton, 'value') == 1
    handles.interp.method = 1;
    axes(handles.interp_axes);
    interpfig = imread('一阶泰勒.bmp');
    imagesc(interpfig);
    axis off
elseif get(handles.secondtalorinterp_radiobutton, 'value') == 1
    handles.interp.method = 2;
    
    axes(handles.interp_axes);
    interpfig = imread('二阶泰勒.bmp');
    imagesc(interpfig);
    axis off
else
    handles.inter.pmethod = 3;    
end
    


% --- Executes on button press in postprocess_pushbutton.
function postprocess_pushbutton_Callback(hObject, eventdata, handles)
% 输出后置处理后的文件
dirc = ['..\Data\Output\' datestr(now, 29) ];
if exist([dirc '\postprocess'], 'dir') == 0
    mkdir(dirc, 'postprocess');
end
fnum = 1;
fdir = [dirc '\postprocess\postprocess' datestr(now, 29) '-' num2str(fnum, 0) '.txt'];
while(exist(fdir, 'file') ~= 0)
    fnum = fnum + 1;
    fdir = [dirc '\postprocess\postprocess' datestr(now, 29) '-' num2str(fnum, 0) '.txt'];
end

% 弹出对话框，选择保存的目录和文件名
[filename, pahtname, filerindex] = uiputfile({'*.txt'}, '保存光顺后的路径文件',  fdir);
try
	% 创建文件
	wfile = fopen([pahtname filename], 'w+');
catch err
	% 失败则抛出错误消息
	if pahtname ~= 0
		h = msgbox(err.message, '保存失败');
		ah = get( h, 'CurrentAxes' );  
		ch = get( ah, 'Children' );  
		set( ch, 'fontname', '微软雅黑'); 
	end
	return;
end

for i = 1:size(handles.interpresult.mcrarr, 1)
    fprintf(wfile, '%f, %f, %f, %f, %f, %f', handles.interpresult.mcrarr(i, 1), handles.interpresult.mcrarr(i, 2), handles.interpresult.mcrarr(i, 3), handles.interpresult.mcrarr(i, 4), handles.interpresult.mcrarr(i, 5));
    fprintf(wfile, '\n');
end
fclose(wfile);

% --- Executes on button press in showactualjerk_pushbutton.
function showactualjerk_pushbutton_Callback(hObject, eventdata, handles)
% 绘制切向跃度曲线
if handles.interp.method == 1
    
elseif handles.interp.method == 2
    figure('units','normalized','position',[0.1,0.1, 0.5, 0.4]);
    
    % 求实际刀尖点跃度
    actualjerk = zeros(length(handles.interpresult.actualf) - 2, 1);
    
    for i = 1:length(handles.interpresult.actualf) - 2
        actualjerk(i) = (handles.interpresult.actualf(i + 2) - 2 * handles.interpresult.actualf(i + 1) + handles.interpresult.actualf(i)) / handles.interpolationperiod ^ 2;
    end
    plot((5:length(actualjerk)) * handles.interpolationperiod, actualjerk(5:end), 'linewidth', 1.5);

    h = legend('尖点实际加速度');
    set(h,'Orientation','horizon');
    set(gca, 'fontsize', 15);
    ylabel('加速度 (mm/s…^2)', 'fontsize', handles.fontsizelabel);
    xlabel('时间 (s)', 'fontsize', handles.fontsizelabel);
    ymax = max(actualjerk(5:end));
    ymin = min(actualjerk(5:end));
    ylim([ymin * 1.1, ymax* 1.3]);
    xlim([0, length(actualjerk) * handles.interpolationperiod]);
    grid on;
else
    
end


% --- Executes on button press in saveinterpresult_pushbutton.
function saveinterpresult_pushbutton_Callback(hObject, eventdata, handles)
% 保存插补计算之后计算结果，输出格式根据选择而定
% 查找当前存在的文件，添加编号使文件不重名
dirc = ['..\Data\Output\' datestr(now, 29) ];
if exist([dirc '\interpolation'], 'dir') == 0
    mkdir(dirc, 'interpolation');
end
fnum = 1;
fdir = [dirc '\interpolation\interpolation' datestr(now, 29) '-' num2str(fnum, 0) '.txt'];
while(exist(fdir, 'file') ~= 0)
    fnum = fnum + 1;
    fdir = [dirc '\interpolation\interpolation' datestr(now, 29) '-' num2str(fnum, 0) '.txt'];
end

% 弹出对话框，选择保存的目录和文件名
[filename, pahtname, filerindex] = uiputfile({'*.txt'}, '保存光顺后的路径文件',  fdir);
try
	% 创建文件
	wfile = fopen([pahtname filename], 'w+');
catch err
	% 失败则抛出初五错误消息
	if pahtname ~= 0
		h = msgbox(err.message, '保存失败');
		ah = get( h, 'CurrentAxes' );  
		ch = get( ah, 'Children' );  
		set( ch, 'fontname', '微软雅黑'); 
	end
	return;
end
fprintf(wfile, '% ');
	
if get(handles.interpPoutput_checkbox, 'value') == 1
	fprintf(wfile, '刀尖点坐标和刀轴向量 x, y, z, i, j, k ');
end

if get(handles.interpVoutput_checkbox, 'value') == 1
	fprintf(wfile, '、进给速度 f ');
end

if get(handles.interpAoutput_checkbox, 'value') == 1
	fprintf(wfile, '、加速度 a');
end

if get(handles.interpKoutput_checkbox, 'value') == 1
	fprintf(wfile, '、曲率 c');
end
fprintf(wfile, '\n');

% 根据选择输出相应的txt文件

for i = 1:size(handles.interpresult.interpcor, 1)
	if get(handles.interpPoutput_checkbox, 'value') == 1
		fprintf(wfile, '%f, %f, %f, %f, %f, %f', handles.interpresult.interpcor(i, 1), handles.interpresult.interpcor(i, 2), handles.interpresult.interpcor(i, 3), handles.interpresult.interpcor(i, 4), handles.interpresult.interpcor(i, 6), handles.interpresult.interpcor(i, 7));
	end

	if get(handles.interpVoutput_checkbox, 'value') == 1
		fprintf(wfile, ', %f', handles.interpresult.actualf(i));
	end

	if get(handles.interpPoutput_checkbox, 'value') == 1
		if i == 1
			acc = 0;
		else
			acc = (handles.interpresult.actualf(i) - handles.interpresult.actualf(i - 1)) / handles.interpolationperiod;
		end
		fprintf(wfile, '、%f', acc);
	end

	if get(handles.interpAoutput_checkbox, 'value') == 1
		fprintf(wfile, '、%f', handles.interpresult.curvature(i));
	end
	fprintf(wfile, '\n');
end
fclose(wfile);


function figure1_KeyPressFcn(hObject, eventdata, handles)
% 暗藏的一个按键，按下'delete'键后会关掉初主界面外的所有绘图
if strcmp(eventdata.Key, 'delete')
	h = findobj('type', 'figure', '-not', 'name', 'FiveAxisVirtualCNCSystem');
	close(h);
end


function uipanel38_CreateFcn(hObject, eventdata, handles)

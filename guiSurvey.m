function varargout = guiSurvey(varargin)
% GUISURVEY MATLAB code for guiSurvey.fig
%      GUISURVEY, by itself, creates a new GUISURVEY or raises the existing
%      singleton*.
%
%      H = GUISURVEY returns the handle to a new GUISURVEY or the handle to
%      the existing singleton*.
%
%      GUISURVEY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUISURVEY.M with the given input arguments.
%
%      GUISURVEY('Property','Value',...) creates a new GUISURVEY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiSurvey_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiSurvey_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiSurvey

% Last Modified by GUIDE v2.5 05-Nov-2014 01:00:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @guiSurvey_OpeningFcn, ...
    'gui_OutputFcn',  @guiSurvey_OutputFcn, ...
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

% only add the directory into path when it is not in the path to load GUI
% faster
pathCell = regexp(path, pathsep, 'split');
if ~any(strcmpi('./src', pathCell))
    addpath(genpath('./src'));
end


% --- Executes just before guiSurvey is made visible.
function guiSurvey_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiSurvey (see VARARGIN)

% Choose default command line output for guiSurvey
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guiSurvey wait for user response (see UIRESUME)
% uiwait(handles.figureMain);


% --- Outputs from this function are returned to the command line.
function varargout = guiSurvey_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btn_loadPWaveVelocityModel.
function btn_loadPWaveVelocityModel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_loadPWaveVelocityModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% load velocity model
[file, path] = uigetfile('*.mat', 'Select a velocity model');
if (~any([file, path])) % user pressed cancel button
    return;
end
load(fullfile(path, file));

dim = length(size(velocityModel));
vmin = min(velocityModel(:));
vmax = max(velocityModel(:));

%% enable objects
set(handles.edit_dx, 'Enable', 'on');
set(handles.edit_dz, 'Enable', 'on');
set(handles.edit_dt, 'Enable', 'on');
set(handles.edit_boundary, 'Enable', 'on');
set(handles.ppm_approxOrder, 'Enable', 'on');
set(handles.edit_centerFreq, 'Enable', 'on');
set(handles.edit_sx, 'Enable', 'on');
set(handles.edit_sz, 'Enable', 'on');
set(handles.ppm_sweepAll, 'Enable', 'on');
set(handles.ppm_receiveAll, 'Enable', 'on');
set(handles.btn_shot, 'Enable', 'on');

%% set finite difference setting values
dx = 10;
dz = 10;
dt = 0.5*(min([dx, dz])/vmax/sqrt(2));
[nz, nx, ~] = size(velocityModel);
nt = round((sqrt((dx*nx)^2 + (dz*nz)^2)*2/vmin/dt + 1));
x = (1:nx) * dx;
z = (1:nz) * dz;

nBoundary = 20;
nDiffOrder = 2;
f = 20;

sx = round(nx / 2);
sz = 1;

str_rx = sprintf('1:%d', nx);
str_rz = sprintf('%d', 1);

%% set values in edit texts
set(handles.edit_dx, 'String', num2str(dx));
set(handles.edit_dz, 'String', num2str(dz));
set(handles.edit_dt, 'String', num2str(dt));
set(handles.edit_nx, 'String', num2str(nx));
set(handles.edit_nz, 'String', num2str(nz));
set(handles.edit_nt, 'String', num2str(nt));
set(handles.edit_boundary, 'String', num2str(nBoundary));
set(handles.ppm_approxOrder, 'Value', nDiffOrder);
set(handles.edit_centerFreq, 'String', num2str(f));
set(handles.edit_sx, 'String', num2str(sx));
set(handles.edit_sz, 'String', num2str(sz));
set(handles.edit_rx, 'String', str_rx);
set(handles.edit_rz, 'String', str_rz);

% 3D case
if (dim > 2)
    % enable edit texts for y-axis
    set(handles.edit_dy, 'Enable', 'on');
    set(handles.edit_sy, 'Enable', 'on');
    % set finite difference setting values
    dy = 10;
    dt = 0.5*(min([dx, dy, dz])/vmax/sqrt(3));
    [~, ~, ny] = size(velocityModel);
    nt = round((sqrt((dx*nx)^2 + (dy*ny)^2 + (dz*nz)^2)*2/vmin/dt + 1));
    y = (1:ny) * dy;
    
    sy = round(ny / 2);
    
    str_ry = sprintf('1:%d', ny);
    
    % set values in edit texts for y-axis
    set(handles.edit_dy, 'String', num2str(dy));
    set(handles.edit_dt, 'String', num2str(dt));
    set(handles.edit_ny, 'String', num2str(ny));
    set(handles.edit_nt, 'String', num2str(nt));
    set(handles.edit_sy, 'String', num2str(sy));
    set(handles.edit_ry, 'String', str_ry);
end

%% plot velocity model
if (dim <= 2)	% 2D case
    imagesc(x, z, velocityModel, 'Parent', handles.axes_velocityModel);
    xlabel(handles.axes_velocityModel, 'Distance (m)'); ylabel(handles.axes_velocityModel, 'Depth (m)');
    title(handles.axes_velocityModel, 'Velocity Model');
    colormap(handles.axes_velocityModel, seismic);
else            % 3D case
    slice(handles.axes_velocityModel, x, y, z, permute(velocityModel, [2, 3, 1]), ...
        round(linspace(2 * dx, (size(velocityModel, 3)-1) * dx, 5)), ...
        round(linspace(2 * dy, (size(velocityModel, 2)-1) * dy, 5)), ...
        round(linspace(2 * dz, (size(velocityModel, 1)-1) * dz, 10)));
    xlabel(handles.axes_velocityModel, 'Distance (m)');
    ylabel(handles.axes_velocityModel, 'Distance (m)');
    zlabel(handles.axes_velocityModel, 'Depth (m)');
    title(handles.axes_velocityModel, 'Velocity Model');
    shading(handles.axes_velocityModel, 'interp');
    colormap(handles.axes_velocityModel, seismic);
end

%% share variables among callback functions
data = guidata(hObject);
data.velocityModel = velocityModel;
guidata(hObject, data); % hObject can be any object contained in the figure, including push button, edit text, popup menu, etc.


% --- Executes on button press in btn_shot.
function btn_shot_Callback(hObject, eventdata, handles)
% hObject    handle to btn_shot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% enable / disable objects
set(handles.btn_stop, 'Enable', 'on');
set(handles.btn_shot, 'Enable', 'off');

%% share variables among callback functions
data = guidata(hObject);
data.stopFlag = false;
guidata(hObject, data);

%% load parameter
data = guidata(hObject);
velocityModel = data.velocityModel;
dim = length(size(velocityModel));
[nz, nx, ~] = size(velocityModel);
dx = str2double(get(handles.edit_dx, 'String'));
dz = str2double(get(handles.edit_dz, 'String'));
dt = str2double(get(handles.edit_dt, 'String'));
nt = str2double(get(handles.edit_nt, 'String'));
x = (1:nx) * dx;
z = (1:nz) * dz;
t  = (0:nt-1).*dt;
nBoundary = str2double(get(handles.edit_boundary, 'String'));
nDiffOrder = get(handles.ppm_approxOrder, 'Value');
f = str2double(get(handles.edit_centerFreq, 'String'));
sx = eval(sprintf('[%s]', get(handles.edit_sx, 'String')));
sz = eval(sprintf('[%s]', get(handles.edit_sz, 'String')));
[szMesh, sxMesh] = meshgrid(sz, sx);
sMesh = [szMesh(:), sxMesh(:)];
nShots = size(sMesh, 1);
rx = eval(sprintf('[%s]', get(handles.edit_rx, 'String')));
rz = eval(sprintf('[%s]', get(handles.edit_rz, 'String')));

% 3D case
if (dim > 2)
    [~, ~, ny] = size(velocityModel);
    dy = str2double(get(handles.edit_dy, 'String'));
    y = (1:ny) * dy;
    sy = eval(sprintf('[%s]', get(handles.edit_sy, 'String')));
    [szMesh, sxMesh, syMesh] = meshgrid(sz, sx, sy);
    sMesh = [szMesh(:), sxMesh(:), syMesh(:)];
    nShots = size(sMesh, 1);
    ry = eval(sprintf('[%s]', get(handles.edit_ry, 'String')))
end

% add region around model for applying absorbing boundary conditions
V = extBoundary(velocityModel, nBoundary, dim);

for ixs = 1:nShots
    %% locating current source
    cur_sz = sMesh(ixs, 1);
    cur_sx = sMesh(ixs, 2);
    
    %% generate shot source field and shot record using FDTD
    sourceTime = zeros([size(V), nt]);
    wave1dTime = ricker(f, nt, dt);
    
    if (dim <= 2)	% 2D case
        % plot velocity model and shot position
        imagesc(x, z, velocityModel, 'Parent', handles.axes_velocityModel);
        xlabel(handles.axes_velocityModel, 'Distance (m)'); ylabel(handles.axes_velocityModel, 'Depth (m)');
        title(handles.axes_velocityModel, 'Velocity Model');
        colormap(handles.axes_velocityModel, seismic);
        hold(handles.axes_velocityModel, 'on');
        plot(handles.axes_velocityModel, cur_sx * dx, cur_sz * dz, 'w*');
        hold(handles.axes_velocityModel, 'off');
        
        sourceTime(cur_sz, cur_sx+nBoundary, :) = reshape(wave1dTime, 1, 1, nt);
        [dataTrue, snapshotTrue] = fwdTimeCpmlFor2dAw(V, sourceTime, nDiffOrder, nBoundary, dz, dx, dt);
    else            % 3D case
        slice(handles.axes_velocityModel, x, y, z, permute(velocityModel, [2, 3, 1]), ...
            round(linspace(2 * dx, (size(velocityModel, 3)-1) * dx, 5)), ...
            round(linspace(2 * dy, (size(velocityModel, 2)-1) * dy, 5)), ...
            round(linspace(2 * dz, (size(velocityModel, 1)-1) * dz, 10)));
        xlabel(handles.axes_velocityModel, 'Distance (m)');
        ylabel(handles.axes_velocityModel, 'Distance (m)');
        zlabel(handles.axes_velocityModel, 'Depth (m)');
        title(handles.axes_velocityModel, 'Velocity Model');
        shading(handles.axes_velocityModel, 'interp');
        colormap(handles.axes_velocityModel, seismic);
        cur_sy = sMesh(ixs, 3);
        
        hold(handles.axes_velocityModel, 'on');
        plot3(handles.axes_velocityModel, cur_sx * dx, cur_sy * dy, cur_sz * dz, 'k*');
        hold(handles.axes_velocityModel, 'off');
        
        sourceTime(cur_sz, cur_sx+nBoundary, cur_sy+nBoundary, :) = reshape(wave1dTime, 1, 1, 1, nt);
        [dataTrue, snapshotTrue] = fwdTimeCpmlFor3dAw(V, sourceTime, nDiffOrder, nBoundary, dz, dx, dy, dt);
    end
    
    %% plot figures into axes
    for it = 1:nt
        % stop plotting when hObject becomes invalid (due to its deletion)
        if (~ishandle(hObject))
            return;
        end
        
        % stop plotting when stop button has been pushed
        data = guidata(hObject);
        if (data.stopFlag)
            return;
        end
        
        if (dim <= 2)	% 2D case
            plot(handles.axes_sourceTime, [1:nt], wave1dTime); hold(handles.axes_sourceTime, 'on');
            plot(handles.axes_sourceTime, it, wave1dTime(it), 'r*'); hold(handles.axes_sourceTime, 'off');
            xlim(handles.axes_sourceTime, [1, nt]);
            xlabel(handles.axes_sourceTime, 'Time'); ylabel(handles.axes_sourceTime, 'Amplitude');
            title(handles.axes_sourceTime, sprintf('Shot at x = %dm', cur_sx));
            colormap(handles.axes_sourceTime, seismic);
            
            dataDisplay = zeros(nt, nx);
            dataDisplay(1:it, rx) = dataTrue(rx+nBoundary, 1:it).';
            imagesc(x, t, dataDisplay, 'Parent', handles.axes_data, [-0.1 0.1]);
            xlabel(handles.axes_data, 'Distance (m)'); ylabel(handles.axes_data, 'Time (s)');
            title(handles.axes_data, 'Shot Record (True)');
            
            imagesc(x, z, snapshotTrue(1:end-nBoundary, nBoundary+1:end-nBoundary, it), 'Parent', handles.axes_snapshot, [-0.14 1]);
            xlabel(handles.axes_snapshot, 'Distance (m)'); ylabel(handles.axes_snapshot, 'Depth (m)');
            title(handles.axes_snapshot, sprintf('Wave Propagation (True) t = %.3fs', t(it)));
        else            % 3D case
            
        end
        
        drawnow;
    end
    
end

%% enable / disable objects
set(handles.btn_shot, 'Enable', 'on');
set(handles.btn_stop, 'Enable', 'off');


% --- Executes on button press in btn_stop.
function btn_stop_Callback(hObject, eventdata, handles)
% hObject    handle to btn_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% enable / disable objects
set(handles.btn_shot, 'Enable', 'on');
set(handles.btn_stop, 'Enable', 'off');

%% share variables among callback functions
data = guidata(hObject);
data.stopFlag = true;
guidata(hObject, data);


function edit_dx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dx as text
%        str2double(get(hObject,'String')) returns contents of edit_dx as a double

data = guidata(hObject);
velocityModel = data.velocityModel;
dim = length(size(velocityModel));
vmin = min(velocityModel(:));
vmax = max(velocityModel(:));

dx = str2double(get(handles.edit_dx, 'String'));
dz = str2double(get(handles.edit_dz, 'String'));
dt = 0.5*(min([dx, dz])/vmax/sqrt(2));
[nz, nx, ~] = size(velocityModel);
nt = round((sqrt((dx*nx)^2 + (dz*nz)^2)*2/vmin/dt + 1));
set(handles.edit_dt, 'String', num2str(dt));
set(handles.edit_nt, 'String', num2str(nt));

% 3D case
if (dim > 2)
    dy = str2double(get(handles.edit_dy, 'String'));
    dt = 0.5*(min([dx, dy, dz])/vmax/sqrt(3));
    [~, ~, ny] = size(velocityModel);
    nt = round((sqrt((dx*nx)^2 + (dy*ny)^2 + (dz*nz)^2)*2/vmin/dt + 1));
    set(handles.edit_dt, 'String', num2str(dt));
    set(handles.edit_nt, 'String', num2str(nt));
end


% --- Executes during object creation, after setting all properties.
function edit_dx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_dy_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dy as text
%        str2double(get(hObject,'String')) returns contents of edit_dy as a double

% only happen in 3D case
data = guidata(hObject);
velocityModel = data.velocityModel;
vmin = min(velocityModel(:));
vmax = max(velocityModel(:));

dx = str2double(get(handles.edit_dx, 'String'));
dy = str2double(get(handles.edit_dy, 'String'));
dz = str2double(get(handles.edit_dz, 'String'));
dt = 0.5*(min([dx, dy, dz])/vmax/sqrt(3));
[nz, nx, ny] = size(velocityModel);
nt = round((sqrt((dx*nx)^2 + (dy*ny)^2 + (dz*nz)^2)*2/vmin/dt + 1));
set(handles.edit_dt, 'String', num2str(dt));
set(handles.edit_nt, 'String', num2str(nt));


% --- Executes during object creation, after setting all properties.
function edit_dy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_dz_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dz as text
%        str2double(get(hObject,'String')) returns contents of edit_dz as a double

data = guidata(hObject);
velocityModel = data.velocityModel;
dim = length(size(velocityModel));
vmin = min(velocityModel(:));
vmax = max(velocityModel(:));

dx = str2double(get(handles.edit_dx, 'String'));
dz = str2double(get(handles.edit_dz, 'String'));
dt = 0.5*(min([dx, dz])/vmax/sqrt(2));
[nz, nx, ~] = size(velocityModel);
nt = round((sqrt((dx*nx)^2 + (dz*nz)^2)*2/vmin/dt + 1));
set(handles.edit_dt, 'String', num2str(dt));
set(handles.edit_nt, 'String', num2str(nt));

% 3D case
if (dim > 2)
    dy = str2double(get(handles.edit_dy, 'String'));
    dt = 0.5*(min([dx, dy, dz])/vmax/sqrt(3));
    [~, ~, ny] = size(velocityModel);
    nt = round((sqrt((dx*nx)^2 + (dy*ny)^2 + (dz*nz)^2)*2/vmin/dt + 1));
    set(handles.edit_dt, 'String', num2str(dt));
    set(handles.edit_nt, 'String', num2str(nt));
end


% --- Executes during object creation, after setting all properties.
function edit_dz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_dt_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dt as text
%        str2double(get(hObject,'String')) returns contents of edit_dt as a double

data = guidata(hObject);
velocityModel = data.velocityModel;
dim = length(size(velocityModel));
vmin = min(velocityModel(:));
vmax = max(velocityModel(:));

dx = str2double(get(handles.edit_dx, 'String'));
dz = str2double(get(handles.edit_dz, 'String'));
dt = str2double(get(handles.edit_dt, 'String'));
[nz, nx, ~] = size(velocityModel);
nt = round((sqrt((dx*nx)^2 + (dz*nz)^2)*2/vmin/dt + 1));
set(handles.edit_nt, 'String', num2str(nt));

% 3D case
if (dim > 2)
    dy = str2double(get(handles.edit_dy, 'String'));
    dt = str2double(get(handles.edit_dt, 'String'));
    [~, ~, ny] = size(velocityModel);
    nt = round((sqrt((dx*nx)^2 + (dy*ny)^2 + (dz*nz)^2)*2/vmin/dt + 1));
    set(handles.edit_nt, 'String', num2str(nt));
end


% --- Executes during object creation, after setting all properties.
function edit_dt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_nx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_nx as text
%        str2double(get(hObject,'String')) returns contents of edit_nx as a double


% --- Executes during object creation, after setting all properties.
function edit_nx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ny_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ny (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ny as text
%        str2double(get(hObject,'String')) returns contents of edit_ny as a double


% --- Executes during object creation, after setting all properties.
function edit_ny_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ny (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_nz_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_nz as text
%        str2double(get(hObject,'String')) returns contents of edit_nz as a double


% --- Executes during object creation, after setting all properties.
function edit_nz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_nt_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_nt as text
%        str2double(get(hObject,'String')) returns contents of edit_nt as a double


% --- Executes during object creation, after setting all properties.
function edit_nt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menuHelp_Callback(hObject, eventdata, handles)
% hObject    handle to menuHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuHelpAbout_Callback(hObject, eventdata, handles)
% hObject    handle to menuHelpAbout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guiAbout;


function edit_boundary_Callback(hObject, eventdata, handles)
% hObject    handle to edit_boundary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_boundary as text
%        str2double(get(hObject,'String')) returns contents of edit_boundary as a double


% --- Executes during object creation, after setting all properties.
function edit_boundary_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_boundary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ppm_approxOrder.
function ppm_approxOrder_Callback(hObject, eventdata, handles)
% hObject    handle to ppm_approxOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ppm_approxOrder contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ppm_approxOrder


% --- Executes during object creation, after setting all properties.
function ppm_approxOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ppm_approxOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_centerFreq_Callback(hObject, eventdata, handles)
% hObject    handle to edit_centerFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_centerFreq as text
%        str2double(get(hObject,'String')) returns contents of edit_centerFreq as a double


% --- Executes during object creation, after setting all properties.
function edit_centerFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_centerFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_sx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sx as text
%        str2double(get(hObject,'String')) returns contents of edit_sx as a double


% --- Executes during object creation, after setting all properties.
function edit_sx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_sy_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sy as text
%        str2double(get(hObject,'String')) returns contents of edit_sy as a double


% --- Executes during object creation, after setting all properties.
function edit_sy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_sz_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sz as text
%        str2double(get(hObject,'String')) returns contents of edit_sz as a double


% --- Executes during object creation, after setting all properties.
function edit_sz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ppm_sweepAll.
function ppm_sweepAll_Callback(hObject, eventdata, handles)
% hObject    handle to ppm_sweepAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ppm_sweepAll contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ppm_sweepAll

data = guidata(hObject);
velocityModel = data.velocityModel;
dim = length(size(velocityModel));
[nz, nx, ~] = size(velocityModel);

isSweepAll = get(hObject, 'Value');
if (isSweepAll == 1) % Yes
    str_sx = sprintf('1:%d', nx);
    set(handles.edit_sx, 'String', str_sx);
    set(handles.edit_sx, 'Enable', 'off');
    set(handles.edit_sz, 'Enable', 'off');
end
if (isSweepAll == 2) % No
    set(handles.edit_sx, 'Enable', 'on');
    set(handles.edit_sz, 'Enable', 'on');
end

% 3D case
if (dim > 2)
    [~, ~, ny] = size(velocityModel);
    if (isSweepAll == 1) % Yes
        str_sy = sprintf('1:%d', ny);
        set(handles.edit_sy, 'String', str_sy);
        set(handles.edit_sy, 'Enable', 'off');
    end
    if (isSweepAll == 2) % No
        set(handles.edit_sy, 'Enable', 'on');
    end
end


% --- Executes during object creation, after setting all properties.
function ppm_sweepAll_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ppm_sweepAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ppm_receiveAll.
function ppm_receiveAll_Callback(hObject, eventdata, handles)
% hObject    handle to ppm_receiveAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ppm_receiveAll contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ppm_receiveAll

data = guidata(hObject);
velocityModel = data.velocityModel;
[nz, nx, ~] = size(velocityModel);
dim = length(size(velocityModel));

isReceiveAll = get(hObject, 'Value');
if (isReceiveAll == 1) % Yes
    set(handles.edit_rx, 'Enable', 'off');
end
if (isReceiveAll == 2) % No
    set(handles.edit_rx, 'Enable', 'on');
end

% 3D case
if (dim > 2)
    [~, ~, ny] = size(velocityModel);
    if (isReceiveAll == 1) % Yes
        set(handles.edit_ry, 'Enable', 'off');
    end
    if (isReceiveAll == 2) % No
        set(handles.edit_ry, 'Enable', 'on');
        str_ry = sprintf('1:%d', ny);
        set(handles.edit_ry, 'String', str_ry);
    end
end


% --- Executes during object creation, after setting all properties.
function ppm_receiveAll_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ppm_receiveAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rx as text
%        str2double(get(hObject,'String')) returns contents of edit_rx as a double


% --- Executes during object creation, after setting all properties.
function edit_rx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ry_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ry as text
%        str2double(get(hObject,'String')) returns contents of edit_ry as a double


% --- Executes during object creation, after setting all properties.
function edit_ry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rz_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rz as text
%        str2double(get(hObject,'String')) returns contents of edit_rz as a double


% --- Executes during object creation, after setting all properties.
function edit_rz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figureMain.
function figureMain_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figureMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

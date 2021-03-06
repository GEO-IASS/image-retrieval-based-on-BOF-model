function varargout = cbires(varargin)
% CBIRES MATLAB code for cbires.fig
%      CBIRES, by itself, creates a new CBIRES or raises the existing
%      singleton*.
%
%      H = CBIRES returns the handle to a new CBIRES or the handle to
%      the existing singleton*.
%
%      CBIRES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CBIRES.M with the given input arguments.
%
%      CBIRES('Property','Value',...) creates a new CBIRES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cbires_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cbires_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cbires

% Last Modified by GUIDE v2.5 10-Feb-2015 17:01:22

clc;
ini;
detect_opts=[];descriptor_opts=[];dictionary_opts=[];assignment_opts=[];ada_opts=[];

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @cbires_OpeningFcn, ...
    'gui_OutputFcn',  @cbires_OutputFcn, ...
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


% --- Executes just before cbires is made visible.
function cbires_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cbires (see VARARGIN)

% Choose default command line output for cbires
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cbires wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cbires_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btn_BrowseImage.
function btn_BrowseImage_Callback(hObject, eventdata, handles)
% hObject    handle to btn_BrowseImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ini;
[query_fname, query_pathname] = uigetfile('*.jpg; *.png; *.bmp', 'Select query image');

if (query_fname ~= 0)
    query_fullpath = strcat(query_pathname, query_fname);
    [pathstr, name, ext] = fileparts(query_fullpath); % fiparts returns char type
    
    if ( strcmp(lower(ext), '.jpg') == 1 || strcmp(lower(ext), '.png') == 1 ...
            || strcmp(lower(ext), '.bmp') == 1 )
        %% Descriptors
        descriptor_opts.type='sift';                                                     % name descripto
        descriptor_opts.name=['des',descriptor_opts.type]; % output name (combines detector and descrtiptor name)
        descriptor_opts.patchSize=16;                                                   % normalized patch size
        descriptor_opts.gridSpacing=8; 
        descriptor_opts.maxImageSize=600;
        SiftDescriptor = GenerateSiftDescriptor( fullfile( pathstr, strcat(name, ext) ),descriptor_opts );
        
        %% assignment
        vocabulary=getfield(load(strcat(rootpath,'\data\global\sift_dictionary.mat')),'dictionary');
        queryImageFeature = do_assign(SiftDescriptor,vocabulary);
        
        % update handles
        handles.queryImageFeature = queryImageFeature;
        queryImage_name=query_fullpath;
        handles.queryImage_name=queryImage_name;
        guidata(hObject, handles);
       helpdlg('Proceed with the query by executing the green button!');
        
        % Clear workspace
        clear all;
    else
        errordlg('You have not selected the correct file type');
    end
else
    return;
end


% --- Executes on selection change in popupmenu_DistanceFunctions.
function popupmenu_DistanceFunctions_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_DistanceFunctions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_DistanceFunctions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_DistanceFunctions

handles.DistanceFunctions = get(handles.popupmenu_DistanceFunctions, 'Value');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu_DistanceFunctions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_DistanceFunctions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in btnSelectImageDirectory.
function btnSelectImageDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to btnSelectImageDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% select image directory
folder_name = uigetdir(pwd, 'Select the directory of images');
if ( folder_name ~= 0 )
    handles.folder_name = folder_name;
    guidata(hObject, handles);
else
    return;
end


% --- Executes on button press in btnCreateDB.
function btnCreateDB_Callback(hObject, eventdata, handles)
% hObject    handle to btnCreateDB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (~isfield(handles, 'folder_name'))
    errordlg('Please select an image directory first!');
    return;
end

createDB(handles.folder_name);

% --- Executes on button press in btn_LoadDataset.
function btn_LoadDataset_Callback(hObject, eventdata, handles)
% hObject    handle to btn_LoadDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fname, pthname] = uigetfile('*.mat', 'Select the Dataset');
if (fname ~= 0)
    dataset_fullpath = strcat(pthname, fname);
    [pathstr, name, ext] = fileparts(dataset_fullpath);
    if ( strcmp(lower(ext), '.mat') == 1)
        filename = fullfile( pathstr, strcat(name, ext) );
        handles.imageDataset = load(filename);
        guidata(hObject, handles);
        % make dataset visible from workspace
        % assignin('base', 'database', handles.imageDataset.dataset);
        helpdlg('Dataset loaded successfuly!');
    else
        errordlg('You have not selected the correct file type');
    end
else
    return;
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over btn_BrowseImage.
function btn_BrowseImage_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to btn_BrowseImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function axesPrimary_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesPrimary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axesPrimary

% --- Executes on selection change in popupmenu_query_descriptors.
function popupmenu_query_descriptors_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_query_descriptors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_query_descriptors contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_query_descriptors
handles.query_descriptors = get(handles.popupmenu_query_descriptors, 'Value');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_query_descriptors_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_query_descriptors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_train_descriptors.
function popupmenu_train_descriptors_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_train_descriptors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_train_descriptors contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_train_descriptors
handles.train_descriptors = get(handles.popupmenu_train_descriptors, 'Value');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_train_descriptors_CreateFcn(hObject, eventdata, ~)
% hObject    handle to popupmenu_train_descriptors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_dictionarysize_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dictionarysize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dictionarysize as text
%        str2double(get(hObject,'String')) returns contents of edit_dictionarysize as a double
handles.dictionarySize = get(handles.edit_dictionarysize, 'Value');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_dictionarysize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dictionarysize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_query.
function pushbutton_query_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_query (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);
if (~isfield(handles, 'queryImageFeature'))
    errordlg('Please select an image first, then choose your similarity metric and num of returned images!');
    return;
end

% check for dataset existence
if (~isfield(handles, 'imageDataset'))
    errordlg('Please load a dataset first. If you dont have one then you should consider creating one!');
    return;
end

% set variables
if (~isfield(handles, 'DistanceFunctions') && ~isfield(handles, 'NumOfImages'))
    Dist_metric = get(handles.popupmenu_DistanceFunctions, 'Value');
    Img_metric = get(handles.popupmenu_NumOfImages, 'Value');
elseif (~isfield(handles, 'DistanceFunctions') || ~isfield(handles, 'NumOfImages'))
    if (~isfield(handles, 'DistanceFunctions'))
        Dist_metric = get(handles.popupmenu_DistanceFunctions, 'Value');
        NumOfImages = handles.NumOfImages;
    else
        Dist_metric = handles.DistanceFunctions;
        Img_metric = get(handles.popupmenu_NumOfImages, 'Value');
    end
else
    Dist_metric = handles.DistanceFunctions;
    NumOfImages = handles.NumOfImages;
end


switch Img_metric
    case 1
        NumOfImages=20;
    case 2
        NumOfImages=30;
    case 3
        NumOfImages=40;
    otherwise
        errordlg('Error image number!');
end

if (Dist_metric == 1)
    L1(NumOfImages, handles.queryImageFeature, handles.queryImage_name,handles.imageDataset.featureDictionary);
end


% --- Executes on selection change in popupmenu_NumOfImages.
function popupmenu_NumOfImages_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_NumOfImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_NumOfImages contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_NumOfImages
% metric=get(handles.popupmenu_NumOfImages, 'Value');
% switch metric
%     case 1
%         handles.NumOfImages=20;
%     case 2
%         handles.NumOfImages=30;
%     case 3
%         handles.NumOfImages=40;
%     otherwise
%         errordlg('Error image number!');
% end
handles.NumOfImages = get(handles.popupmenu_NumOfImages, 'Value');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_NumOfImages_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_NumOfImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

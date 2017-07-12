function varargout = NEXAFS_FIT_GUI(varargin)
% NEXAFS_FIT_GUI M-file for NEXAFS_FIT_GUI.fig
%      NEXAFS_FIT_GUI, by itself, creates a new NEXAFS_FIT_GUI or raises the existing
%      singleton*.
%
%      H = NEXAFS_FIT_GUI returns the handle to a new NEXAFS_FIT_GUI or the handle to
%      the existing singleton*.
%
%      NEXAFS_FIT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEXAFS_FIT_GUI.M with the given input arguments.
%
%      NEXAFS_FIT_GUI('Property','Value',...) creates a new NEXAFS_FIT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NEXAFS_FIT_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NEXAFS_FIT_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NEXAFS_FIT_GUI

% Last Modified by GUIDE v2.5 20-May-2010 14:39:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NEXAFS_FIT_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @NEXAFS_FIT_GUI_OutputFcn, ...
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


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes just before NEXAFS_FIT_GUI is made visible.
function NEXAFS_FIT_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
%__________________________________________________________________________
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NEXAFS_FIT_GUI (see VARARGIN)
%__________________________________________________________________________


% Choose default command line output for NEXAFS_FIT_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Initialize the tables with an empty array
inarr=[];
set(handles.fitparameter,'Data',inarr);
set(handles.filtered_spectrum,'Data',inarr);
set(handles.spectrum,'Data',inarr);
set(handles.fit_output_table,'Data',inarr);

% Initialize the popup menu with the two possible choices
fit_choice={'Raw Spectrum'; 'Filtered Spectrum'};
set(handles.fit_what,'String',fit_choice);

% Initialize the edit texts "Peaknumber", "Min. [eV]" and "Max. [eV]"
% with the string "-", symbolizing that there is no input
set(handles.peaknumber,'String','-');
set(handles.max_value,'String','-');
set(handles.min_value,'String','-');


% Initialize the checkboxes
% By default box for axes 1 will be checked and the one for axes 2
% unchecked. Value is saved as application-data, so it can be used later on
% as default value. This has to be done, so it can be used for deciding
% where to plot, when no interaction by user with the checkboxes has
% occured.
set(handles.cbox_axes1,'Value',1);
cbox_axes1=get(handles.cbox_axes1,'Value');
setappdata(handles.cbox_axes1,'cbox1',cbox_axes1);
set(handles.cbox_axes2,'Value',0);

% Box for Carbon K-edge will be checked, since main application for
% this GUI will be the fitting of Carbon - NEXAFS - spectra.
set(handles.cbox_carbon,'Value',1);
carbonstruct=struct('cbox',[],'newconsts',[]);
carbonstruct.cbox=get(handles.cbox_carbon,'Value');
carbonstruct.newconsts{1,1}=0.575;
carbonstruct.newconsts{2,1}=-164.75;
setappdata(handles.cbox_carbon,'carbonstruct',carbonstruct);

% UIWAIT makes NEXAFS_FIT_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Outputs from this function are returned to the command line.
function varargout = NEXAFS_FIT_GUI_OutputFcn(hObject, eventdata, handles) 
%__________________________________________________________________________
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


% Get default command line output from handles structure
varargout{1} = handles.output;


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes on button press in cbox_axes1.
function cbox_axes1_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to cbox_axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________
% Hint: get(hObject,'Value') returns toggle state of cbox_axes1
%__________________________________________________________________________


% Get toggle state of checkbox and save it as application-data.
cbox_axes1=get(handles.cbox_axes1,'Value');
setappdata(handles.cbox_axes1,'cbox1',cbox_axes1);
% Uncheck box for axes 2, if the one for axes 1 is checked and save
% the state as application data. This way you make sure, that only
% one of the boxes is checked.
if cbox_axes1==1
    set(handles.cbox_axes2,'Value',0);
    setappdata(handles.cbox_axes2,'cbox2',get(handles.cbox_axes2,'Value'));
end


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes on button press in cbox_axes2.
function cbox_axes2_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to cbox_axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________
% Hint: get(hObject,'Value') returns toggle state of cbox_axes2
%__________________________________________________________________________


% Get toggle state of checkbox and save it as application-data.
cbox_axes2=get(handles.cbox_axes2,'Value');
setappdata(handles.cbox_axes2,'cbox2',cbox_axes2);
% Uncheck box for axes 1, if the one for axes 2 is checked and save
% the state as application data. This way you make sure, that only
% one of the boxes is checked.
if cbox_axes2==1
    set(handles.cbox_axes1,'Value',0);
    setappdata(handles.cbox_axes1,'cbox1',get(handles.cbox_axes1,'Value'));
end


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes on button press in sort_by_energy.
function sort_by_energy_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to sort_by_energy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


% Get the fit parameter from the table called "fitparameter", par is
% retrieved as a cell
par=get(handles.fitparameter,'Data');

% if no parameter exist, the call to the "sort by energy" - function
% will be ignored
if isempty(par)
else
    % get the size of the cell, the parameter are stored in
    sizep=size(par);
    % find the indices of the cell par without/with an entry for the field
    % "Position"; create an array with zeros to increase performance
    % beforehand
    a=zeros(sizep(1,1),1);
    
    for i=1:sizep(1,1)
        if isempty(par{i,3})
            a(i)=0;
        else a(i)=1;
        end
    end

    ind1=find(a ~=0);
    ind2=find(a ==0);

    % get the length of the arrays with indices and create according to the
    % length new cells
    lind1=length(ind1);
    lind2=sizep(1,1)-lind1;
    newpar1=cell(lind1,6);
    newpar2=cell(lind2,6);

    % load the new cells with data of the original cell
    for i=1:lind1
        newpar1(i,:)=par(ind1(i),:);
    end

    % for cells without an entry for "Position" the peaknumber gets overwritten
    % with a new value, so that the are in the correct order
    for i=1:lind2
        newpar2(i,:)=par(ind2(i),:);
        newpar2{i,1}=lind1+i;
    end

    % cell with an entry get sorted by the value of energy and get also a new
    % value for the peaknumber
    newpar1=sortrows(newpar1,3);

    for i=1:lind1
        newpar1{i,1}=i;
    end

    % the sorted cells are put together into the old cell
    par(1:lind1,:)=newpar1;
    par(lind1+1:sizep(1,1),:)=newpar2;

    % the cell with now sorted entries is put back into the table
    % "fitparameter"
    set(handles.fitparameter,'Data',par);
end

%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes on button press in add_peak.
function add_peak_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to add_peak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


% get the data for the fit parameter from the table "fitparameter"
par=get(handles.fitparameter,'Data');
% find out the size of the cell and add "+1" to the number of rows
% (which is a representative of the number of peaks used to fit) 
sizep=size(par);
N=sizep(1,1)+1;
% save this new value as applicationdata "peaknumber", so it can be used in
% "delete_peak_callback"
setappdata(handles.peaknumber,'peaknumber',N);
% Create the fields of the new row
par{N,1}=N;
par{N,2}='Gaussian Fct.';
par{N,6}='-';
% display the new cell in the table "fitparameter"
set(handles.fitparameter,'Data',par)
% display this new number of peaks in the edit box "peaknumber"
N=num2str(N);
set(handles.peaknumber,'String',N);


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes on button press in delete_peak.
function delete_peak_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to delete_peak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


% get the actual number of peaks used to fit, if it is zero, do nothing,
% else start the delete_peak algorithm
peaknumber=getappdata(handles.peaknumber,'peaknumber');

if peaknumber==0
else
    % get the fit parameter from the table "fitparameter" and get the size
    % of the cell the data is stored in
    par=get(handles.fitparameter,'Data');
    sizep=size(par);
    % get the indices of the selected rows in the table "fitparameter",
    % these indices decide, which rows will be deleted
    sel=getappdata(handles.delete_peak,'sel');
    % if there weren't any rows selected at all, display an error message;
    if isempty(sel)
        errordlg('You must select at least one cell of the row(s) you want to delete!','Input Argument Error!')
    else
        % get the length of the indices ( which is equal to the number of
        % rows to be deleted) and the actual number of rows in the fit
        % parameter cell
        lsel=length(sel);
        N=sizep(1,1);
        % "Nnew" is the ne number of rows and is saved for further use 
        Nnew=sizep(1,1)-lsel;
        setappdata(handles.peaknumber,'peaknumber',Nnew);
        
        % The rows, which will be deleted, are branded by writing a zero
        % into their first column vector
        for i=1:lsel
            par{sel(i),1}=0;
        end
        
        % Create a cell for the fit parameter with the new size
        newpar=cell(Nnew,6);
        j=1;
        
        % load the old rows, which shouldn't be deleted, into the new cell
        % and change the "peaknumber" accordingly
        for i=1:1:N
           if par{i,1}~=0
                newpar{j,1}=j;
                newpar{j,2}=par{i,2};
                newpar{j,3}=par{i,3};
                newpar{j,4}=par{i,4};
                newpar{j,5}=par{i,5};
                newpar{j,6}=par{i,6};
                j=j+1;
           end
        end
        % put the new cell into the table "fitparameter" and the new number of peaks into the edit
        % text "peaknumber"
        set(handles.fitparameter,'Data',newpar);
        Nnew=num2str(Nnew);
        set(handles.peaknumber,'String',Nnew);
    end
end


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function peaknumber_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to peaknumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________
% Hints: get(hObject,'String') returns contents of peaknumber as text
%        str2double(get(hObject,'String')) returns contents of peaknumber as a double
%__________________________________________________________________________


% Validate that the text in the field converts to integer number
N = str2double(get(hObject,'String'));
setappdata(handles.peaknumber,'peaknumber',N); % saved for further use in "delete_peak_callback"
upN=ceil(N); % rounds the number up
downN=floor(N); % rounds the number down
diffN=upN-downN;
if isnan(N) || ~isreal(N) || diffN~=0  
    % isdouble returns NaN for non-numbers and N cannot be complex and must
    % be integer
    % Display error message
    errordlg('Invalid input, input must be an integer','Input Argument Error!')
else 
    % creates cell with the size indicated by the input for edit text
    % "peaknumber"
     par=cell(N,6);
    for i=1:1:N
        par{i,1}=i;
        par{i,2}='Gaussian Fct.';
        par{i,6}='-';
    end  
    % display initial data cell in table "fitparameter"
    set(handles.fitparameter,'Data',par)
end


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes during object creation, after setting all properties.
function peaknumber_CreateFcn(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to peaknumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%__________________________________________________________________________
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%__________________________________________________________________________


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes on button press in cbox_carbon.
function cbox_carbon_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to cbox_carbon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________
% Hint: get(hObject,'Value') returns toggle state of cbox_carbon
%__________________________________________________________________________


% Get toggle state of checkbox and save it as application-data in a struct.
% The struct will be later used to change the constants in the asymm.
% Gaussian function, if necessary. Nevertheless it will be only changed,
% when the checkbox is unchecked (having the value = 0).
carbonstruct=getappdata(handles.cbox_carbon,'carbonstruct');
carbonstruct.cbox=get(handles.cbox_carbon,'Value');
carbonbox=carbonstruct.cbox;

% save the new constants and the toggle state of the checkbox as
% application data. The data is saved as a struct. The new constants will
% be only used, when the corresponding toggle state is set to zero,
% indicating a different energy region than the carbon k-edge.
if carbonbox == 0
    % get handles of checkbox for carbon k - edge
    h_cbox=hObject;
    % apply the "C_K_Edge" function, that will open a figure demanding user
    % input
    hfig=C_K_Edge(h_cbox,carbonstruct.newconsts);
    % the GUI waits as long as there has been input into the figure,
    % created by "C_K_Edge" function
    uiwait(hfig);
    % get the data, saved as a struct, created by "C_K_Edge" function
    struct=getappdata(h_cbox,'Consts');
    carbonstruct.newconsts=struct.carbonstruct.newconsts;
    carbonbox=struct.carbonstruct.cbox;
    set(handles.cbox_carbon,'Value',carbonbox);
    setappdata(handles.cbox_carbon,'carbonstruct',carbonstruct);
else
    setappdata(handles.cbox_carbon,'carbonstruct',carbonstruct);
end


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes on button press in load_spec.
function load_spec_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to load_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% get filename and path for spectrum, you wanna load
[filename, pathname] = uigetfile({'*.txt';'*.mat'},'Load Spectrum');


if pathname==0
else
    % change current directory to the pathname
    cd(pathname);
    % get name and extension of the file
    [path,name,ext] = fileparts(filename);

    % according to the file - extension the file is loaded and checked, if it's
    % a spectrum. If not, a error dialog box is opened. If yes, the spectrum is
    % saved as application data and displayed in the table "Spectrum".
    switch ext 
                 case '.txt'
                        spec=load(filename);
                        specsize=size(spec);
                        if specsize(1,2)==2 && length(spec(:,1))==length(spec(:,2))
                        setappdata(handles.load_spec,'spec',spec);
                        set(handles.spectrum, 'Data',spec);
                        else 
                             errordlg('Input argument is not a spec, or not in the right form','Input Argument Error!')
                        end  
                        % display filepath and filename in static texts next to
                        % the table "spectrum" so that user knows which
                        % spectrum is used by the program at the moment.
                        set(handles.filename,'String',filename);
                        set(handles.filepath,'String',pathname);
                        Raw_Spec=struct('filename',filename,'pathname',pathname,'spec',spec);
                        % save "filename", "path" and "spec" as "Raw_Spec" in struct "FIT"
                        FIT.Raw_Spec=Raw_Spec;
                        setappdata(handles.fit_output_table,'FIT',FIT);
                        % since loading of .mat - files can result in loading
                        % of several variables into the workspace, it has to be
                        % checked if the loaded file is a struct or not. In
                        % case it is, all variables in the struct are displayed
                        % and the user is asked to look for the wanted spectrum
                        % in this list. 
                case '.mat'
                        matfile=load(filename);
                        % test if matfile is a struct
                        test=isstruct(matfile);
                        % if "matfile" is no struct, it has only one entry and
                        % can be loaded without further user-input needed
                        if test ~=1
                        spec=evalin('base',name); % searches the workspace for the variable, determined by name
                        specsize=size(spec);
                            % check if variable is a spectrum
                            if specsize(1,2)==2 && length(spec(:,1))==length(spec(:,2))
                            setappdata(handles.load_spec,'spec',spec);
                            set(handles.spectrum, 'Data',spec);
                            else 
                                 errordlg('Input argument is not a spec, or not in the right form','Input Argument Error!')
                            end  
                            % display filepath and filename in static texts next to
                            % the table "spectrum" so that user knows which
                            % spectrum is used by the program at the moment.
                            set(handles.filename,'String',filename);
                            set(handles.filepath,'String',pathname);
                            Raw_Spec=struct('filename',filename,'pathname',pathname,'spec',spec);
                            % save "filename", "path" and "spec" as "Raw_Spec" in struct "FIT"
                            FIT.Raw_Spec=Raw_Spec;
                            setappdata(handles.fit_output_table,'FIT',FIT);
                            % in case "matfile" is a struct get the fieldnames
                            % of the struct and display them in
                            % "spec_matfile_struct" - function and make the
                            % user search for the spectrum in  this list
                        else strentries=fieldnames(matfile);                        
                            var{1,1}='-';
                            hfig=spec_matfile_struct(strentries,handles.load_spec);
                            uiwait(hfig);
                            var{1,1}=getappdata(handles.load_spec,'filesel'); 
                            % if the user finds the spectrum in the struct, the
                            % file is loaded and checked, whether or not it is
                            % really a spectrum
                            if ~strcmp(var{1,1},'-')
                                spec=getfield(matfile,var{1,1}); % searches the workspace for the variable, determined by name
                                specsize=size(spec);
                                if specsize(1,2)==2 && length(spec(:,1))==length(spec(:,2))
                                setappdata(handles.load_spec,'spec',spec);
                                set(handles.spectrum, 'Data',spec);
                                else 
                                     errordlg('Input argument is not a spec, or not in the right form','Input Argument Error!')
                                end   
                                specstring=['struct: ' filename char(10) 'spectrum: ' var];
                                % display filepath and filename in static texts next to
                                % the table "spectrum" so that user knows which
                                % spectrum is used by the program at the
                                % moment. Additionally the filename is divided
                                % into two parts: One showing the name of the
                                % struct the other of the file with the
                                % spectrum.
                                set(handles.filename,'String',specstring);
                                set(handles.filepath,'String',pathname);
                                Raw_Spec=struct('filename',specstring,'pathname',pathname,'spec',spec);
                                % save "filename", "path" and "spec" as "Raw_Spec" in struct "FIT"
                                FIT.Raw_Spec=Raw_Spec;
                                setappdata(handles.fit_output_table,'FIT',FIT);
                            end
                        end
                        % if the file attempted to be loaded is not a .txt -
                        % or .mat - file there is an error message.
        otherwise
            errordlg('Spectrum must be avaiable as a .txt - or .mat - file','Input Argument Error!')
    end
end


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes on button press in plot_spec.
function plot_spec_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to plot_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% get the spectrum from the table "spectrum" and the toggle state of the
% checkbox for axes 1, determining in which of the axes to plot.
spec=getappdata(handles.load_spec,'spec');
cbox1 = getappdata(handles.cbox_axes1,'cbox1');

% create the legendstr for the plot and save a copy for the context menu,
% so it can be used for the new window-feature
legendstr={'Spectrum Raw'};
setappdata(handles.axes1,'legendstr',legendstr);
 
% if there is no spectrum, there is no reaction by the program, otherwise
% the spectrum will be plotted in the axes according to the toggle state
% of the checkboxes.
if isempty(spec)
else
    if cbox1 ==1        
        % Create plot in axes 1
        axes(handles.axes1); % is necessary, so that axes 1 is current axes and xlabel, ylabel and legend
        % are applied to the right axes
        plot(handles.axes1,spec(:,1),spec(:,2))
        set(handles.axes1,'XMinorTick','on')
        set(handles.axes1,'YMinorTick','on')
        xlabel('Energy [eV]');
        ylabel(' O.D. [a.u.]');
        legend(legendstr);
    else
        % Create plot in axes 2
        axes(handles.axes2); % see comment to axes 1
        plot(handles.axes2,spec(:,1),spec(:,2))
        set(handles.axes2,'XMinorTick','on')
        set(handles.axes2,'YMinorTick','on')
        xlabel('Energy [eV]');
        ylabel(' O.D. [a.u.]');
        legend(legendstr);
    end
end

%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes on button press in filter_spectrum.
function filter_spectrum_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to filter_spectrum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________
 
% get polynomial order k and frame size f for the Savitzky - Golay - Filter
% using the "S_golay_filt" - function

hfig=S_golay_filt(handles.filter_spectrum);
% uiwait makes the GUI wait for user input in "S_golay_filt" - function
uiwait(hfig);
% get the output of "S_golay_filt" - function, containing values for k and
% f
cstruct=getappdata(handles.filter_spectrum,'Consts');

% check if user has made input for k,f
if isempty(cstruct)
else
    var=cstruct.var;

    % convert cell elements from string to number and load into static texts
    % below the table for the filtered spectrum
    set(handles.order_k,'String',var{1,1});
    set(handles.frame_size_f,'String',var{2,1});
    var{1,1}=str2double(var{1,1});
    var{2,1}=str2double(var{2,1});

    % load the spectrum and the state of checkbox for axes 1
    
    cbox1 = getappdata(handles.cbox_axes1,'cbox1');% needed for plotting the result in the right axes
    spec=getappdata(handles.load_spec,'spec');
    % check, if spectrum exists, else errormessage
    if isempty(spec)
        errordlg('There is no spectrum available, please load one!','Input Argument Error!')
    else
        energyraw=spec(:,1);
        ODraw=spec(:,2);

        % use the "sgolayfilt" - function to create a filtered/smoothed version of
        % the spectrum
        ODsmoothed=sgolayfilt(ODraw,var{1,1},var{2,1});

        % put the filtered/smoothed version of the spectrum into the table
        % "filtered_spectrum"
        specsmoothed=spec;
        specsmoothed(:,1)=energyraw;
        specsmoothed(:,2)=ODsmoothed;
        set(handles.filtered_spectrum,'Data',specsmoothed);

        % create and save a legendstring, will be used in contextmenu - callback
        % for axes as well
        legendstr={'Spectrum Raw', 'Spectrum Filtered'};
        setappdata(handles.axes1,'legendstr',legendstr);

        % set the static text below the table "filtered_spectrum" to the filename
        % of the spectrum, which has been processed by the "sgolayfilt" - function
        filename=get(handles.filename,'String');
        set(handles.filename_filtered,'String',filename);

        % create a struct containing: "filename", "polynomial order k",
        % "frame size f" and the "smoothed spectrum" and save it as part of
        % the "FIT" - struct
        Filt_Spec=struct('filename',filename,'poly_order_k',var{1,1},'frame_size_f',var{2,1},'spec',specsmoothed);
        FIT=getappdata(handles.fit_output_table,'FIT');
        FIT.Filt_Spec=Filt_Spec;
        setappdata(handles.fit_output_table,'FIT',FIT);

        % plot the raw spectrum and the filtered version of it according to the
        % toggle state of the checkboxes in the respective axes
         if cbox1 ==1 
            % Create plot in axes 1
            axes(handles.axes1); % is necessary, so that axes 1 is current axes and xlabel, ylabel and legend
            % are applied to the right axes
            plot(handles.axes1,spec(:,1),spec(:,2),'.-r',energyraw,ODsmoothed,'k')
            set(handles.axes1,'XMinorTick','on')
            set(handles.axes1,'YMinorTick','on')
            xlabel('Energy [eV]');
            ylabel(' O.D. [a.u.]');
            legend(legendstr);
                else
                % Create plot in axes 2
                axes(handles.axes2); % see comment to axes 1
                plot(handles.axes2,spec(:,1),spec(:,2),'.-r',energyraw,ODsmoothed,'k')
                set(handles.axes2,'XMinorTick','on')
                set(handles.axes2,'YMinorTick','on')
                xlabel('Energy [eV]');
                ylabel(' O.D. [a.u.]');
                legend(legendstr);
         end
    end
end
 

%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes on button press in fit_spec.
function fit_spec_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to fit_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


% get the toggle state of the "carbon-k-edge" - checkbox and possible new
% values for b,m and save them as "C_K_YN" in the "FIT" - struct
carbonstruct=getappdata(handles.cbox_carbon,'carbonstruct');
FIT=getappdata(handles.fit_output_table,'FIT');
FIT.C_K_YN=carbonstruct.cbox;

% get region of spectrum, whose O.D. - values will be averaged and
% subtracted from the spectrum
pre{1,1}=get(handles.min_value,'String');
pre{2,1}=get(handles.max_value,'String');

% save pre in "FIT"-struct
FIT.pre_edge=pre;

%convert into number, if there is input, else ignore "pre"
if strcmp(pre{1,1},'-')
    else
    pre{1,1}=str2double(pre{1,1});
    pre{2,1}=str2double(pre{2,1});
end


% get the actual fit parameter from the table
par=get(handles.fitparameter,'Data');
FIT.param=par;
    
% check for possible empty cell == no fit parameter entered,if this is the
% case display an error message and abort
if isempty(par)
    errordlg('You haven''t created any parameters at all. Please make a input!')
else


    % retrieve the raw spectrum and a possibly existing filtered version 
    spec=get(handles.spectrum,'Data');
    specsmoothed=get(handles.filtered_spectrum,'Data');

    % create an empty array called "fitspec"
    fitspec=[];

    %check if spectrum was loaded, whether or not a filtered version was
    %created and get the state of the popup menu. According to the answers to
    %these questions fitspec will be assigned either the raw spec or the
    %filtered spec or an error message is displayed
    if isempty(spec)
       if isempty(specsmoothed)
            errordlg('There is no spectrum available, please load one!','Input Argument Error!')
       end
    else if  ~isempty(specsmoothed)
           fit_choice=get(handles.fit_what,'Value');
            if fit_choice ==1
                fitspec=spec;
            else fitspec=specsmoothed;
            end 
        else fitspec=spec;
        end


        % check if the fit parameter cell has rows with no entry for the position
        % of the peak and ask the user if he still wants to continue, even when
        % these peaks won't be used in the fitting process at all
        qstring2=['There is no input for one or more peak(s) for the field ' char(10) ...
            '"Position". This(These) peak(s) will be neglected when doing the fit.' char(10) ...
            'Do you still want to continue? Or do you want to abort and add the missing input?'];
        sizep=size(par);
        j=1;
        probe=1;

        % while loop checks for rows with missing entries and opens a
        % question dialog asking, if you wanna abort or continue
        while probe==1
            if isempty(par{j,3})
                probe=0;
                button2 = questdlg(qstring2,'Missing input for one or more peak(s)','Continue','Abort','Abort');
            else 
                if j==sizep(1,1)
                    probe=0;
                end
                button2='-';
                j=j+1;
            end
        end

        % get indices of rows with missing entries
        a=repmat(0,sizep(1,1),1);
        if strcmp(button2,'Continue')
            for i=1:sizep(1,1)
                if isempty(par{i,3})
                    a(i)=0;
                else a(i)=1;
                end
            end

            ind1=find(a ~=0);
            lind1=length(ind1);
            fitpar=cell(lind1,6);

            % load only rows with an entry for position into the new parameter cell
            for i=1:lind1
                fitpar(i,:)=par(ind1(i),:);
            end

            % sort the new cell by energy
            fitpar=sortrows(fitpar,3);

            for i=1:lind1
                fitpar{i,1}=i;
            end
        % if the table has no missing entries, the complete cell is loaded and sort
        % by energy
        else fitpar=par;

            fitpar=sortrows(fitpar,3); 

            for i=1:sizep
                fitpar{i,1}=i;
            end

        end
        
        % get the size of new cell "fitpar"        
        sizef=size(fitpar);
        %if fitpar has no entries since all rows were deleted because of
        %missing entries in the position field, callback is aborted and a
        %error message is shown
        if sizef(1,1)==0
            errordlg(['After all peaks/steps without an entry for ' char(10) 'position were omitted, none were left.' char(10) 'Please correct your input!'],'Input Argument Error!')
        else
        % use the "Nexafs_Decon" - function to fit the spectrum    
        [peaks,fit,normspec,coefs,ci,covb,mse,legendstr,fout,b,m]=Nexafs_Decon(fitspec,fitpar,pre,carbonstruct);
        % overwrite b and m with the values that were actually used in the
        % fit according to the toggle state of the carbon k-edge checkbox
        carbonstruct.newconsts{1,1}=m;
        carbonstruct.newconsts{2,1}=b;
        % save values for b,m that were used to fit, so they right values
        % are saved when using the "Save Fit" - function
        setappdata(handles.cbox_carbon,'carbonstruct',carbonstruct);

        % save the output from the fitting function in the "FIT" struct
        FIT.Fit_Par=fitpar;
        FIT.raw_filt=get(handles.fit_what,'Value');
        FIT.peaks=peaks;
        FIT.fitres=fit;
        FIT.coefs=coefs;
        FIT.con_int=ci;
        FIT.cov_mat=covb;
        FIT.mse=mse;
        FIT.legendstr=legendstr;
        FIT.Fit_Outtab=fout;
        FIT.Norm_Spec=normspec;
        FIT.b_m=carbonstruct.newconsts;

        setappdata(handles.fit_output_table,'FIT',FIT);

        % load the statistical output into the corresponding table
        set(handles.fit_output_table,'Data',fout);

        % save legendstring, will be used in contextmenu - callback
        % for axes as well
        setappdata(handles.axes1,'legendstr',legendstr);

        % get toggle state of checkbox axes1 to decide where to plot the
        % fit
        cbox1 = getappdata(handles.cbox_axes1,'cbox1');
        
        %prepare "en" and "nOD", so they can be used for plotting the
        %results, for the same reason the "loadFit_functions" - function is
        %used
        en=normspec(:,1);
        nOD=normspec(:,2);
        F = loadFit_functions();

        % plot the normalized spectrum,the fit and the single peaks according to the
        % toggle state of the checkboxes in the respective axes
         if cbox1 ==1      
            % Create plot in axes 1
            axes(handles.axes1);% is necessary, so that axes 1 is current axes and xlabel, ylabel and legend
            % are applied to the right axes
            plot(handles.axes1,en,feval(F.Fit_Kernel,coefs,en,fitpar,carbonstruct),en,nOD,'.-r',en,fit(:,2),'.-k')
            set(handles.axes1,'XMinorTick','on')
            set(handles.axes1,'YMinorTick','on')
            xlabel('Energy [eV]');
            ylabel(' O.D. [a.u.]');
            legend(legendstr);
                else
                % Create plot in axes 2
                axes(handles.axes2); % see comment to axes 1
                plot(handles.axes2,en,feval(F.Fit_Kernel,coefs,en,fitpar,carbonstruct),en,nOD,'.-r',en,fit(:,2),'.-k')
                set(handles.axes2,'XMinorTick','on')
                set(handles.axes2,'YMinorTick','on')
                xlabel('Energy [eV]');
                ylabel(' O.D. [a.u.]');
                legend(legendstr);
         end
        end
    end
end

%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes on button press in save_fit.
function save_fit_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to save_fit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% retrieve "FIT" - struct 
FIT=getappdata(handles.fit_output_table,'FIT');

%get the values from the carbon k-edge checkbox and save them into the
%"FIT" struct; if not altered by the user, the defau;t values for carbon
%will be saved, which are initialized just before the GUI becomes visible
carbonstruct=getappdata(handles.cbox_carbon,'carbonstruct');
FIT.C_K_YN=carbonstruct.cbox;
FIT.b_m=carbonstruct.newconsts;

% get the parameter and save them in the struct, contrary to the "fitpar"
% they weren't altered by the program, but only by the user
par=get(handles.fitparameter,'Data');
FIT.param=par;

% get region of spectrum, whose O.D. - values will be averaged and
% subtracted from the spectrum
pre{1,1}=get(handles.min_value,'String');
pre{2,1}=get(handles.max_value,'String');

% save pre in "FIT"-struct
FIT.pre_edge=pre;

% get value from popup menu, determining which spec. to fit
FIT.raw_filt=get(handles.fit_what,'Value');

% save data as struct "FIT" .mat - file
uisave('FIT');

%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes on button press in save_par.
function save_par_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to save_par (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% retrieve data from table and carbon k-edge checkbox
PAR.par=get(handles.fitparameter,'Data');
PAR.carbonstruct=getappdata(handles.cbox_carbon,'carbonstruct');
% get region of spectrum, whose O.D. - values will be averaged and
% subtracted from the spectrum
pre{1,1}=get(handles.min_value,'String');
pre{2,1}=get(handles.max_value,'String');

PAR.pre=pre;

% get state of popup menu
PAR.raw_filt=get(handles.fit_what,'Value');

% save data as struct "PAR" as a mat - file
uisave('PAR');


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes on button press in load_par.
function load_par_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to load_par (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% get filename and path for parameter, you wanna load
[filename, pathname] = uigetfile({'*.mat'},'Load Fit Parameter');
% change current directory to the pathname, but check beforehand if any
% file was chosen and loaded
if pathname==0
else
    cd(pathname);
    matfile=load(filename);
    % test if matfile is a struct
    % if "matfile" is no struct, it has only one entry and
    % can't be output from neither "Save Par." nor "Save Fit"
    if ~isstruct(matfile)      
    else matfilestruct=matfile;
        matfile=fieldnames(matfile);
        % if the fieldname is "PAR" the struct is output from the "Save
        % Par." - function and is treated accordingly
         if strcmp(matfile,'PAR')
             PAR=matfilestruct.PAR;
             set(handles.fitparameter,'Data',PAR.par); 
             set(handles.min_value,'String',PAR.pre{1,1});
             set(handles.max_value,'String',PAR.pre{2,1});
             set(handles.fit_what,'Value',PAR.raw_filt);
             carbonstruct.cbox=PAR.carbonstruct.cbox;
             set(handles.cbox_carbon,'Value',PAR.carbonstruct.cbox);
             carbonstruct.newconsts{1,1}=PAR.carbonstruct.newconsts{1,1};
             carbonstruct.newconsts{2,1}=PAR.carbonstruct.newconsts{2,1};
             setappdata(handles.cbox_carbon,'carbonstruct',carbonstruct);
             sizep=size(PAR.par);
             set(handles.peaknumber,'String',num2str(sizep(1,1)));
        % if the fieldname is "FIT" the struct is output from the "Save
        % Fit" - function and is treated accordingly
         elseif strcmp(matfile,'FIT')
             FIT=matfilestruct.FIT;
             set(handles.min_value,'String',FIT.pre_edge{1,1});
             set(handles.max_value,'String',FIT.pre_edge{2,1});
             set(handles.fit_what,'Value',FIT.raw_filt);
             carbonstruct.cbox=FIT.C_K_YN;
             set(handles.cbox_carbon,'Value',FIT.C_K_YN);
             carbonstruct.newconsts{1,1}=FIT.b_m{1,1};
             carbonstruct.newconsts{2,1}=FIT.b_m{2,1};
             setappdata(handles.cbox_carbon,'carbonstruct',carbonstruct);
             
             % check if either fitpar or par has to be loaded into the
             % fitparameter table. fitpar only exists, if the "Fit Spec." -
             % button had been pushed, before using "Save Fit"
             FIT_names=fieldnames(FIT);
             s=strmatch('Fit_Par',FIT_names);

                if ~isempty(s)
                set(handles.fitparameter,'Data',FIT.Fit_Par);
                sizep=size(FIT.Fit_Par);
                else
                    set(handles.fitparameter,'Data',FIT.param);
                    sizep=size(FIT.param);
                end

             set(handles.peaknumber,'String',num2str(sizep(1,1)));
         end     
    end
end
%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function plot_ax2_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to plot_ax2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% callback for contextmenu that executes, when user right - clicks on axes
% 2

% Create a figure to receive this axes' data
legendstr=getappdata(handles.axes1,'legendstr');
axes2fig = figure;
% Copy the axes and size it to the figure
axes2copy = copyobj(handles.axes2,axes2fig);
set(axes2copy,'Units','Normalized',...
              'Position',[.10,.10,.85,.85])
% Assemble a title for this new figure
title('Axes 2','Fontweight','bold')
legend(legendstr);
% Save handles to new fig and axes in case
% we want to do anything else to them
handles.axes2fig = axes2fig;
handles.axes2copy = axes2copy;
guidata(hObject,handles);


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function plot_ax1_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to plot_ax1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% callback for contextmenu that executes, when user right - clicks on axes
% 1

% Create a figure to receive this axes' data
legendstr=getappdata(handles.axes1,'legendstr');
axes1fig = figure;
% Copy the axes and size it to the figure
axes1copy = copyobj(handles.axes1,axes1fig);
set(axes1copy,'Units','Normalized',...
              'Position',[.10,.10,.85,.85])
% Assemble a title for this new figure
title('Axes 1','Fontweight','bold')
legend(legendstr);
% Save handles to new fig and axes in case
% we want to do anything else to them
handles.axes1fig = axes1fig;
handles.axes1copy = axes1copy;
guidata(hObject,handles);


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function plot_axes1_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to plot_axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function plot_axes2_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to plot_axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes when selected cell(s) is changed in fitparameter.
function fitparameter_CellSelectionCallback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to fitparameter (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% retrieve the indices of the selected rows (single cells in a row)
selection=eventdata.Indices(:,1);
% use the "unique" - function to get rid of row - indices that occur more
% than once. 
selection=unique(selection);
% save the indices, so they can used in "delete_peak_callback"
setappdata(handles.delete_peak,'sel',selection);


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes on button press in legend.
function legend_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to legend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% call the "nexafs_table_legend" - function, providing a short legend to
% the tabel
nexafs_table_legend;


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes on button press in load_fit.
function load_fit_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to load_fit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% get filename and path for fit, you wanna load
[filename, pathname] = uigetfile({'*.mat'},'Load Fit');
% change current directory to the pathname and check if any file was loaded
if pathname==0
else
    cd(pathname);
    matfile=load(filename);
    % test if matfile is a struct
    % if "matfile" is no struct, it has only one entry and therefore can't be a
    % fit
    if ~isstruct(matfile)
    else
        matfilestruct=matfile;
        matfile=fieldnames(matfile);
        % check if struct the "FIT" struct, if not abort
        if ~strcmp(matfile,'FIT')
            else
            FIT=matfilestruct.FIT;
            % check if the "FIT" struct has any entries and abort in case there are
            % none
            if isempty(FIT)
            else
                % get toggle state of checkbox for axes 1, necessary to be
                % able to plot a possible fit
                cbox1 = getappdata(handles.cbox_axes1,'cbox1');
                % get the names of the different fields stored in struct
                % "FIT" and load them, if they exist
                entries=fieldnames(FIT);
                
                % search for a raw spectrum
                s=strmatch('Raw_Spec',entries);

                if ~isempty(s)
                set(handles.filename,'String',FIT.Raw_Spec.filename);
                set(handles.filepath,'String',FIT.Raw_Spec.pathname);
                set(handles.spectrum, 'Data',FIT.Raw_Spec.spec);
                setappdata(handles.load_spec,'spec',FIT.Raw_Spec.spec);
                else
                end
                
                % search for a filtered version of the spectrum
                s=strmatch('Filt_Spec',entries);

                if ~isempty(s)
                set(handles.order_k,'String',FIT.Filt_Spec.poly_order_k);
                set(handles.frame_size_f,'String',FIT.Filt_Spec.frame_size_f);
                set(handles.filtered_spectrum,'Data',FIT.Filt_Spec.spec);
                set(handles.filename_filtered,'String',FIT.Filt_Spec.filename);
                else
                end
                
                % load input, which has to exist by default
                set(handles.min_value,'String',FIT.pre_edge{1,1});
                set(handles.max_value,'String',FIT.pre_edge{2,1});
                set(handles.fit_what,'Value',FIT.raw_filt);
                carbonstruct.cbox=FIT.C_K_YN;
                set(handles.cbox_carbon,'Value',FIT.C_K_YN);
                carbonstruct.newconsts{1,1}=FIT.b_m{1,1};
                carbonstruct.newconsts{2,1}=FIT.b_m{2,1};
                setappdata(handles.cbox_carbon,'carbonstruct',carbonstruct);
                
                % check if fitpar or par has to be loaded into fitparameter
                % table (see comments "Load Par." - function)
                FIT_names=fieldnames(FIT);
                s=strmatch('Fit_Par',FIT_names);

                    if ~isempty(s)
                    set(handles.fitparameter,'Data',FIT.Fit_Par);
                    sizep=size(FIT.Fit_Par);
                    else
                        set(handles.fitparameter,'Data',FIT.param);
                        sizep=size(FIT.param);
                    end

                set(handles.peaknumber,'String',num2str(sizep(1,1)));
                
                %search for fitting algorithm output and load it in case of
                %existance
                s=strmatch('coefs',entries);
                if isempty(s)
                    warnstr=['No fit had been created when you saved the output of the GUI!' char(10) ...
                        'Therefore no plot will be generated and the "ouput for fitting ' char(10) ...
                        'process" table will remain empty, resp. won''t be renewed:.' ];
                    warndlg(warnstr);   
                else   
                        coefs=FIT.coefs;
                        normspec=FIT.Norm_Spec;
                        fit=FIT.fitres;
                        legendstr=FIT.legendstr;
                        fitpar=FIT.Fit_Par;
                        
                        en=normspec(:,1);
                        nOD=normspec(:,2);

                        set(handles.fit_output_table,'Data',FIT.Fit_Outtab);
                        

                        F = loadFit_functions();

                        % plot the normalized spectrum,the fit and the single peaks according to the
                        % toggle state of the checkboxes in the respective axes
                         if cbox1 ==1      
                            % Create plot in axes 1
                            axes(handles.axes1);% is necessary, so that axes 1 is current axes and xlabel, ylabel and legend
                            % are applied to the right axes
                            plot(handles.axes1,en,feval(F.Fit_Kernel,coefs,en,fitpar,carbonstruct),en,nOD,'.-r',en,fit(:,2),'.-k')
                            set(handles.axes1,'XMinorTick','on')
                            set(handles.axes1,'YMinorTick','on')
                            xlabel('Energy [eV]');
                            ylabel(' O.D. [a.u.]');
                            legend(legendstr);
                                else
                                % Create plot in axes 2
                                axes(handles.axes2); % see comment to axes 1
                                plot(handles.axes2,en,feval(F.Fit_Kernel,coefs,en,fitpar,carbonstruct),en,nOD,'.-r',en,fit(:,2),'.-k')
                                set(handles.axes2,'XMinorTick','on')
                                set(handles.axes2,'YMinorTick','on')
                                xlabel('Energy [eV]');
                                ylabel(' O.D. [a.u.]');
                                legend(legendstr);
                         end
                    end
            end
        end
    end
end


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% opens a question dialog, if you attempt to close the figure, asking for
% confirmation of your intent to close the figure
selection = questdlg('Do you want to close the Fit - Program?',...
      'Close Request Function',...
      'Yes','No','Yes'); 
switch selection, 
      case 'Yes',
         delete(gcf)
      case 'No'
      return 
end


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function sort_desc_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to sort_desc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% callback for contextmenu that executes, when user right - clicks on the
% corresponding button, text input, checkbox or popup menu, look at title
% of helpdlg (second entry) to determine, what the callback was made for


helpstr=['By pushing this button you sort the entries' char(10) ...
    'in the parameter table according to their' char(10) ...
    'value in the field "Pos. [eV]" in ascending' char(10) ...
    'order.'];
helpdlg(helpstr,'Sort by Energy - Button');


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function delete_peak_desc_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to delete_peak_desc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% callback for contextmenu that executes, when user right - clicks on the
% corresponding button, text input, checkbox or popup menu, look at title
% of helpdlg (second entry) to determine, what the callback was made for

helpstr=['Pushing this button deletes those entries' char(10) ...
    'in the parameter table, you have selected. You' char(10) ...
    'select entries by clicking at least one cell of' char(10) ...
    'the row, you want to delete. You can select' char(10) ...
    ' several cells at a time by holding the "ctrl" - key.'];
helpdlg(helpstr,'Delete Peak - Button');


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function add_peak_desc_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to add_peak_desc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% callback for contextmenu that executes, when user right - clicks on the
% corresponding button, text input, checkbox or popup menu, look at title
% of helpdlg (second entry) to determine, what the callback was made for

helpstr=['Pushing this button increases the number' char(10) ...
    'of peaks/steps used to fit the spectrum by 1.'];
helpdlg(helpstr,'Add Peak - Button');


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function peaknumber_desc_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to peaknumber_desc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% callback for contextmenu that executes, when user right - clicks on the
% corresponding button, text input, checkbox or popup menu, look at title
% of helpdlg (second entry) to determine, what the callback was made for

helpstr=['Type in any positive integer and confirm by' char(10) ...
    'pushing the "enter" - key. The fit program will' char(10) ...
    'then generate the respective number of peaks/steps' char(10) ...
    'using default-/start - values in the table.'];
helpdlg(helpstr,'Number of peaks/steps - Input');


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function cbox_carbon_desc_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to cbox_carbon_desc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% callback for contextmenu that executes, when user right - clicks on the
% corresponding button, text input, checkbox or popup menu, look at title
% of helpdlg (second entry) to determine, what the callback was made for

helpstr=['The state of this box is a marker for the energy region' char(10) ...
    'of your spectrum. The default - state is "checked", since the main ' char(10) ...
    'intent of this GUI is fitting Carbon spectra at the NEXAFS - K - edge.' char(10) ...
    'The fit parameter for the asym. Gaussian Fct.''s width are strongly' char(10) ...
    'dependent upon the energy. When there is a change in energy there must' char(10) ...
    'be a change in these two parameters as well. You will be asked for new ' char(10) ...
    'values, if you uncheck the box.' char(10) char(10) ...
    'Important: New values will only be used, when the box is unchecked.' char(10) ...
    'So don''t check the box again, after confirming new values, if you intend to use them!!!'];
helpdlg(helpstr,'Carbon K-edge - Checkbox');


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function load_par_desc_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to load_par_desc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% callback for contextmenu that executes, when user right - clicks on the
% corresponding button, text input, checkbox or popup menu, look at title
% of helpdlg (second entry) to determine, what the callback was made for

helpstr=['Push this button to load old fit parameter' char(10) ...
    'in the parameter table. You can only load mat - files.' char(10) ...
    'But those can either be complete fits (produced by "Save Fit")' char(10) ...
    'or only the parameter (produced by "Save Par.").'];
helpdlg(helpstr,'Load Par. - Button');


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function save_par_desc_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to save_par_desc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% callback for contextmenu that executes, when user right - clicks on the
% corresponding button, text input, checkbox or popup menu, look at title
% of helpdlg (second entry) to determine, what the callback was made for

helpstr=['With this button you can save the parameter' char(10) ...
    'as a mat - file. The can be loaded by the "Load Par." - ' char(10) ...
    'Button later on, if you wanna use them again.'];
helpdlg(helpstr,'Save Par. - Button');


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function load_fit_desc_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to load_fit_desc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% callback for contextmenu that executes, when user right - clicks on the
% corresponding button, text input, checkbox or popup menu, look at title
% of helpdlg (second entry) to determine, what the callback was made for

helpstr=['Load a complete fit into the GUI. The fit must have' char(10) ...
    'been saved beforehand by applying the "Save Fit" - function. ' char(10) ...
    'The graph will be plotted in those axes, that are checked. Existing ' char(10) ...
    'output in any of the tables will be replaced.'];
helpdlg(helpstr,'Load Fit - Button');


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function save_fit_desc_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to save_fit_desc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% callback for contextmenu that executes, when user right - clicks on the
% corresponding button, text input, checkbox or popup menu, look at title
% of helpdlg (second entry) to determine, what the callback was made for

helpstr=['Save the state of the GUI to be able to' char(10) ...
    'load it later on with the "Load Fit" - function.'];
helpdlg(helpstr,'Save Fit - Button');


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function fit_spec_desc_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to fit_spec_desc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% callback for contextmenu that executes, when user right - clicks on the
% corresponding button, text input, checkbox or popup menu, look at title
% of helpdlg (second entry) to determine, what the callback was made for

helpstr=['A push on this button starts the fitting algorithm.' char(10) ...
    'The resulting fit will be plotted in the checked axes and' char(10) ...
    'statistical output from the fit displayed in the corresponding' char(10) ...
    'table.' char(10) ...
    'In following cases an error message can occur:' char(10) ...
    '1.)You haven''t created any parameters at all.' char(10) ...
    '2.)You chose to fit the filtered version of the spectrum, ' char(10) ...
    'but you haven''t created it.' char(10) ...
    '3.)You haven''t loaded any spectrum to fit.'];
helpdlg(helpstr,'Fit Spec. - Button');


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function filter_spec_desc_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to filter_spec_desc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% callback for contextmenu that executes, when user right - clicks on the
% corresponding button, text input, checkbox or popup menu, look at title
% of helpdlg (second entry) to determine, what the callback was made for

helpstr=['The "Filter Spec." - Button enables you to' char(10) ...
    'filter/smooth the spectrum by applying a Savitzky - ' char(10) ...
    'Golay - Filter to it, after you have chosen and ' char(10) ...
    'confirmed the necessary input values.' char(10) ...
    'Original spectrum and filtered spectrum will' char(10) ...
    'be plotted in the checked axes.'];
helpdlg(helpstr,'Filter Spec. - Button');


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function plot_spec_desc_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to plot_spec_desc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% callback for contextmenu that executes, when user right - clicks on the
% corresponding button, text input, checkbox or popup menu, look at title
% of helpdlg (second entry) to determine, what the callback was made for

helpstr=['Plots the loaded spectrum in the checked axes.' char(10) ...
    'Without a spectrum loaded, nothing will happen,' char(10) ...
    'when pushing this button.'];
helpdlg(helpstr,'Plot Spec. - Button');


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function load_spec_desc_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to load_spec_desc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% callback for contextmenu that executes, when user right - clicks on the
% corresponding button, text input, checkbox or popup menu, look at title
% of helpdlg (second entry) to determine, what the callback was made for

helpstr=['You can load spectra in txt-/mat- format.' char(10) ...
    'The spectrum must consist out of the same number of ' char(10) ...
    'x - and y - values. If it is not in the right form ' char(10) ...
    'or format an error message will be displayed.'];
helpdlg(helpstr,'Load Spec. - Button');


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function cbox_axes2_desc_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to cbox_axes2_desc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% callback for contextmenu that executes, when user right - clicks on the
% corresponding button, text input, checkbox or popup menu, look at title
% of helpdlg (second entry) to determine, what the callback was made for

helpstr=['The state of this checkbox decides, whether or not' char(10) ...
    'new graphs will be plotted in axes 1 or 2. New graphs' char(10) ...
    'will always be plotted in the checked axes.'];
helpdlg(helpstr,'Axes 2 - Checkbox');


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function cbox_axes1_desc_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to cbox_axes1_desc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% callback for contextmenu that executes, when user right - clicks on the
% corresponding button, text input, checkbox or popup menu, look at title
% of helpdlg (second entry) to determine, what the callback was made for

helpstr=['The state of this checkbox decides, whether or not' char(10) ...
    'new graphs will be plotted in axes 1 or 2. New graphs' char(10) ...
    'will always be plotted in the checked axes.'];
helpdlg(helpstr,'Axes 1 - Checkbox');


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function cbox_axes1_des_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to cbox_axes1_des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function cbox_axes2_des_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to cbox_axes2_des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function load_spec_des_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to load_spec_des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function plot_spec_des_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to plot_spec_des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function filter_spec_des_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to filter_spec_des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function fit_spec_des_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to fit_spec_des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function save_fit_des_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to save_fit_des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function load_fit_des_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to load_fit_des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function save_par_des_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to save_par_des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function load_par_des_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to load_par_des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function cbox_carbon_des_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to cbox_carbon_des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function peaknumber_des_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to peaknumber_des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function add_peak_des_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to add_peak_des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function delete_peak_des_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to delete_peak_des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function sort_des_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to sort_des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function math_models_overv_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to math_models_overv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

%calls the "math_models_nexafs" - function, providing a table with
%available functions and their general shape and mathematical formul;
%callback to right - click on the table
math_models_nexafs;


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function math_models_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to math_models (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes on selection change in fit_what.
function fit_what_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to fit_what (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% Hints: contents = cellstr(get(hObject,'String')) returns fit_what contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fit_what


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes during object creation, after setting all properties.
function fit_what_CreateFcn(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to fit_what (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%__________________________________________________________________________

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function min_value_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to min_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% Hints: get(hObject,'String') returns contents of min_value as text
%        str2double(get(hObject,'String')) returns contents of min_value as a double

% Validate that the text in the field is a valid entry
N = str2double(get(hObject,'String'));
if isnan(N) || ~isreal(N) || N<0
    % isdouble returns NaN for non-numbers and N cannot be complex and must
    % be positive
    % Display error message
    errordlg('Invalid input, input must be a positive number','Input Argument Error!')
end


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes during object creation, after setting all properties.
%__________________________________________________________________________
function min_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%__________________________________________________________________________

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function max_value_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to max_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% Hints: get(hObject,'String') returns contents of max_value as text
%        str2double(get(hObject,'String')) returns contents of max_value as a double

% Validate that the text in the field is a valid entry
N = str2double(get(hObject,'String'));
if isnan(N) || ~isreal(N) || N<0
    % isdouble returns NaN for non-numbers and N cannot be complex and must
    % be positive
    % Display error message
    errordlg('Invalid input, input must be a positive number','Input Argument Error!')
end


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


% --- Executes during object creation, after setting all properties.
function max_value_CreateFcn(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to max_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%__________________________________________________________________________

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function raw_filt_desc_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to raw_filt_desc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% callback for contextmenu that executes, when user right - clicks on the
% corresponding button, text input, checkbox or popup menu, look at title
% of helpdlg (second entry) to determine, what the callback was made for

helpstr=['By choosing either "Raw Spectrum" or "Filtered Spectrum"' char(10) ...
    'you decide which one will be used, when the fitting algorithm' char(10) ...
    'is applied. Choosing "Filtered Spectrum" makes of course only' char(10) ...
    'sense, when you have created / create a filtered version.'];
helpdlg(helpstr,'Raw/Filtered - PopUp Menu');


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function max_val_desc_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to max_val_desc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% callback for contextmenu that executes, when user right - clicks on the
% corresponding button, text input, checkbox or popup menu, look at title
% of helpdlg (second entry) to determine, what the callback was made for

helpstr=['Type in the upper limit for the energy region, you intend ' char(10) ...
    'to get the optical density values from, which will be used ' char(10) ...
    'for averaging and subtracting from the spectrum. This can' char(10) ...
    'be senseful to find the "true" baseline of the spectrum. It can' char(10) ...
    'be thought of applying an offset to the whole spectrum, therefore' char(10) ...
    'not changing any characteristic features of the spectrum.'];
helpdlg(helpstr,'Min. [eV] - Text Input');


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function min_val_desc_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to min_val_desc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________

% callback for contextmenu that executes, when user right - clicks on the
% corresponding button, text input, checkbox or popup menu, look at title
% of helpdlg (second entry) to determine, what the callback was made for

helpstr=['Type in the lower limit for the energy region, you intend ' char(10) ...
    'to get the optical density values from, which will be used ' char(10) ...
    'for averaging and subtracting from the spectrum. This can' char(10) ...
    'be senseful to find the "true" baseline of the spectrum. It can' char(10) ...
    'be thought of applying an offset to the whole spectrum, therefore' char(10) ...
    'not changing any characteristic features of the spectrum.'];
helpdlg(helpstr,'Max. [eV] - Text Input');


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function min_val_des_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to min_val_des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function max_val_des_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to max_val_des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------


function raw_filt_des_Callback(hObject, eventdata, handles)
%__________________________________________________________________________
% hObject    handle to raw_filt_des (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%__________________________________________________________________________



%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------

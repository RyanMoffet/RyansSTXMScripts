function varargout = STACKLab(varargin)
% STACKLAB M-file for STACKLab.fig

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @STACKLab_OpeningFcn, ...
                   'gui_OutputFcn',  @STACKLab_OutputFcn, ...
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


% --- Executes just before STACKLab is made visible.
function STACKLab_OpeningFcn(hObject, eventdata, handles, varargin)

% Define blobal variables
global S V eVmin eVmax eVlength colorTable;

% Define color table
colorTable={'b','r','k','g','m','c','b','r','k','g','m','c','b','r','k','g','m','c','b','r','k','g','m','c'};

% Read input arguments
S=varargin{1};
V=S.spectr;

% Read usefull information about the stack
eVlength=size(V,3);
eVinit=floor(eVlength/10);
eVmin=min(S.eVenergy);
eVmax=max(S.eVenergy);

% Set eVSlider value to middle of stack, set Max and Min
set(handles.eVSlider,'Min',1);
set(handles.eVSlider,'Max',eVlength);
set(handles.eVSlider,'Value',eVinit);

% initialize StackViewer and SpecViewer
initViewers(handles,eVinit,0);

% Choose default command line output for STACKLab
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes STACKLab wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = STACKLab_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function eVSlider_Callback(hObject, eventdata, handles)
global S V sliderValue; 

sliderValue = ceil(get(handles.eVSlider,'Value')); % read slider Value

% update StackViewer
axes(handles.StackViewer);
imagesc(V(:,:,sliderValue))
colormap(gray)
text(1,10,sprintf('E=%6.2f eV',S.eVenergy(sliderValue)),'FontSize',18,'BackgroundColor',[1,1,1],'FontWeight','bold')
axis image
colorbar

drawSpecViewer(handles,sliderValue);



% --- Executes during object creation, after setting all properties.
function eVSlider_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on button press in buttonNewROI.
function buttonNewROI_Callback(hObject, eventdata, handles)
global specArray S sliderValue colorTable;

axes(handles.StackViewer)
try 
    colorcounter=length(specArray)+1;
catch
    colorcounter=1;
end

% Draw ROI, create binary ROI Mask
h=imfreehand;
setColor(h,colorTable{colorcounter});
Mask=createMask(h);

% Calculate average spectrum 
return_spec=averagespec(S,Mask);
specArray{length(specArray)+1}=return_spec;
drawSpecViewer(handles,sliderValue)

% draw updated SpecViewer


% --- Executes on button press in buttonReset.
function buttonReset_Callback(hObject, eventdata, handles)

clear global energyA energyB
sliderValue = ceil(get(handles.eVSlider,'Value')); % read slider Value
initViewers(handles, sliderValue,1)
set(handles.textEnergyB,'String',sprintf('Energy B ='))
set(handles.textEnergyA,'String',sprintf('Energy A ='))


% --- Executes on button press in buttonEnergyB.
function buttonEnergyB_Callback(hObject, eventdata, handles)
global energyB S
energyB= ceil(get(handles.eVSlider,'Value')); % read slider Value
set(handles.textEnergyB,'String',sprintf('Energy B = %6.2f eV',S.eVenergy(energyB)))


% --- Executes on button press in buttonEnergyA.
function buttonEnergyA_Callback(hObject, eventdata, handles)
global energyA S
energyA= ceil(get(handles.eVSlider,'Value')); % read slider Value
set(handles.textEnergyA,'String',sprintf('Energy A= %6.2f eV',S.eVenergy(energyA)))

% --- Executes on button press in buttonSubtract.
function buttonSubtract_Callback(hObject, eventdata, handles)
global energyA energyB S

bufferA=S.spectr(:,:,energyA);
bufferB=S.spectr(:,:,energyB);

axes(handles.StackViewer)
imagesc(bufferA-bufferB)
colormap(gray)
text(1,10,sprintf('Energy A - Energy B'),'FontSize',18,'BackgroundColor',[1,1,1],'FontWeight','bold')
axis image
colorbar




% --- Function calculates binary mask for inital SpecViewer
function returnMask=initMask(V)

imagebuffer=mean(V,3); % Mean of total Stack is used to Produce initial mask
imagebuffer(imagebuffer<0)=0; % Filter negative values
imagebuffer=medfilt2(imagebuffer);
GrayImage=mat2gray(imagebuffer); % Turn into a greyscale with vals [0 1]
Thresh=graythresh(GrayImage); % Otsu thresholding
tempMask=im2bw(GrayImage,Thresh); % Give binary image

labelMat=bwlabel(tempMask); %% Label connected regions in binary image

returnMask=zeros(size(tempMask)); % Mask used to note valid Fe rich areas who's pixels will be used in histogram
numofparticles=max(max(labelMat));
totnumofpixels=size(returnMask,1)*size(returnMask,2);

% Filtering of connected regions that are smaller than 0.5% of total image Area  
for cnt=1:numofparticles
            
        [ytrue,xtrue]=find(labelMat==cnt);
        linearind=sub2ind(size(returnMask),ytrue,xtrue);
        
        if length(linearind)>=0.005* totnumofpixels   %Areas bigger or equal to 1% of total image size are used for histogram 
            
            returnMask(linearind)=1;
            
        end
        
end

return



% --- Function to return average spectrum over region defined by binary Mask
function return_spec=averagespec(S,Mask)
global eVlength

V=S.spectr;
return_spec=zeros(eVlength,2);
return_spec(:,1)=S.eVenergy;

% loop over energy range of stack, calculate average vor each energy -> return_spec
for cnt=1:eVlength
    
    buffer=V(:,:,cnt);
    return_spec(cnt,2)=mean(mean(buffer(Mask~=0)));
    clear buffer
   
end

return



% --- Function used to calculate plot limits for SpecViewer
function [SpecViewerMin,SpecViewerMax]=SpecViewerLimits(inputArray)

% init return values
SpecViewerMin=99;
SpecViewerMax=0;

for cnt=1:length(inputArray)
    
    if min(inputArray{cnt}(:,2)) < SpecViewerMin
        
        SpecViewerMin=min(inputArray{cnt}(:,2));
        
    end
    
    if max(inputArray{cnt}(:,2)) > SpecViewerMax
        
        SpecViewerMax=max(inputArray{cnt}(:,2));
        
    end
    
end

SpecViewerMax=1.05*SpecViewerMax;
SpecViewerMin=SpecViewerMin-0.05*SpecViewerMax;
return



% --- Function used to initialize StackViewer and SpecViewer after program start / reset
% RESET = 0 / 1, for RESET = 1: specArray is cleared, no average stack spec is displayed  
function initViewers(handles,energyposition,RESET)
global S V specArray Mask eVmin eVmax spec; 

% Display initial Stack view
axes(handles.StackViewer)
imagesc(V(:,:,energyposition))
colormap(gray)
text(1,10,sprintf('E=%6.2f eV',S.eVenergy(energyposition)),'FontSize',18,'BackgroundColor',[1,1,1],'FontWeight','bold')
axis image
colorbar

% Calculate initial Mask for average stack spectrum
Mask=initMask(V);

% Get initial spectrum of stack for initial SpecViewer
spec=averagespec(S,Mask);
specArray{1}=spec;

% Get SpecViewer plot limits
[SpecViewerMin,SpecViewerMax]=SpecViewerLimits(specArray);

% Show initial SpecViewer
axes(handles.SpecViewer)

if RESET==1
    clear global specArray
end

if RESET~=1
    plot(spec(:,1),spec(:,2));
    hold on
end


stem(spec(energyposition,1),spec(energyposition,2)+5,'r')
xlim([eVmin,eVmax])
ylim([SpecViewerMin,SpecViewerMax])
hold off

return




% --- Function used to draw updated SpecViewer
function drawSpecViewer(handles,energyposition)
global specArray eVmin eVmax V S colorTable

axes(handles.SpecViewer)

%try has to be used to test if specArray exists
try
    % Get SpecViewer plot limits
    [SpecViewerMin,SpecViewerMax]=SpecViewerLimits(specArray);
    
    % update SpecViewer by looping ofer all specArray elements (if specArray exists)
    for cnt=1:length(specArray)
        
        plot(specArray{cnt}(:,1),specArray{cnt}(:,2),colorTable{cnt})
        hold on
        
    end
    
    stem(specArray{1}(energyposition,1),specArray{1}(energyposition,2)+5,'r')
    xlim([eVmin,eVmax])
    ylim([SpecViewerMin,SpecViewerMax])
    hold off
    
catch
    
    % Calculate initial Mask for average stack spectrum
    Mask=initMask(V);
    
    % Get initial spectrum of stack for initial SpecViewer
    spec=averagespec(S,Mask);
    specArray{1}=spec;
    [SpecViewerMin,SpecViewerMax]=SpecViewerLimits(specArray);
    stem(specArray{1}(energyposition,1),specArray{1}(energyposition,2)+5,'r')
    xlim([eVmin,eVmax])
    ylim([SpecViewerMin,SpecViewerMax])
    hold off
    clear global specArray
    
end

return
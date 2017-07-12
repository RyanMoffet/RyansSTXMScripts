function hf=S_golay_filt(handle)
%   Opens a figure consisting of a listbox, two static texts, two edit
%   texts and a oush button. It cites a part of the help to the m - file
%   "sgolayfilt", which is used to filter the spectrum. The edit texts  
%   and the push button are then used to ask for user input and confirming
%   this input.


% create a figure of a certain size; give it a name; turn the "resize" -
% function off; make the WindowStyle "modal": meaning that you have to
% interact with this window first, before you can continue; and set the
% closerequestfcn, which will be called when you try to close the window
hf = figure('Position',[200 100 800 500]);
set(hf,'Name','Input for Savitzky - Golay - Filter');
set(hf,'Resize','off');
set(hf,'WindowStyle','modal');
set(hf,'CloseRequestFcn',@NEXAFS_closereq);

% create a listbox and the textstring for it
pos1 = [10 180 780 300]; 
ht1 = uicontrol('Style','listbox','Position',pos1);
t=help('sgolayfilt');
set(ht1,'Fontsize',14);
set(ht1,'Backgroundcolor',[0.953 0.871 0.733]);
string1=['From the help of the m - file "sgolayfilt": ' char(10) ... 
   'SGOLAYFILT(X,K,F) smoothes the signal X using a Savitzky-Golay ' ... 
   '(polynomial) smoothing filter.  The polynomial order, K, must ' ...
   'be less than the frame size, F, and F must be odd.  The length ' ... 
   'of the input X must be >= F.  If X is a matrix, the filtering ' ...
   'is done on the columns of X. ' char(10) ...
   'Note that if the polynomial order K equals F-1, no smoothing ' ...
   'will occur.' char(10) char(10) ...
   '----------------------------------------------------------------------' char(10) ...
   'To create a filtered version of the spectrum choose now values ' char(10) ...
   'for K and F.'];
string1 = {string1};

% use the "textwrap" - function to make the text fit well into the listbox
colwidth = 80;
outstring1 = textwrap(ht1,string1,colwidth);

% Reset Units of ht1 to Characters to use the result
set(ht1,'Units','characters');
newpos1 = get(ht1,'Position');
set(ht1,'String',outstring1,'Position',newpos1)

% Create static text, labeling one of the text inputs
pos2 = [50 60 250 25];
ht2=uicontrol('Style','text','Position',pos2);
strm='Enter the polynomial order K:';
set(ht2,'Fontsize',14);
set(ht2,'String',strm);
set(ht2,'Backgroundcolor',[0.502 0.502 0.502]);

% Create static  text as label for other text input
pos3 = [50 140 250 25];
ht3=uicontrol('Style','text','Position',pos3);
strb='Enter the frame size F:';
set(ht3,'Fontsize',14);
set(ht3,'String',strb);
set(ht3,'Backgroundcolor',[0.502 0.502 0.502]);

% Create edit text input for ploynomial order K and set initial value to "-"
pos4 = [125 25 100 25];
ht4=uicontrol('Style','edit','Position',pos4);
set(ht4,'Fontsize',12);
set(ht4,'String','-');
set(ht4,'Backgroundcolor',[0.757 0.867 0.776]);

% Create edit text input for frame size F and set initial value to "-"
pos5 = [125 105 100 25];
ht5=uicontrol('Style','edit','Position',pos5);
set(ht5,'Fontsize',12);
set(ht5,'String','-');
set(ht5,'Backgroundcolor',[0.757 0.867 0.776]);

% save the handles of the edit texts and of the gui component as a struct
struct2=struct('K_handle',ht4,'F_handle',ht5,'gui_handle',handle);
data.handlestruct=struct2;
setappdata(hf,'Consts',data);

% create the push button to confirm the user input for K and F
pos6 = [400 75 300 80];
ht6=uicontrol('Style','pushbutton','Position',pos6);
set(ht6,'Fontsize',14);
set(ht6,'String','Confirm values');
set(ht6,'Backgroundcolor',[0.392 0.475 0.635]);
set(ht6,'Callback',@sgolay_confirm_new_values);

end
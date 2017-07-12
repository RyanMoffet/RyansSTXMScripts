function hf=spec_matfile_struct(filelist,handle)
%   Opens a figure consisting of one static text, one listbox and push
%   button. The static text explains, that the matfile loaded is not a
%   single variable but a struct. The fields of the struct are displayed in
%   the listbox and the user can choose one entry by selecting it with a
%   mouse click and confirming the selection by pushing the button.



% create a figure of a certain size; give it a name; turn the "resize" -
% function off; make the WindowStyle "modal": meaning that you have to
% interact with this window first, before you can continue; and set the
% closerequestfcn, which will be called when you try to close the window
hf = figure('Position',[200 100 700 360]);
set(hf,'Name','Choose Spectrum out of this list');
set(hf,'Resize','off');
set(hf,'WindowStyle','modal');
set(hf,'CloseRequestFcn',@NEXAFS_closereq);

% create the static text and the string for it
pos1 = [10 160 350 180]; 
ht1 = uicontrol('Style','text','Position',pos1);
set(ht1,'Fontsize',12);
set(ht1,'Backgroundcolor',[0.953 0.871 0.733]);
string1=['The .mat - file you loaded, seems to be a struct. In the box '...
         'to the right is a list of the variables loaded into the workspace. '...
         'If the spectrum is part of this list, you can choose it '...
         'by doing the following:' char(10) char(10) ...
         '  Select the spectrum in the listbox, by clicking once, and confirm with pushing the Button.'];
string1={string1};

% use the "textwrap" - function to make the text fit well into the listbox
colwidth = 55;
outstring1 = textwrap(ht1,string1,colwidth);

% Reset Units of ht1 to Characters to use the result
set(ht1,'Units','characters')
newpos1 = get(ht1,'Position');
set(ht1,'String',outstring1,'Position',newpos1)


% create the listbox and load it with the fields of the struct. The fields
% have to be given to the function as an input argument.
pos2 = [400 60 250 280];
ht2=uicontrol('Style','listbox','Position',pos2);
set(ht2,'Fontsize',12);
set(ht2,'String',filelist);
set(ht2,'Backgroundcolor',[0.757 0.867 0.776]);

% create the push button to confirm your choice of a field 
pos3 = [90 80 200 60];
ht3=uicontrol('Style','pushbutton','Position',pos3);
set(ht3,'Fontsize',14);
set(ht3,'String','Confirm choice');
set(ht3,'Callback',@confirm_spec_choice);
set(ht3,'Backgroundcolor',[0.392 0.475 0.635]);


% save the handles of the listbox and the gui component as application
% data, so it can be used in the callback of the push button
struct1=struct('lbox_handle',ht2,'gui_comp_handle',handle);
data=struct1;
setappdata(hf,'lbox',data);


end
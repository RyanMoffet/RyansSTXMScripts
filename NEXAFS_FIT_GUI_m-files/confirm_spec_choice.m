function confirm_spec_choice(src,evnt)
%   Callback - function of the push button "Confirm Choice" of the
%   "spec_matfile_struct" - function. It gets the index of the selected
%   entry from the listbox and uses this index to get the name out of the
%   sring cell. This name will be saved as application data , so it can be
%   accessed in the main gui and further processed.


% get handle of the figure
h=gcf;
% get application data from the figure
cstruct=getappdata(h,'lbox');
h2=cstruct.lbox_handle;
h3=cstruct.gui_comp_handle;

% get the name of the chosen field of the struct
index_selected = get(h2,'Value');
filelist = get(h2,'String');
filesel = filelist{index_selected};

% save the name as application data of the gui component
setappdata(h3,'filesel',filesel);

% delete figure
delete(h)

end
function cb_confirm_new_values(src,evnt)
%   Callback for the "Confirm new values" - button of the "C_K_Edge" -
%   function. It uses the handle of the edit texts stored in the struct
%   saved as application data in the figure to get the new values entered by the user.
%   These values are saved as application data of the gui component so they
%   can be accessed from within the gui script.


% get handle of figure
h=gcf;
% get struct from the figure
cstruct=getappdata(h,'Consts');
% get the input from the edit texts and save it into the struct
newm=str2num(get(cstruct.handlestruct.m_handle,'String'));
newb=str2num(get(cstruct.handlestruct.b_handle,'String'));
cstruct.carbonstruct.newconsts{1,1}=newm;
cstruct.carbonstruct.newconsts{2,1}=newb;
% write a 0 into the "cbox" - value, showing that you are not at the carbon
% k - edge
cstruct.carbonstruct.cbox=0;
% save the changes as struct as application data of the gui comp
h_cbox=cstruct.handlestruct.c_box;
setappdata(h_cbox,'Consts',cstruct);

% destroy the figure
delete(h)

end
function cb_cancel_defaultval(src,evnt)
%   Callback for the "Cancel and reset default values" - button and
%   "CloseRequestFcn" for the figure created by "C_K_Edge". It justs delete
%   the figure and writes a 1 into the cbox - value. This will be used to
%   check the carbon checkbox again and also in "loadFit_functions"
%   restoring the deafult values of b and m.


% get handle of the current figure
h=gcf;
% get the struct created in the C_K_Edge function
cstruct=getappdata(h,'Consts');
% write 1 into the cbox value and save it as application data
cstruct.carbonstruct.cbox=1;
h_cbox=cstruct.handlestruct.c_box;
setappdata(h_cbox,'Consts',cstruct);
% destroy the figure
delete(h)

return
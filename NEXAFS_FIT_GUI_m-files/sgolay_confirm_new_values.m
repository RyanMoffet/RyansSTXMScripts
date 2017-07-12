function sgolay_confirm_new_values(src,evnt)
%   Callback for the "Confrim Values" - button of the "S_golay_filt" -
%   function. Gets the user input and writes it into a cell. This cell is
%   saved as part of a struct as application data of the gui component, so
%   it can further processed in the main gui.

% get handle of figure
h=gcf;
% get the struct from the figure with the handles for th edit texts
cstruct=getappdata(h,'Consts');
% get the input from the edit texts and save it as part of cstruct
K=get(cstruct.handlestruct.K_handle,'String');
F=get(cstruct.handlestruct.F_handle,'String');
var{1,1}=K;
var{2,1}=F;
cstruct.var=var;
setappdata(cstruct.handlestruct.gui_handle,'Consts',cstruct);

% destroy the figure
delete(h)

end
function NEXAFS_closereq(src,evnt)
%   User-defined close request function 
%   to display a question dialog box used for figures 
%   of the NEXAFS_FIT_GUI


selection = questdlg('Do you want to close this window?',...
                    'Close Request Function',...
                    'Yes','No','Yes'); 
   switch selection, 
      case 'Yes',
         delete(gcf)
      case 'No'
      return 
   end
   
   
end
function nexafs_table_legend()
% Opens a figure consisting of a listbox, one static text and one push
% button. It serves as a legend to the fitparameter table, providing short
% information about the different columns.

% create a figure of a certain size; give it a name; turn the "resize" -
% function off; set the closerequestfcn, which will be called when you 
% try to close the window
hf = figure('Position',[200 100 800 600]);
set(hf,'Name','Legend to table');
set(hf,'Resize','off');
set(hf,'CloseRequestFcn',@NEXAFS_closereq);

% create a listbox and the textstring for it
colwidth = 109;
pos1 = [10 100 780 490]; 
ht1 = uicontrol('Style','listbox','Position',pos1);
set(ht1,'Fontsize',12);
set(ht1,'Backgroundcolor',[0.953 0.871 0.733]);
string1=['1.) Peak #: The actual number of peaks and/or steps used to fit the spectrum. ' ...
    'It is also used as the row - index for the parameter table. Therefore it is the only '...
    'column, which entries can''t be manipulated by the user.' char(10)];
string2=['2.) Mathematical Model: Determines the model function used to describe a peak/step. Following functions are '...
    'available: Gaussian Fct., Lorentzian Fct., Voigt Fct., Asym. Gaussian Fct., Gaussian Shaped Step (Decaying Error Fct.), '...
    'Lorentzian Shaped Step (Decaying ArcTan). For further information about the functions push the "Open math. models overview" - button and/or right - click' ...
    ' the table or look at literature about spectroscopy resp. these specific functions.' char(10)];
string3=['3.) Pos. [eV]: The position of the peak/step in Electron Volt. The parameter is relevant for every model. '...
    'If you leave this field empty, the complete row will be ignored by the fitting algorithm.' char(10)];
string4=['4.) Wid. [eV]: The "Full Width Half Maximum" (FWHM) in Electron Volt. The parameter is relevant for all models, '...
    'but the "Asym. Gaussian Fct.". If you leave this field empty, the program will choose as default value 1 eV.' char(10)];
string5=['5.) Lor. Frac.: The "Lorentzian Fraction" is only important, when using the "Voigt Fct." as model. If the field is left '...
    'empty, the default value is set to 0.5 . For further information about it push the "Open math. models overview" - button and/or right - click' ...
    ' the table or look at literature about the Voigt Fct.' char(10)];
string6=['6.) Assignment: With this field you can assign the peak/step to a certain energy transition or excitation. It will '...
    'be used for the legend of the plot. Use TeX - format to produce greek letters and/or mathematical symbols, e.g. "\sigma". '...
    'Without user input, the peak number will be used as default value for the legend.'];
string1 = {string1,string2,string3,string4,string5,string6};

% create a listbox and the text for it
colwidth = 109;
outstring1 = textwrap(ht1,string1,colwidth);

% Reset Units of ht1 to Characters to use the result
set(ht1,'Units','characters')
newpos1 = get(ht1,'Position');
set(ht1,'String',outstring1,'Position',newpos1)

% create static text, that gives some instruction/info about push button
pos2 = [150 60 500 25];
ht2=uicontrol('Style','text','Position',pos2);
strdes='Push this button to open an overview of the mathematical models!';
set(ht2,'Fontsize',12);
set(ht2,'String',strdes);
set(ht2,'Backgroundcolor',[0.502 0.502 0.502]);

%create a push button, which when activated, gives some extra information
%about the mathematical models
pos3 = [260 10 280 45];
ht3=uicontrol('Style','pushbutton','Position',pos3);
set(ht3,'Fontsize',14);
set(ht3,'String','Open math. models overview');
set(ht3,'Callback',@button_table_legend);
set(ht3,'Backgroundcolor',[0.392 0.475 0.635]);

end
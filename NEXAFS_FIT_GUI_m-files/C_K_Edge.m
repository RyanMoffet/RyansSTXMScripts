function hf=C_K_Edge(handle,consts)
%   Opens a figure consisting of a listbox, two static texts, two edit text
%   and two push buttons. The listbox contains text about how the parameter
%   used to fit asymmetric Gaussian functions are strongly dependent upon
%   energy. Therefore they have to be changed when the energy values of the
%   spectrum differ a lot from the Carbon K - edge (~ 280 - 320 eV). 
%   That is why you have the edit texts and push buttons, so you can change
%   those parameter, if necessary.


% initialize the constants with the actual values, which were the last to
% be used by the fitting program
struct1=struct('cbox',[],'newconsts',[]);
struct1.newconsts{1,1}=consts{1,1};
struct1.newconsts{2,1}=consts{2,1};

% create a figure of a certain size; give it a name; turn the "resize" -
% function off; make the WindowStyle "modal": meaning that you have to
% interact with this window first, before you can continue; and set the
% closerequestfcn, which will be called when you try to close the window
hf = figure('Position',[200 100 800 600]);
set(hf,'Name','New constants for linear dependent FWHM');
set(hf,'Resize','off');
set(hf,'WindowStyle','modal');
set(hf,'CloseRequestFcn',@cb_cancel_defaultval);

% create a listbox and the text for it
pos1 = [10 220 780 370]; 
ht1 = uicontrol('Style','listbox','Position',pos1);
set(ht1,'Fontsize',12);
set(ht1,'Backgroundcolor',[0.953 0.871 0.733]);
string1=['Sigma* - resonances are best fitted by asymmetric Gaussian functions.' char(10) ...
    'The mathematical formula is as follows: ' char(10) char(10) '      I = H*Exp[-0.5*((E-P)/(F/c))^2] '  char(10)];
string2=['Where E is the independent variable energy, P is the position of the peak, '...
    'c is a constant defined by' char(10) 'c = 2*Sqrt[ln[4]] = 2.355, H is the maximum value of the '...
    'function and F is the full width at half maximum (FWHM).'];
string3=['For the lineshape to be asymmetric F depends linearly upon energy. It is described by: F = E*m+b' char(10) ...
    'Where E is again the energy and m and b are constants. At the Carbon K-edge, spectra are '...
    'best fitted,' char(10) 'when m = 0.575 and b = -164.75 eV. [source: NEXAFS Spectroscopy by Joachim Stoehr]' char(10)];
string4=['By unchecking the box you implied, that your spectrum was taken at a different '...
    'energy than the Carbon K-edge! Therefore new values should be assigned to m and b, guaranteeing '...
    'the best possible fit for your spectrum. Edit the values for m and b and push the "Confirm new values" - button.' char(10) ...
    'In case you unchecked the box by accident or out of curiosity, please close this dialog or ' ...
    'push the "Cancel and reset default values" - button.' char(10)];
string1 = {string1,string2,string3,string4};

% use the "textwrap" - function to make the text fit well into the listbox
colwidth = 109;
outstring1 = textwrap(ht1,string1,colwidth);

% Reset Units of ht1 to Characters to use the result
set(ht1,'Units','characters')
newpos1 = get(ht1,'Position');
set(ht1,'String',outstring1,'Position',newpos1)

% Create static text, labeling one of the text inputs
pos2 = [50 90 250 25];
ht2=uicontrol('Style','text','Position',pos2);
strm='Enter new value for m:';
set(ht2,'Fontsize',14);
set(ht2,'String',strm);
set(ht2,'Backgroundcolor',[0.502 0.502 0.502]);

% Create static  text as label for other text input
pos3 = [50 170 250 25];
ht3=uicontrol('Style','text','Position',pos3);
strb='Enter new value for b [eV]:';
set(ht3,'Fontsize',14);
set(ht3,'String',strb);
set(ht3,'Backgroundcolor',[0.502 0.502 0.502]);

% Create edit text input and load in the most recent value of the constant
% (m) used
pos4 = [125 55 100 25];
ht4=uicontrol('Style','edit','Position',pos4);
set(ht4,'Fontsize',12);
set(ht4,'String',num2str(consts{1,1}));
set(ht4,'Backgroundcolor',[0.757 0.867 0.776]);

% Create edit text input and load in the most recent value of the constant
% (b) used
pos5 = [125 135 100 25];
ht5=uicontrol('Style','edit','Position',pos5);
set(ht5,'Fontsize',12);
set(ht5,'String',num2str(consts{2,1}));
set(ht5,'Backgroundcolor',[0.757 0.867 0.776]);

% Create a struct containing the handles of the gui component and the two
% edit texts and save it as application data of the figure. hereby you are
% able to used it in the callback - functions of the push buttons
struct2=struct('m_handle',ht4,'b_handle',ht5,'c_box',handle);
data.handlestruct=struct2;
data.carbonstruct=struct1;
setappdata(hf,'Consts',data);

% create push button, used to confirm new values
pos6 = [400 140 300 60];
ht6=uicontrol('Style','pushbutton','Position',pos6);
set(ht6,'Fontsize',14);
set(ht6,'String','Confirm new values');
set(ht6,'Backgroundcolor',[0.392 0.475 0.635]);
set(ht6,'Callback',@cb_confirm_new_values);

% create push button to cancel and close the figure and reset default
% values for the constants b and m
pos7 = [400 50 300 60];
ht7=uicontrol('Style','pushbutton','Position',pos7);
set(ht7,'Fontsize',14);
set(ht7,'String','Cancel and reset default values');
set(ht7,'Backgroundcolor',[0.392 0.475 0.635]);
set(ht7,'Callback',@cb_cancel_defaultval);







end
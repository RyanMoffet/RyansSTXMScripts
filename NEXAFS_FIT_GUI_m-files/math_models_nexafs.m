function math_models_nexafs()
%   Opens a figure, that by use of the "subplot" - function contains twelve
%   axes. Six of these axes are changed in their appearance in such a way,
%   that they look like plain boxes. These are used to display the
%   mathematical formulas of the functions available for the
%   NEXAFS_FIT_GUI. The other six axes show a plot of the respective
%   function, using normalized values.
%   The intent of this figure is to give the user a general idea of the
%   functions available to him/her and what their general shape is like.


% initialize the struct F with the function handles of loadFit_Models,
% enabling you to call the different mathematical functions (Gaus., Lor.,
% etc.) with "feval()";
F=loadFit_Models();
% Initialize x, H, pos, wid so they can be used for plotting
x=[0:0.001:1];
H=1;
pos=0.5;
wid=0.2;

% create a figure of a certain size; give it a name; turn the "resize" -
% function on; set the closerequestfcn, which will be called when you 
% try to close the window
hf = figure('Position',[200 100 1000 650]);
set(hf,'Name','Mathematical Models');
set(hf,'Resize','on');
set(hf,'CloseRequestFcn',@NEXAFS_closereq);

subplot('Position',[0.01 0.92 0.98 0.08],'XTick',[],'YTick',[],'Box','on','Color',[0.5 0.5 0.5]);
text(0.05,0.5,['Variables in \color{blue} blue \color{black} are the coefficients fitted by the nonlinear least square fit and therefore machine generated.' char(10) ...
    'The \color{red} red \color{black} variables  '  ],'Fontweight','bold','Fontsize',12);



% display the formula for the Voigt Fct. in axes, using TeX - format and
% alter the axes in such a way, that they appear to be a empty box
subplot('Position',[0.01 0.03 0.25 0.23],'XTick',[],'YTick',[],'Box','on','Color',[0.953 0.871 0.733]);
title('Voigt Fct.','Fontweight','bold','Fontsize',12)
text(0.05,0.8,['I = \color{blue}H\color{black}*[\color{red}\eta\color{black} *((\color{red}\Gamma\color{black}/2)^2/((E-\color{red}P\color{black})^2+(\color{red}\Gamma\color{black}/2)^2))+' char(10)...
    '+(1-\color{red}\eta\color{black})*Exp[-1/2*((E-\color{red}P)\color{black}/(\color{red}\Gamma\color{black}/c))^2]'],'Fontweight','bold','Fontsize',12);
gfstr=[' \color{blue}H\color{black} = Height ; E = Energy ' char(10) ...
    '\color{red}P\color{black} = Position ; \color{red}\Gamma\color{black} = FWHM' char(10) ...
    'c = 2*\surdlog[4] = 2.355' char(10) ...
    '\color{red}\eta\color{black} = Lorentzian fraction \in [0,1]'];
text(0.1,0.35,gfstr,'Fontsize',12);

% plot in the box to the right of the Voigt Fct.'s mathematical description
% the function itself using some normalized values
subplot('Position',[0.29 0.03 0.20 0.25],'XTick',[0:0.2:1],'YTick',[0:0.2:1],'Box','on');
n=0.5;
plot(x,feval(F.Voigt_Fct,H,n,x,pos,wid),'Linewidth',2);
text(0.05,0.6,['H = 1' char(10) 'P = 0.5' char(10) '\Gamma = 0.2' char(10) 'E \in [0,1]' char(10) '\eta = 0.5'],'Fontsize',12);

% display the formula for the Lorentzian Fct. in axes, using TeX - format and
% alter the axes in such a way, that they appear to be a empty box
subplot('Position',[0.01 0.33 0.25 0.23],'XTick',[],'YTick',[],'Box','on','Color',[0.953 0.871 0.733]);
title('Lorentzian Fct.','Fontweight','bold','Fontsize',12)
text(0.1,0.8,'I = \color{blue}H\color{black}*[(\color{red}\Gamma\color{black}/2)^2/((E-\color{red}P\color{black})^2+(\color{red}\Gamma\color{black}/2)^2)]','Fontweight','bold','Fontsize',12);
gfstr=['\color{blue}H\color{black} = Height ; E = Energy ' char(10) ...
    '\color{red}P\color{black} = Position ; \color{red}\Gamma\color{black} = FWHM' char(10)];
text(0.1,0.4,gfstr,'Fontsize',12);

% plot in the box to the right of the Lorentzian Fct.'s mathematical description
% the function itself using some normalized values
subplot('Position',[0.29 0.33 0.20 0.25],'XTick',[0:0.2:1],'YTick',[0:0.2:1],'Box','on');
plot(x,feval(F.Lorentzian_Fct,H,x,pos,wid),'Linewidth',2);
text(0.05,0.7,['H = 1' char(10) 'P = 0.5' char(10) '\Gamma = 0.2' char(10) 'E \in [0,1]'],'Fontsize',12);

% display the formula for the Gaussian Fct. in axes, using TeX - format and
% alter the axes in such a way, that they appear to be a empty box
subplot('Position',[0.01 0.64 0.25 0.23],'XTick',[],'YTick',[],'Box','on','Color',[0.953 0.871 0.733]);
title('Gaussian Fct.','Fontweight','bold','Fontsize',12)
text(0.1,0.8,'I = \color{blue}H\color{black}*Exp[-1/2*((E-\color{red}P\color{black})/(\color{red}\Gamma\color{black}/c))^2]','Fontweight','bold','Fontsize',12);
gfstr=['\color{blue}H\color{black} = Height ; E = Energy ' char(10) ...
    '\color{red}P\color{black} = Position ; \color{red}\Gamma\color{black} = FWHM' char(10) ...
    'c = 2*\surdlog[4] = 2.355'];
text(0.1,0.4,gfstr,'Fontsize',12);

% plot in the box to the right of the Gaussian Fct.'s mathematical description
% the function itself using some normalized values
subplot('Position',[0.29 0.64 0.20 0.25],'XTick',[0:0.2:1],'YTick',[0:0.2:1],'Box','on');
plot(x,feval(F.Gaussian_Fct,H,x,pos,wid),'Linewidth',2);
text(0.05,0.7,['H = 1' char(10) 'P = 0.5' char(10) '\Gamma = 0.2' char(10) 'E \in [0,1]'],'Fontsize',12);

% display the formula for the Lorentzian Shaped Step in axes, using TeX - format and
% alter the axes in such a way, that they appear to be a empty box
subplot('Position',[0.51 0.03 0.25 0.23],'XTick',[],'YTick',[],'Box','on','Color',[0.953 0.871 0.733]);
title(['Lorentzian Shaped Step' char(10) '(Decaying ArcTan)'],'Fontweight','bold','Fontsize',12)
text(0.02,0.8,['J = \color{blue}H\color{black}*(1/2+1/\pi*arctan[(E-\color{red}P\color{black})/(\color{red}\Gamma\color{black}/2)])' char(10) ...
    'I = J ;   E \leq \color{red}P\color{black}+\color{red}\Gamma\color{black}' char(10) ...
    'I = J*Exp[-\color{blue}d\color{black}*(E-\color{red}P\color{black}-\color{red}\Gamma\color{black})];' ...
    'E > \color{red}P\color{black}+\color{red}\Gamma\color{black}'],'Fontweight','bold','Fontsize',12);
gfstr=['\color{blue}H\color{black} = Height ; E = Energy ' char(10) ...
    '\color{red}P\color{black} = Position ; \color{red}\Gamma\color{black} = FWHM' char(10) ...
    '\color{blue}d\color{black} = exp. decay coefficient'];
text(0.1,0.35,gfstr,'Fontsize',12);

% plot in the box to the right of the Lorentzian Shaped Step's mathematical description
% the function itself using some normalized values
subplot('Position',[0.79 0.03 0.20 0.25],'XTick',[0:0.2:1],'YTick',[0:0.2:1],'Box','on');
pos2=0.4;
x2=[0.001:0.001:1];
x2=x2';
d=0.4;
wid2=0.1;
plot(x2,feval(F.Lorentzian_Shaped_Step,H,d,x2,pos2,wid2),'Linewidth',2);
text(0.05,0.6,['H = 1' char(10) 'P = 0.4' char(10) '\Gamma = 0.1' char(10) 'E \in [0,1]' char(10) 'd = 0.4'],'Fontsize',12);

% display the formula for the Gaussian Shaped Step in axes, using TeX - format and
% alter the axes in such a way, that they appear to be a empty box
subplot('Position',[0.51 0.33 0.25 0.23],'XTick',[],'YTick',[],'Box','on','Color',[0.953 0.871 0.733]);
title(['Gaussian Shaped Step' char(10) '(Decaying Error Fct.)'],'Fontweight','bold','Fontsize',12)
text(0.02,0.8,['J = \color{blue}H\color{black}*(1/2+1/2*erf[(E-\color{red}P\color{black})/(\color{red}\Gamma\color{black}/k)])' char(10) ...
    'I = J ;   E \leq \color{red}P\color{black}+\color{red}\Gamma\color{black}' char(10) ...
    'I = J*Exp[-\color{blue}d\color{black}*(E-\color{red}P\color{black}-\color{red}\Gamma\color{black})];' ...
    'E > \color{red}P\color{black}+\color{red}\Gamma\color{black}'],'Fontweight','bold','Fontsize',12);
gfstr=['\color{blue}H\color{black} = Height ; E = Energy ' char(10) ...
    '\color{red}P\color{black} = Position ; \color{red}\Gamma\color{black} = FWHM' char(10) ...
    'k = 2*\surdlog[2] = 1.665' char(10) ...
    '\color{blue}d\color{black} = exp. decay coefficient'];
text(0.1,0.3,gfstr,'Fontsize',12);

% plot in the box to the right of the Gaussian Shaped Step's mathematical description
% the function itself using some normalized values
subplot('Position',[0.79 0.33 0.20 0.25],'XTick',[0:0.2:1],'YTick',[0:0.2:1],'Box','on');
plot(x2,feval(F.Gaussian_Shaped_Step,H,d,x2,pos2,wid2),'Linewidth',2);
text(0.05,0.6,['H = 1' char(10) 'P = 0.4' char(10) '\Gamma = 0.1' char(10) 'E \in [0,1]' char(10) 'd = 0.4'],'Fontsize',12);

% display the formula for the Asym. Gaussian Fct. in axes, using TeX - format and
% alter the axes in such a way, that they appear to be a empty box
subplot('Position',[0.51 0.64 0.25 0.23],'XTick',[],'YTick',[],'Box','on','Color',[0.953 0.871 0.733]);
title('Asym. Gaussian Fct.','Fontweight','bold','Fontsize',12)
text(0.1,0.8,['I = \color{blue}H\color{black}*Exp[-1/2*((E-\color{red}P\color{black})/(\Gamma/c))^2]' char(10) ...
    '\Gamma = E*\color{red}m\color{black}+\color{red}b\color{black}'],'Fontweight','bold','Fontsize',12);
gfstr=['\color{blue}H\color{black} = Height ; E = Energy ' char(10) ...
    '\color{red}P\color{black} = Position ; \color{red}m,b\color{black} = consts.' char(10) ...
    'c = 2*\surdlog[4] = 2.355'];
text(0.1,0.4,gfstr,'Fontsize',12);

% plot in the box to the right of the Asym. Gaussian Fct.'s mathematical description
% the function itself using some normalized values
subplot('Position',[0.79 0.64 0.20 0.25],'XTick',[0:0.2:1],'YTick',[0:0.2:1],'Box','on');
b=0.1;
m=0.5;
plot(x,feval(F.Asym_Gaussian_Fct,H,x,pos,b,m),'Linewidth',2);
text(0.05,0.6,['H = 1' char(10) 'P = 0.5' char(10) 'E \in [0,1]' char(10) 'b = 0.1' char(10) 'm = 0.5'],'Fontsize',12);



end
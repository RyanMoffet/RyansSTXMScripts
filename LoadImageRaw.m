function S = LoadImageRaw(filedir,name,figsav,varargin)
%function S=LoadStackRaw(filedir)
%
%Imports STXM raw data from input directoy filedir
%filedir needs to contain the STXM header file (.hdr) and the STXM data files (.xim)
%R.C. Moffet, T.R. Henn February 2009
%
%Inputs
%------
%filedir        path to STXM raw data directory
%name           filename
%figsav         0 if no save or 1 if save
%Outputs
%-------
%S              structure array containing imported STXM data
%S.spectr       STXM absorption images
%S.eVenergy     Photon energies used to record images
%S.Xvalue       length of horizontal STXM image axis in µm
%S.Yvalue       length of vertical STXM image axis in µm

cd(filedir) 

FileStruct=dir;

spccnt=1;
for i=3:length(FileStruct)
    stridx=findstr(FileStruct(i).name,sprintf('%s_a.xim',name));
    hdridx=findstr(FileStruct(i).name,sprintf('%s.hdr',name));

    if ~isempty(stridx)
        S.spectr=flipud(load(FileStruct(i).name));
        spccnt=spccnt+1;
    elseif ~isempty(hdridx) 
        [S.eVenergy,S.Xvalue,S.Yvalue]=ReadHdr(FileStruct(i).name);
    end
end
xAxislabel=[0,S.Xvalue];
yAxislabel=[0,S.Yvalue];
figure,
imagesc(xAxislabel,yAxislabel,S.spectr)
axis image
colorbar
title(sprintf('%s, Raw Transmission Image, %g eV',name,S.eVenergy),'Interpreter', 'none','FontSize',14,'FontWeight','normal')
colormap gray
xlabel('X-Position (µm)','FontSize',14,'FontWeight','normal')
ylabel('Y-Position (µm)','FontSize',14,'FontWeight','normal')
if figsav==1
    filename=sprintf('%s\%s',varargin{1},name);
    saveas(gcf,filename,'png');
end

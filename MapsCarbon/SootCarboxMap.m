function Sout=SootCarboxMap(Snew,plotflg)

% if ~exist('Snew.LabelMat','var')
%     beep
%     disp('gotta run CarbonMaps first to generate the LabelMat')
%     return
% end
energy=Snew.eVenergy;
stack=Snew.spectr;
subdim=ceil(sqrt(length(energy)));

sp2mapidx=find(energy>284.9 & energy<285.5);
sp2mapidx=round(mean(sp2mapidx));
carboxmapidx=find(energy>=288.5 & energy<=288.8);
carboxmapidx=round(mean(carboxmapidx));
if isnan(carboxmapidx) | isnan(sp2mapidx) 
    disp('missing one of the energies for carbox-sp2/TotC map');
    disp('returning empty matrices')
    Sout=Snew;
    Sout.SootCarbox=[];
%     Sout.binmap=[];% was causing CropPart to put out empty matrices when
%     COOH map was missing
    Sout.TotC=[];
    return
end
%% plot slected images
if plotflg==1
    figure,
    subplot(2,1,1)
    imagesc([0, Snew.Xvalue],[0,Snew.Yvalue],stack(:,:,sp2mapidx)),...
        set(gca,'Clim',[0,1.5]),
    colormap('gray'),
    axis image
    colorbar
    plottitle=sprintf('%geV',energy(sp2mapidx));
    title(plottitle);
    subplot(2,1,2)
    image([0, Snew.Xvalue],[0,Snew.Yvalue],stack(:,:,carboxmapidx)),...
        set(gca,'Clim',[0,1.5]),
    colormap('gray'),
    colorbar
    title(sprintf('%g eV',energy(carboxmapidx)));
    axis image
end
%% make map of Total Carbon
% sp2carbox=stack(:,:,carboxmapidx)-stack(:,:,sp2mapidx);
sp2carbox=(stack(:,:,carboxmapidx)-stack(:,:,sp2mapidx)); %./(stack(:,:,end)-stack(:,:,1));
TotC=(stack(:,:,end)-stack(:,:,1));
%% sp2 map
% sp2=(stack(:,:,sp2mapidx)-stack(:,:,1));
carbox=(stack(:,:,carboxmapidx)-stack(:,:,1));
% percsp2=sp2./TotC*(0.4512/0.8656);
% percsp2(percsp2>1)=1;
% percsp2(percsp2<0)=0;
%% make binary map
% % binmap=Snew.LabelMat;
% % binmap(binmap>0)=1;
% meanim=mean(Snew.spectr,3);
% meanim(meanim>.2)=.2;
% % figure,imagesc(meanim),colormap gray,colorbar
% GrayImage=mat2gray(meanim); %% Turn into a greyscale with vals [0 1]
% % GrayImage=imadjust(GrayImage,[0 1],[0 1],0.52); %% increase contrast
% Thresh=graythresh(GrayImage); %% Otsu thresholding
% binmap=im2bw(GrayImage,Thresh); %% Give binary image
% % SE = strel('disk', 1, 0);
% % figure,imagesc(binmap)
% % binmap = bwareaopen(binmap,3);
% binmap=medfilt2(binmap);
binmap=Snew.binmap;

%% Mask Maps
sp2carbox=sp2carbox.*binmap;
TotC=TotC.*binmap;
% sp2=sp2.*binmap;
carbox=carbox.*binmap;
TotC(TotC<0)=0;
sp2carbox(sp2carbox<0)=0;
% sp2(sp2<0)=0;
% percsp2=percsp2.*binmap;
carbox(carbox<0)=0;
if plotflg==1
    figure,
    image([0, Snew.Xvalue],[0,Snew.Yvalue],sp2carbox),...
        set(gca,'Clim',[0,5]),
    title(sprintf('%g eV - %g eV/total C',energy(carboxmapidx),energy(sp2mapidx)))
    axis image
    colormap jet
    colorbar
%     figure,imagesc([0, Snew.Xvalue],[0,Snew.Yvalue],percsp2),...
%         set(gca,'Clim',[0,1]),colorbar
%     figure, imagesc(TotC)
end
Sout=Snew;
Sout.SootCarbox=sp2carbox;
% Sout.TotC=TotC;
% Sout.sp2=sp2;
Sout.carbox=carbox;
% Sout.binmap=binmap;
return
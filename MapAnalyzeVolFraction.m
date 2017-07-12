function Sout=MapAnalyzeVolFraction(Snew)

% figure,
% subplot(2,2,1),imagesc(Snew.spectr(:,:,1)),colormap gray,colorbar,title '278 eV'
% subplot(2,2,2),imagesc(Snew.spectr(:,:,2)),colormap gray,colorbar,title '285 eV'
% subplot(2,2,3),imagesc(Snew.spectr(:,:,3)),colormap gray,colorbar,title '288 eV'
% subplot(2,2,4),imagesc(Snew.spectr(:,:,3)),colormap gray,colorbar,title '320 eV'
% 
%% Prepare input
stack=Snew.spectr;
DiffMap=zeros(size(stack,1),size(stack,2),5);

%% Find spectral components
preidx=find(Snew.eVenergy<283)
% ccidx=find(Snew.eVenergy>284 & Snew.eVenergy<286)
postidx=length(Snew.eVenergy);
cidx=find(Snew.eVenergy>288 & Snew.eVenergy<289)
if isempty(cidx)
    cidx=postidx;
end

%% Find particles
meanim=mean(Snew.spectr,3);
meanim(meanim>.2)=.2;
% figure,imagesc(meanim),colormap gray,colorbar
GrayImage=mat2gray(meanim); %% Turn into a greyscale with vals [0 1]
GrayImage=imadjust(GrayImage,[0 1],[0 1],0.52); %% increase contrast
% GrayImage=imadjust(GrayImage,[0 1],[0 1],1); %% increase contrast

Thresh=graythresh(GrayImage); %% Otsu thresholding
Mask=im2bw(GrayImage,Thresh); %% Give binary image
Mask=bwlabel(Mask,8);
% antiMask=zeros(size(Mask));
% antiMask(Mask==0)=1;
% figure,imagesc(Mask),colormap gray

%% Calculate maps
% % Carbon-Carbon double bonds
% im1=(Snew.spectr(:,:,ccidx)-Snew.spectr(:,:,preidx))./...
%     (Snew.spectr(:,:,postidx)-Snew.spectr(:,:,preidx));
% % pre/post ratio
im2=Snew.spectr(:,:,preidx)./Snew.spectr(:,:,postidx);
postim=Snew.spectr(:,:,postidx);
preim=Snew.spectr(:,:,preidx);
% % Total Carbon
im3=Snew.spectr(:,:,cidx)-Snew.spectr(:,:,preidx);

%% Thresholds
ccthresh=1;
inorgthresh=.5;

%% C=C
% figure,imagesc(Snew.spectr(:,:,ccidx).*antiMask),colormap gray, colorbar
% noise=Snew.spectr(:,:,ccidx).*antiMask;
% ccim=Snew.spectr(:,:,ccidx);
% im1(ccim<0.08)=0; %% sp2 peak must be greater than 0.12 (single pixel noise)
% im1(im3<0.08)=0; %% total carbon peak must also be greater than 0.12 (single pixel noise)
% im1(Mask==0)=0;
% im1(im1>2)=1;
% im1(im1<ccthresh)=0;
% im1=medfilt2(im1);

LabelMat=raw2maskMap(Snew,Mask),axis image;
%% Inorg Volume Fraction
[uorgpre,uorgpost,uinorgpre,uinorgpost]=PreToPostRatioVolFrac('NaCl','adipic'); %% get calculated cross sections
inorgDens=2.16;
orgDens=1.36;
im2(Mask==0)=0;
im2(im2>1.5)=1.5;
im2(im2<inorgthresh)=0;
im2=medfilt2(im2);
xin=uinorgpost./uinorgpre;
torg=(postim-xin.*preim)./(uorgpost.*orgDens+xin.*uorgpre.*orgDens);
torg(torg<0)=0;
torg=torg./100; % convert to meters
% figure,imagesc(torg),colorbar;
tinorg=(preim-uorgpre.*((postim-xin.*preim)./(uorgpost+xin.*uorgpre)))./...
    (uinorgpre.*inorgDens);
tinorg(tinorg<0)=0;
tinorg=tinorg./100; % convert to meters
% figure,imagesc(tinorg),colorbar;
volFraction=torg./(torg+tinorg);
volFraction(Mask==0)=0;
% figure,imagesc(volFraction),colorbar
MatSiz=size(LabelMat);
XSiz=Snew.Xvalue/MatSiz(1);
YSiz=Snew.Yvalue/MatSiz(2);
xdat=[0:XSiz:Snew.Xvalue];
ydat=[0:YSiz:Snew.Yvalue];
%% Integrate volume fractions for individual particles
volFrac=zeros(max(max(LabelMat)),1);
for i=1:max(max(LabelMat))
    [j,k]=find(LabelMat==i);
    linidx=sub2ind(size(LabelMat),j,k);
    sumOrgThick=sum(torg(linidx));
    sumInorgThick=sum(tinorg(linidx));
    volFrac(i)=sumOrgThick./(sumOrgThick+sumInorgThick);
end

%% Do figures
figure('Name',Snew.particle,'NumberTitle','off','Position',[1,1,715,869]);
subplot(2,2,1),imagesc(xdat,ydat,torg),colorbar, 
axis image, 
title('organic thickness (m)'), 
xlabel('X (\mum)');
ylabel('Y (\mum)'); 
subplot(2,2,2),imagesc(xdat,ydat,tinorg),colorbar,axis image,
title('inorganic thickness (m)'), 
xlabel('X (\mum)');
ylabel('Y (\mum)');
subplot(2,2,3),imagesc(xdat,ydat,volFraction),colorbar,
axis image,
title('organic volume fraction'),
xlabel('X (\mum)');
ylabel('Y (\mum)');
subplot(2,2,4),hist(volFrac), 
title('Organic Volume Fraction'),
xlabel('volume fraction'),
ylabel('#');

%% Carbox
im3(Mask==0)=0;
im3(im3>2)=0;
im3(im3<0)=0;
im3=medfilt2(im3);

% %% Plot figures
figure,
subplot(2,2,1),imagesc(im1),colorbar, axis image, title C=C
subplot(2,2,2),imagesc(im2),colorbar, axis image, title pre/post
subplot(2,2,3),imagesc(im3),colorbar, axis image, title Carb
subplot(2,2,4),LabelMat=raw2maskMap(Snew,Mask),axis image;

%% prepare outputs
Snew.VolFrac=volFrac;
DiffMap(:,:,1)=im2;
DiffMap(:,:,3)=im1;
DiffMap(:,:,5)=im3;
ThickMap(:,:,1)=torg;
ThickMap(:,:,2)=tinorg;
ThickMap(:,:,3)=volFraction;
Snew.DiffMap=DiffMap;
Snew.LabelMat=LabelMat;
Sout=Snew;
Sout=PartLabelCompSize(Sout);
Snew.ThickMap=ThickMap;
Snew.VolFrac=volFrac;



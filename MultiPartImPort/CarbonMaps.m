function Snew=CarbonMaps(Snew,varargin)
%% Snew=CarbonMaps(Snew,sp2,savepath,sample{j})
%% Snew=CarbonMaps(Snew,35)
%% Input
%   Snew is the stack structure produced using functions OdStack.m and
%   AlignStack.m or any bastardization of those
%% Output
% Snew.Maps(:,:,1) is a carbon map
% Snew.Maps(:,:,2) is a pre/post ratio map
% Snew.Maps(:,:,3) is a sp2 carbon map
% Snew.BinCompMap is a cell array of binary component maps
%                 ={carb,prepost,sp2}
% Snew.CompSize=[OCArea,InArea,ECArea,TotalParticleArea]
% RCM, UOP, 2013
energy=Snew.eVenergy;
stack=Snew.spectr;
subdim=ceil(sqrt(length(energy)));

if length(Snew.eVenergy)<2
    beep
    disp('too few images for this mapping routine');
    return
end
test=energy(energy<319 & energy>277);
if isempty(test)
    beep
    disp('this is not the carbon edge')
    return
end
if isempty(varargin)
    spThresh=0.35;
    figsav=0;
    nofig=0;
elseif length(varargin)==1
    spThresh=varargin{1};
    figsav=0;
    nofig=0;
elseif length(varargin)==2
    figsav=0;
    spThresh=varargin{1};
    nofig=1;
elseif length(varargin)==3
    spThresh=varargin{1};
    figsav=1;
    rootdir=varargin{2};
    sample=varargin{3};
    nofig=0;
end
if spThresh>1
    disp('sp2 threshold input as percent, dividing by 100 for diffmaps');
    spThresh=spThresh/100;
end

energy=Snew.eVenergy;
stack=Snew.spectr;
subdim=ceil(sqrt(length(energy)));
if nofig==0&&length(energy)<6
    figure('NumberTitle','off','Name',sprintf('%s%s',Snew.particle,' Single Energy Images'));
    for i=1:length(energy)
        subplot(subdim,subdim,i)
        imagesc([0, Snew.Xvalue],[0,Snew.Yvalue],stack(:,:,i)),...
            %             set(gca,'Clim',[0,1.5]),
        axis image
        xlabel('X (\mum)');
        ylabel('Y (\mum)');
        colormap('gray'),
        colorbar
        plottitle=sprintf('%geV',energy(i));
        title(plottitle);
    end
end
if figsav==1
    filename=sprintf('%s%s%s%s',rootdir,sample,Snew.particle,'_SingleEnergyIms');
    saveas(gcf,filename,'png');
end

% %% identify particles based on maps
% for i=length(energy)
%     GrayImage=mat2gray(stack(:,:,i)); %% Turn into a greyscale with vals [0 1]
%     GrayImage=imadjust(GrayImage,[0 1],[0 1],0.1); %% increase contrast
%     GrayImage=medfilt2(GrayImage);  %% something weird was happening
%
%     %     figure,imagesc(GrayImage),colorbar
%     % %to the pixels on the corner
%     Thresh=graythresh(GrayImage); %% Otsu thresholding
%     Mask=im2bw(GrayImage,Thresh); %% Give binary image
%     %     figure,imagesc(Mask);
%     SE = strel('disk', 1, 0);
%     binmap = imdilate(Mask,SE);
%     % binmap = bwareaopen(Mask,5);
%     %     figure,imagesc(binmap);
%     LabelMat=bwlabel(binmap,8);
% end
% %%
% %%
sp2idx=find(energy>284.5 & energy<285.6);
preidx=find(energy>277 & energy<283);
carboxidx=find(energy>288 & energy<289);
postidx=find(energy>310 & energy<325);
if length(Snew.eVenergy)>10
    sp2idx=round(mean(sp2idx));
    preidx=preidx(1);
    postidx=postidx(end);
    carboxidx=round(mean(carboxidx));
end
%% Find particles
meanim=sum(Snew.spectr,3);
if isempty(carboxidx)
    meanim=Snew.spectr(:,:,postidx);
else
    meanim=Snew.spectr(:,:,carboxidx);
end
meanim(meanim>0.2)=0.2;
meanim(meanim<0)=0;
% figure,imagesc(meanim),colormap gray,colorbar
GrayImage=mat2gray(meanim); %% Turn into a greyscale with vals [0 1]
% GrayImage=imadjust(GrayImage,[0 1],[0 1],0.75); %% increase contrast
% figure,imagesc(GrayImage),colormap gray,colorbar
Thresh=graythresh(GrayImage); %% Otsu thresholding
binmap=im2bw(GrayImage,Thresh); %% Give binary image
binmap=imclearborder(binmap); %% Remove particles from edges
% SE = strel('disk', 1, 0);
% figure,imagesc(binmap)
% binmap = bwareaopen(binmap,3);
binmap=medfilt2(binmap);

% figure,
% subplot(1,2,1),imagesc(GrayImage),colormap gray,colorbar,axis image
% subplot(1,2,2),imagesc(binmap),axis image
% pause(1);
% figure,imagesc(binmap)
%% Define Label Matrix
LabelMat=bwlabel(binmap,8);
%% Filter noise that appears as Small Particles
for i=1:max(max(LabelMat))
    [a1,b1]=find(LabelMat==i);
    linidx1=sub2ind(size(LabelMat),a1,b1);
    if length(linidx1)<7
        LabelMat(linidx1)=0;
    end
end
LabelMat(LabelMat>0)=1;
LabelMat=bwlabel(LabelMat);

%% Assign Particle Serial Numbers and directories
NumPart=max(max(LabelMat));
PartZero=str2num(strcat(Snew.particle(5:end),'0000'));
PartSN=[1:NumPart]+PartZero;
dirstr=pwd;
PartDir=strcat(dirstr);
PartDirs=cell(NumPart,2);
PartDirs(:,1)={PartDir};
PartDirs(:,2)={strcat('F',Snew.particle,'.mat')};

%% Carbon Map
carb=stack(:,:,postidx)-stack(:,:,preidx);
if nofig==0
    figure('NumberTitle','off','Name',sprintf('%s%s',Snew.particle,' Maps'));
    subplot(2,2,1),
    imagesc([0, Snew.Xvalue],[0,Snew.Yvalue],carb),colormap gray,colorbar
    caxis([0 max(max(carb))])
    axis image
    title('PostEdge-PreEdge');
    xlabel('X (\mum)');
    ylabel('Y (\mum)');
    end
carb1=carb;                  % taking STD of regions not having particles
carb1(carb1<0)=0; % removes regions having negative total carbon
% figure,imagesc(carb1),colormap gray,colorbar
carb1=carb1.*binmap;
Snew.TotC=carb1;
carb1 = bwareaopen(carb1,3);
carbmask=carb1;
carbmask(carbmask>0)=1;
carbmask=medfilt2(carbmask);
% figure,imagesc(carbmask),colormap gray,colorbar

%% Inorganic Map
prepost=stack(:,:,preidx)./stack(:,:,postidx);
pre=stack(:,:,preidx);
% figure,imagesc(pre),colormap gray,colorbar
Noise=std(pre(binmap==0));
pre1=pre;
pre1(pre1<3*Noise)=0;
premask=pre1;
premask(premask>0)=1;
% figure,imagesc(premask),colormap gray,colorbar
prepost=prepost.*premask.*binmap;
if nofig==0
    subplot(2,2,2),imagesc([0, Snew.Xvalue],[0,Snew.Yvalue],prepost),colormap gray,colorbar
    axis image
    set(gca,'Clim',[0,1.0])
    xlabel('X (\mum)');
    ylabel('Y (\mum)');
    title('PreEdge/PostEdge');
end
prepost(prepost<0.5)=0;
% figure,imagesc(prepost),colormap gray,colorbar
% set(gca,'Clim',[0,1.0])
prepostmask=prepost;
prepostmask(prepost>1)=1;
prepostmask = bwareaopen(prepostmask,5);
% figure,imagesc(prepostmask),colormap gray,colorbar

%% SP2 Map; HOPG(285.25)=0.8656; HOPG(310)=0.4512;
if ~isempty(sp2idx)
    doublecarb=stack(:,:,sp2idx)-stack(:,:,preidx); % make sp2 map by subtracting preedge
    % if nofig==0
    % figure,imagesc(doublecarb),colormap gray,colorbar,title('285.4-278')
    % end
    doubCarbNois=std(doublecarb(binmap==0)); % calculate the noise of the sp2 peak by
    doublecarb1=doublecarb;
    doublecarb2=doublecarb./...
        (stack(:,:,postidx)-stack(:,:,preidx))*(0.4512/0.8656);
    doublecarb1(doublecarb1<3*doubCarbNois)=0; % removes regions with sp2 less than 3x S/N
    % figure,imagesc(doublecarb1),colormap gray,colorbar
    doublecarb1=doublecarb1.*binmap;          % removes regions not containing carbon
    spmask=doublecarb1;
    spmask(doublecarb1>0)=1;                  % make binary sp2 mask
    % figure,imagesc(spmask),colormap gray
    % figure,imagesc(doublecarb1),colormap gray,colorbar
    sp2=(stack(:,:,sp2idx)-stack(:,:,preidx))./...
        (stack(:,:,postidx)-stack(:,:,preidx))*(0.4512/0.8656).*spmask; % calculate %sp2 of masked images
    if nofig==0
        subplot(2,2,3),imagesc([0, Snew.Xvalue],[0,Snew.Yvalue],sp2), colormap gray,...
            set(gca,'Clim',[0,1.0]),
        axis image
        xlabel('X (\mum)');
        ylabel('Y (\mum)');
        colorbar
        title('%sp^{2} Map')
    end
    sp2NoThresh=doublecarb2;
    sp2NoThresh(sp2NoThresh<0)=NaN;
    sp2NoThresh(sp2NoThresh>1)=1;
    Snew.sp2=sp2NoThresh;
    sp2(sp2<spThresh)=0;                                                     % threshold everythin less than 40% sp2
    % figure,
    % imagesc([0, Snew.Xvalue],[0,Snew.Yvalue],sp2), colormap gray,...
    %     set(gca,'Clim',[0,1.0]),
    % colorbar
    
    %     colormap('gray'),
    finSp2mask=sp2;
    finSp2mask(sp2>0)=1;
    % figure,imagesc(finSp2mask),colormap gray
    
    %% get rid of small few pixel regions
    finSp2mask=bwlabel(finSp2mask,8);
    % figure,imagesc(finSp2mask),colormap jet
    for i=1:max(max(finSp2mask))
        [a1,b1]=find(finSp2mask==i);
        linidx1=sub2ind(size(finSp2mask),a1,b1);
        if length(linidx1)<7
            finSp2mask(linidx1)=0;
        end
    end
    finSp2mask(finSp2mask>0)=1;
    bw=im2bw(finSp2mask);
    
    % figure,imagesc(bw),colormap gray
    %ImStruct=regionprops(bw,'Eccentricity','MajorAxisLength','MinorAxisLength','ConvexHull');
    ImStruct=regionprops(bw,'Eccentricity','MajorAxisLength','MinorAxisLength','ConvexArea','Area');
    Ecc = reshape([ImStruct.Eccentricity],size(ImStruct));
    Maj=reshape([ImStruct.MajorAxisLength],size(ImStruct));
    Min=reshape([ImStruct.MinorAxisLength],size(ImStruct));
    %ImStruct.ConvexArea
    %ImStruct.Area
    Cvex=reshape([ImStruct.ConvexArea],size(ImStruct));
    Area=reshape([ImStruct.Area],size(ImStruct));
    Snew.SootEccentricity=Ecc;
    Snew.SootMajorAxisLength=Maj;
    Snew.SootMinorAxisLength=Min;
    Snew.SootConvexArea=Cvex;
    Snew.SootArea=Area;
    if nofig==0
        figure,imagesc(doublecarb),colormap gray,colorbar,title('285.4-278')
    end
else
    sp2=zeros(size(binmap));
    finSp2mask=zeros(size(binmap));
    doublecarb=zeros(size(binmap));
end


% figure,imagesc(finSp2mask),colormap gray
%% Combine maps,
BinCompMap{1}=carbmask;
BinCompMap{2}=prepostmask;
BinCompMap{3}=finSp2mask;
%% This first loop creates masks for the individual components over the
%% entire field of view. Each component is then defined as a colored
%% component for visualization.
ColorVec=[0,170,0;0,255,255;255,0,0;255,170,0;255,255,255]; %% rgb colors of the different components

MatSiz=size(LabelMat);
RgbMat=zeros([MatSiz,3]);
RedMat=zeros(MatSiz);
GreMat=zeros(MatSiz);
BluMat=zeros(MatSiz);

[l,m]=find(LabelMat>0);
labidx=sub2ind(MatSiz,l,m);
cnt=1;
for i=1:length(BinCompMap)%i=[1,2,3] %% loop over chemical components
    [j,k]=find(BinCompMap{cnt}>0); %% find index of >0 components
    if ~isempty(j) || ~isempty(k)  %% this conditional defines a color for the component areas (if it exists)
        linidx=sub2ind(size(BinCompMap{cnt}),j,k); %% change to linear index
        rejidx=setdiff(linidx,labidx); %% find componets that overlap with particles
        BinCompMap{cnt}(rejidx)=0; %% set regions that dont overlap to zero
        linidx=sub2ind(size(BinCompMap{cnt}),find(BinCompMap{cnt}>0)); %% get linear index of regions having nonzero values
        RedMat(linidx)=ColorVec(cnt,1); %% define the color for the ith component
        GreMat(linidx)=ColorVec(cnt,2);
        BluMat(linidx)=ColorVec(cnt,3);
        trmat=zeros(size(RedMat));
        tgmat=zeros(size(RedMat));
        tbmat=zeros(size(RedMat));
        trmat(linidx)=ColorVec(cnt,1);
        tgmat(linidx)=ColorVec(cnt,2);
        tbmat(linidx)=ColorVec(cnt,3);
        ccmap{cnt}(:,:,1)=trmat;
        ccmap{cnt}(:,:,2)=tgmat;
        ccmap{cnt}(:,:,3)=tbmat;
        clear trmat tgmat tbmat
    else
        ccmap{cnt}=zeros(MatSiz(1),MatSiz(2),3);
    end
    cnt=cnt+1;  %% this counter keeps track of the indivdual components.
    clear j k linidx GrayImage Thresh Mask rejidx;
end
clear l m
%% This second loop assigns labels over individual particles defined
%% previously
% LabelStr={'OC','In','K','EC'};
LabelStr={'OC','In','EC'};

CompSize=zeros(NumPart,length(LabelStr)+1); %% CompSize=[OC,In,EC,TotalParticle]
PartLabel={};
for i=1:NumPart  %% Loop over particles defined in Diffmaps.m
    PartLabel{i}='';
    for j=1:length(LabelStr)  %% Loop over chemical components
        [a1,b1]=find(LabelMat==i);  %% get particle i
        [a2,b2]=find(BinCompMap{j}>0); %% get component j
        if ~isempty([a1,b1]) && ~isempty([a2,b2])
            linidx1=sub2ind(size(LabelMat),a1,b1); %% Linear index for particle
            linidx2=sub2ind(size(BinCompMap{j}),a2,b2); %% Linear index for component
            IdxCom=intersect(linidx1,linidx2); %% find common indices
            if length(IdxCom)>3%0.05*length(linidx1) %% if component makes up greater than 2% of the pixels of the particle...
                PartLabel{i}=strcat(PartLabel{i},LabelStr{j}); %% give label of component.
                CompSize(i,j)=length(IdxCom); %% number of pixels in the component.
            end
        end
    end
    if isempty(PartLabel{i})
        PartLabel{i}='NoID'; %% Particles identified by Otsu's mehod here but not in Particle map script
    end
    CompSize(i,j+1)=length(linidx1);  %% number of pixels in the particle
    clear linidx1 linidx2 IdxCom a1 b1 a2 b2;
end
if isempty(PartLabel)
    PartLabel='NoID';
else
    PartLabel=PartLabel;
end

%% Define Outputs
Snew.LabelMat=LabelMat;
Snew.PartLabel=PartLabel;
Snew.PartSN=PartSN';
binmap=zeros(size(LabelMat));
binmap(LabelMat>0)=1;
Snew.binmap=binmap;
Snew=ParticleSize(Snew);
XSiz=Snew.Xvalue/MatSiz(1);
YSiz=Snew.Yvalue/MatSiz(2);
CompSize=CompSize.*(XSiz*YSiz); %% Area of components in um^2;  CompSize=[OCArea,InArea,ECArea,TotalParticleArea]
Snew.CompSize=CompSize;
Snew.PartDirs=PartDirs;

RgbMat(:,:,1)=RedMat;
RgbMat(:,:,2)=GreMat;
RgbMat(:,:,3)=BluMat;
Snew.RGBCompMap=RgbMat;
for i=1:length(BinCompMap)
    temp{i}=BinCompMap{i};
    temp{i}(temp{i}>1)=1;
end
xdat=[0:XSiz:Snew.Xvalue];
ydat=[0:YSiz:Snew.Yvalue];

%% Combined Masks
if nofig==0
    subplot(2,2,4),
    image(xdat,ydat,uint8(RgbMat))
    title(sprintf('Red=sp2>%g%,Blue=pre/post>0.5,green=Organic',spThresh));
    axis image
    xlabel('X (\mum)');
    ylabel('Y (\mum)');
    if figsav==1
        filename=sprintf('%s%s%s%s',rootdir,sample,Snew.particle,'_Maps');
        saveas(gcf,filename,'png');
    end
end
xysiz=size(carb);
Snew.Maps=zeros(xysiz(1),xysiz(2),3);
Snew.Maps(:,:,1)=carb;
Snew.Maps(:,:,2)=prepost;
Snew.Maps(:,:,3)=sp2;
% if figsav==1
% filename=sprintf('%s%s%s%s',rootdir,sample,particle,'_f2_thresh');
% saveas(gcf,filename,'png');
% end
Snew.BinCompMap=temp;
% Snew=MultPartAvSpec(Snew);
% if figsav==1
% filename=sprintf('%s%s%s%s',rootdir,sample,particle,'_f3_spec');
% saveas(gcf,filename,'png');
% close all
% end


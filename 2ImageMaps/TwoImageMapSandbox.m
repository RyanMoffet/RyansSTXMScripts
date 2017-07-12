stack=Snew.spectr;
% stack(stack>3)=0;

%% mask particles
stack(stack>5)=5; %% clip really large values of OD
figure,imagesc(stack(:,:,2)),colorbar
GrayImage=mat2gray(stack(:,:,2)); %% Turn into a greyscale with vals [0 1]
% GrayImage=medfilt2(GrayImage);  %% something weird was happening
GrayImage=imadjust(GrayImage,[0 1],[0 1],0.1); %% increase contrast
figure,imagesc(GrayImage),colorbar
% %to the pixels on the corner
Thresh=graythresh(GrayImage); %% Otsu thresholding
Mask=im2bw(GrayImage,Thresh); %% Give binary image
figure,imagesc(Mask);
SE = strel('disk', 2, 0)
mask3 = imdilate(Mask,SE)
figure,imagesc(mask3);

%% this bit will remove the TEM grid cell 
CC = bwlabel(mask3);
lvec=zeros(max(CC),1)
for i=1:max(CC)
    idx=find(CC==i);
    lvec(i)=length(idx);
end
[pixmax,maxidx]=max(lvec);
mask3(CC==maxidx)=0;
figure,imagesc(mask3);
% close all
%% Do the map
RawMap=stack(:,:,2)-stack(:,:,1);
RawMap=RawMap.*mask3;
RawMap(RawMap<0)=0;
% RawMap(RawMap>0.25)=0.25

%% plots!! images!!
figure,imagesc(RawMap),colormap gray,colorbar,hold on
figure,imagesc(RawMap),colorbar,hold on

%%For coatings -- gray scale
returnimage=RawMap./max(max(RawMap));
returnimage=returnimage.*255;
returnimage=uint8(returnimage);
ctable=gray(255);
rmat=zeros(size(returnimage));
gmat=zeros(size(returnimage));
bmat=zeros(size(returnimage));
for i=1:length(returnimage(:,1))
    for j=1:length(returnimage(1,:))
        if returnimage(i,j)>0
            rmat(i,j)=ctable(returnimage(i,j),1);
            gmat(i,j)=ctable(returnimage(i,j),2);
            bmat(i,j)=ctable(returnimage(i,j),3);
        end
    end
end
rgbmat(:,:,1)=rmat;
rgbmat(:,:,2)=gmat;
rgbmat(:,:,3)=bmat;
figure,image([0, Snew.Xvalue],[0,Snew.Yvalue],rgbmat),hold on,set(gca,'Clim',[0 5]), 
colormap gray
colorbar,
[B,L] = bwboundaries(mask3);
[xmax,ymax,emax]=size(stack);
for k = 1:length(B)
    boundary = B{k};
    plot(boundary(:,2).*(S.Xvalue./xmax), ...
        boundary(:,1).*(S.Yvalue./ymax), 'm', 'LineWidth', 1)
end
hold off

%%for inclusions -- color map
MapThresh=graythresh(RawMap); %% Otsu thresholding
MapMask=im2bw(RawMap,MapThresh); %% Give binary image
IncMap=RawMap.*MapMask;
returnimage=IncMap./max(max(IncMap));
returnimage=returnimage.*255;
returnimage=uint8(returnimage);
ctable=jet(255);
rmat=zeros(size(returnimage));
gmat=zeros(size(returnimage));
bmat=zeros(size(returnimage));
for i=1:length(returnimage(:,1))
    for j=1:length(returnimage(1,:))
        if returnimage(i,j)>0
            rmat(i,j)=ctable(returnimage(i,j),1);
            gmat(i,j)=ctable(returnimage(i,j),2);
            bmat(i,j)=ctable(returnimage(i,j),3);
        end
    end
end
rgbmat(:,:,1)=rmat;
rgbmat(:,:,2)=gmat;
rgbmat(:,:,3)=bmat;
rgbmat(:,:,3)=rgbmat(:,:,3).*MapMask;
figure,image([0, Snew.Xvalue],[0,Snew.Yvalue],rgbmat),hold on,
colormap jet,
set(gca,'Clim',[0 5]), 
colorbar,
[B,L] = bwboundaries(mask3);
[xmax,ymax,emax]=size(stack);
for k = 1:length(B)
    boundary = B{k};
    plot(boundary(:,2).*(S.Xvalue./xmax), ...
        boundary(:,1).*(S.Yvalue./ymax), 'w', 'LineWidth', 1)
end
hold off

function Snew=GenericStackMap(Snew)

%% Generate LabelMat variable...code taken from CarbonMaps
%% Find particles
meanim=mean(Snew.spectr,3);
meanim(meanim>.2)=.2;
% figure,imagesc(meanim),colormap gray,colorbar
GrayImage=mat2gray(meanim); %% Turn into a greyscale with vals [0 1]
% GrayImage=imadjust(GrayImage,[0 1],[0 1],0.52); %% increase contrast
Thresh=graythresh(GrayImage); %% Otsu thresholding
binmap=im2bw(GrayImage,Thresh); %% Give binary image
% SE = strel('disk', 1, 0);
% figure,imagesc(binmap)
% binmap = bwareaopen(binmap,3);
binmap=medfilt2(binmap);

% figure,imagesc(binmap)
LabelMat=bwlabel(binmap,8);
Snew.LabelMat=LabelMat;

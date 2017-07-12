function Mask=MakeMask(Im);


GrayImage=mat2gray(Im); %% Turn into a greyscale with vals [0 1]
% figure,imagesc(GrayImage),colormap gray
GrayImage=imadjust(GrayImage,[0 1],[0 1],0.1); %% increase contrast 
GrayImage=medfilt2(GrayImage);
Thresh=graythresh(GrayImage); %% Otsu thresholding
Mask=im2bw(GrayImage,Thresh); %% Give binary image
% figure,imagesc(Mask),colormap gray
% Mask=bwlabel(Mask,8);


function Mask=raw2maskCtoO(Sin)

energy=Sin.eVenergy;
% eidx=find(energy>288 & energy<289);
TotImage=mean(Sin.spectr(:,:,:),3);  %% Use average of all images in stack
GrayImage=mat2gray(TotImage); %% Turn into a greyscale with vals [0 1]
GrayImage=imadjust(GrayImage,[0 1],[0 1],0.1); %% increase contrast 
GrayImage=medfilt2(GrayImage);
Thresh=graythresh(GrayImage); %% Otsu thresholding
Mask=im2bw(GrayImage,Thresh); %% Give binary image
Mask=bwlabel(Mask,8);
% figure,
% subplot(1,3,1);
% imagesc(TotImage);
% colormap(gray);
% subplot(1,3,2);
% imagesc(GrayImage);
% subplot(1,3,3);
NPart=max(max(Mask));
for i=1:NPart
    [j,k]=find(Mask==i);
    linidx=sub2ind(size(Mask),j,k);
    if length(linidx)<10
        Mask(j,k)=0;
    end
    clear j k;
end
Mask=bwlabel(Mask,8);

imagesc(Mask),
for i=1:max(max(Mask))
    [k,j]=find(Mask==i);
    text(j(1),k(1),num2str(i),'color',[1,1,1],'FontWeight','bold')
    clear i j
end

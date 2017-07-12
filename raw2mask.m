function Mask=raw2mask(Sin,varargin)

if length(varargin)==1
    nofig=1;
else
    nofig=0;
end

energy=Sin.eVenergy;
eidx=find(energy>288 & energy<295);
% eidx=find(energy>280 & energy<320);
TotImage=mean(Sin.spectr(:,:,eidx),3);  %% Use average of all images in stack
TotImage(TotImage==Inf)=0;
GrayImage=mat2gray(TotImage); %% Turn into a greyscale with vals [0 1]
GrayImage=imadjust(GrayImage,[0 1],[0 1],0.1); %% increase contrast 
GrayImage=medfilt2(GrayImage);
Thresh=graythresh(GrayImage); %% Otsu thresholding
Mask=im2bw(GrayImage,Thresh); %% Give binary image
Mask=bwlabel(Mask,4);
% figure,
% subplot(1,3,1);
% imagesc(TotImage);
% colorbar
% colormap(gray);
% subplot(1,3,2);
% imagesc(GrayImage);
% colorbar
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
Mask=bwlabel(Mask,4);

MatSiz=size(Sin.spectr);
XSiz=Sin.Xvalue/MatSiz(2);
YSiz=Sin.Yvalue/MatSiz(1);
xdat=[0:XSiz:Sin.Xvalue-XSiz];
ydat=[0:YSiz:Sin.Yvalue-YSiz];
%
if nofig==0
    imagesc(xdat,ydat,Mask),
    for i=1:max(max(Mask))
        [k,j]=find(Mask==i);
        linidx=sub2ind(size(Mask),k,j);
        [x,y]=ind2sub(size(Mask),linidx(1));
        text(xdat(y),ydat(x),num2str(i),'color',[0,0,0],'FontSize',12,'FontWeight','bold')
        clear j k
    end
end
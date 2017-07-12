function Sout=DistCent(Sin)
[nx,ny]=size(Sin.LabelMat);
TotImage=nansum(Sin.spectr,3);
TotImage(TotImage==Inf)=0;
mask=zeros(nx,ny);

% figure,
% imagesc(Sin.LabelMat),hold on,

for i=1:max(max(Sin.LabelMat))  %% loop over particles
    [xtmp,ytmp]=find(Sin.LabelMat==i); %% find particle index i
    linidx=sub2ind(size(Sin.LabelMat),xtmp,ytmp);  %% change to linear index
    xhat=round(nansum(xtmp.*TotImage(linidx))/nansum(TotImage(linidx)));  %% calc centroid x
    yhat=round(nansum(ytmp.*TotImage(linidx))/nansum(TotImage(linidx)));  %% calc centroid y
    cent{i}=[yhat,xhat]; %% somehow x and y got mixed...
%     plot(yhat,xhat,'w.','MarkerSize',10),hold on,
    mask(abs(xhat),abs(yhat))=1;  %% set particle centroids to 1
end

D1 = bwdist(mask,'euclidean'); %% distance transform of binary image
% imcontour(D1),hold off,
% 
mask2=zeros(nx,ny);
mask2(Sin.LabelMat>0)=1;
if isequal(size(D1),size(mask2))
    D2=D1.*mask2.*mean([Sin.Xvalue/nx,Sin.Yvalue/ny]);
%     figure,
%     imagesc(D2./max(max(D2))),hold on,
%     imcontour(D1./max(max(D1))),hold off,
    Sout=Sin;
    Sout.DistToCent=D2;
else
    Sout=Sin;
    Sout.DistToCent=zeros(size(Sin.spectr(:,:,1)));
end

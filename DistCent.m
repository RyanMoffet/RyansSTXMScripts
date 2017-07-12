function Sout=DistCent(Sin)
[nx,ny]=size(Sin.LabelMat);
TotImage=nansum(Sin.spectr,3);
TotImage(TotImage==Inf)=0;
SootMap=Sin.Maps(:,:,3);
mask=zeros(nx,ny);
[Rad,cx,cy]=max_inscribed_circle_STXM(Sin, 0); %% finds the radius of the maximum inscribed circle

% IncLoc=zeros(length(Sin.Size));
cnt=1;
% figure,
% imagesc(Sin.LabelMat),hold on,
%% this loop marks out the particle centers to use in the call to bwidst below
[xtmpSoot,ytmpSoot]=find(Sin.BinCompMap{3}>0); %% soot inclusion particle index i
Sootlinidx=sub2ind(size(SootMap),xtmpSoot,ytmpSoot);  %% change to linear index
SootCentLinidx=[];
for i=1:max(max(Sin.LabelMat))  %% loop over particles
    [xtmp,ytmp]=find(Sin.LabelMat==i); %% find particle index i
    linidx{i}=sub2ind(size(Sin.LabelMat),xtmp,ytmp);  %% change to linear index
    xhat=round(nansum(xtmp.*TotImage(linidx{i}))/nansum(TotImage(linidx{i})));  %% calc centroid x
    yhat=round(nansum(ytmp.*TotImage(linidx{i}))/nansum(TotImage(linidx{i})));  %% calc centroid y
    cent{i}=[yhat,xhat]; %% somehow x and y got mixed...
    %     plot(yhat,xhat,'w.','MarkerSize',10),hold on,
    mask(abs(xhat),abs(yhat))=1;  %% set particle centroids to 1
    sootIncLinidx=intersect(Sootlinidx,linidx{i});
    if ~isempty(sootIncLinidx)
        [subsootx,subsooty]=ind2sub(size(SootMap),sootIncLinidx);
        Sootxhat=round(nansum(subsootx.*SootMap(sootIncLinidx))/nansum(SootMap(sootIncLinidx)));  %% calc centroid x
        Sootyhat=round(nansum(subsooty.*SootMap(sootIncLinidx))/nansum(SootMap(sootIncLinidx)));  %% calc centroid y
        SootCentLinidx(cnt)=sub2ind(size(SootMap),Sootxhat,Sootyhat); %% somehow x and y got mixed...
        %         plot(Sootyhat,Sootxhat,'k.','MarkerSize',10),hold on,
        clear sootIncLinidx
        cnt=cnt+1;
    end
end

D1 = bwdist(mask,'euclidean'); %% distance transform of binary image
Boundaries=bwboundaries(mask,'noholes');
% imcontour(D1),hold off,

mask2=zeros(nx,ny);
mask2(Sin.LabelMat>0)=1; %% this is redundant as we already have Sin.binmap
if isequal(size(D1),size(mask2))
    D2=D1.*mask2.*mean([Sin.Xvalue/nx,Sin.Yvalue/ny]);
    %     figure,
    %     imagesc(D2./max(max(D2))),hold on,
    %     imcontour(D1./max(max(D1))),hold on,
    
    Sout=Sin;
    Sout.DistToCent=D2;
    D3=D2;D4=D1;
    for i=1:length(linidx) %% loop over all particles in LabelMat
        D3(linidx{i})=D3(linidx{i})./max(D3(linidx{i}));%% this normalizes the distance from the center of the particle to the furthest edge
        D4(linidx{i})=D4(linidx{i})./Rad(i);%% this normalizes the distance from the center of the particle to radius of the largest inscribed circle
    end
    %% mark out relative distance of soot inclusion from the center.
    if isempty(SootCentLinidx)
        Sout.SootDistCent=[];
        Sout.SootDistCentInscribed=[];
    else
        Sout.SootDistCent=D3(SootCentLinidx);
        Sout.SootDistCentInscribed=D4(SootCentLinidx);
    end
    
else
    Sout=Sin;
    Sout.DistToCent=zeros(size(Sin.spectr(:,:,1)));
    Sout.SootDistCent=[];
    Sout.SootDistCentInscribed=[];
end

return



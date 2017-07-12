function [pcaMap,C,eImages,temp_spec1]=pcaClusterEmax(S,lowestorder,highestorder,g,nofC,Emax)
emax=length(S.eVenergy(S.eVenergy<Emax));
[ymax,xmax,Eorig]=size(S.spectr);

% init data matrix
D=zeros(emax,ymax*xmax);

% reshape 3D stack data --> 2D data matrix
for k=1:emax
    
    D(k,:)=reshape(S.spectr(:,:,k),1,ymax*xmax);
    
end

% calculate spectral covariance matrix
Z=D*D';

% eigenspectra & eigencalues of the covariance matrix:
[C,Lambda]=eig(Z);

% sort eigenvectors & eigenspectra in ascending oder:
C=fliplr(C);
Lambda=rot90(Lambda,2);

% eigenimage matrix:
R=C'*D;

% reshape eigenimages to original stack structur
eImages=zeros(ymax,xmax,emax);

for k=1:emax
    eImages(:,:,k)=reshape(R(k,:),ymax,xmax);
end

% calculate reduced eigenimage matrix:
Rred=R(lowestorder:highestorder,:);

% center eigenimage matrix around PC coordinate system origin, gamma scale eigenimage matrix (Lerotic, eqn(19))
meanvec=mean(Rred,2);

for k=1:size(Rred,1)
    
    Rred(k,:)=(Rred(k,:)-meanvec(k))*((Lambda(1,1)/Lambda(lowestorder-1+k,lowestorder-1+k))^g);
    
end


% cluster analysis on reduced eigenimage data:
idx=kmeans(transpose(Rred),nofC);

pcaMap=reshape(idx,ymax,xmax);
mask=S.LabelMat;
mask(mask>0)=1;
tmpmap=pcaMap.*mask;
%% make color map
colorTable=zeros(nofC+1,3);
colorTable(2:nofC+1,:)=jet(nofC);
[nx,ny]=size(tmpmap);
rmat=zeros(nx,ny);
gmat=zeros(nx,ny);
bmat=zeros(nx,ny);
for i=0:nofC
    tidx=sub2ind(size(tmpmap),find(tmpmap==i));
    rmat(tidx)=colorTable(i+1,1);
    gmat(tidx)=colorTable(i+1,2);
    bmat(tidx)=colorTable(i+1,3);
end
colormat=zeros(nx,ny,3);
colormat(:,:,1)=rmat;
colormat(:,:,2)=gmat;
colormat(:,:,3)=bmat;

figure,
% subplot(1,2,2)
imagesc(colormat)
colorbar
axis image
title('KMeans cluster component map','FontSize',11,'FontWeight','bold')

% subplot(1,2,1)
figure,
semilogy(diag(Lambda),'r+')
title('PCA eigenvalue magnitude','FontSize',11,'FontWeight','bold')
xlim([0 xmax+1])

% figure%('Position',[100 100 600 600])
% for k=1:9
% subplot(3,3,k)
% imagesc(reshape(R(k,:),size(S.spectr,1),size(S.spectr,2)))
% colorbar
% axis image
% end
% 
% figure%('Position',[200 200 600 600])
% for k=1:9
% subplot(3,3,k)
% plot(S.eVenergy,C(:,k))
% xlim([min(S.eVenergy) max(S.eVenergy)])
% end
% 
figure%('Position',[100 100 600 600])
nofSubs=ceil(sqrt(nofC));
V=S.spectr;
temp_spec=zeros(emax,nofC);
title('Average KMeans cluster spectra','FontSize',11,'FontWeight','bold')
j=0;
for k=1:nofC
    
    for cnt=1:Eorig
    
    buffer=V(:,:,cnt);
    temp_spec1(cnt,k)=mean(mean(buffer(pcaMap==k)));
    clear buffer
    
    end
    temp_spec=temp_spec1(:,k);
%     subplot(nofSubs,nofSubs,k)
    plot(S.eVenergy,temp_spec+j,'Color',colorTable(k+1,:),'LineWidth',1.5)
    xlim([S.eVenergy(1) S.eVenergy(end)])
    ylim([(min(temp_spec)-0.05*max(temp_spec)) (max(temp_spec)+0.05*max(temp_spec))])
    j=j+max(temp_spec);
    clear temp_spec
    hold on
end
set(gca,'YTickLabel',{},'YTick',zeros(1,0),'PlotBoxAspectRatio',[1/j,1,1])
xlim([280,320]);
ylim([0,j+.1]);
vline([285,288.6],'k:')
hold off

% figure,
% j=0;
% for i=1:length(ecspec)
%     plot(ecspec{i}(:,1),ecspec{i}(:,2)+j,'k-','LineWidth',2),hold on,
% %     legendstr{j+1}=textdata{i};
% %     textstr{j+1}=strcat(['Cluster ' textdata{i} sprintf(' N=%g',TakNums(i-1))]);
%     text(290,j+0.25,textstr{i});
%     j=j+max(ecspec{i}(:,2))
% %     j=j+1;
% end
% set(gca,'YTickLabel',{},'YTick',zeros(1,0),'PlotBoxAspectRatio',[1/j,1,1])
% xlim([280,320]);
% ylim([0,j+.1]);
% vline([285,288.6],'k:')
    
    


return
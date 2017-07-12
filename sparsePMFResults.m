function sparsePMFResults(S,k,w,h)


%% original stack dimensions
[ymax,xmax,emax]=size(S.spectr);
stack=S.spectr;
% mask=S.LabelMat;
% mask(mask>0)=1;
% for i=1:emax
%     stack(:,:,i)=stack(:,:,i).*mask;
% end

%% init data matrix
D=zeros(emax,ymax*xmax);

%% reshape 3D stack data --> 2D data matrix

for i=1:emax
    D(i,:)=reshape(stack(:,:,i),1,ymax*xmax);
end

[i,j]=find(D<0);
if ~isempty(i) | ~isempty(j)
    D=D+abs(min(min(D)));
end

%% perform factorization
% if length(varargin)==0 & sparse==0
%     [w,h]=nnmf(D,k);
% elseif length(varargin)==0 && sparse==1
%     fname='sparseResults'
%     [w,h] = nmfsc( D, k, 1, 1, fname, 1 )
%     w=W;h=H
% elseif length(varargin)==1;
%     [w,h]=nnmf(D,k,'w0',wo);
% end

%% calculate physical spectra
physSpec=zeros(size(w));

for i=1:k
    for j=1:emax
        hnew=h(i,:)./sum(h(i,:));
        physSpec(j,i)=sum(hnew.*D(j,:));
    end
    figure,plot(S.eVenergy,physSpec(:,i));
end


%% reshape eigenimages to original stack structur
eImages=zeros(ymax,xmax,k);

for i=1:k
    eImages(:,:,i)=reshape(h(i,:),ymax,xmax);
end

%% plot factors
for i=1:k
    figure('Name',sprintf('Factor%g',i))
    subplot(1,2,1),plot(S.eVenergy,w(:,i)),axis square,
    xlim([S.eVenergy(1),S.eVenergy(end)]),
    title(sprintf('Factor %g Spectrum',i))
    subplot(1,2,2),imagesc(eImages(:,:,i)),colormap gray,colorbar,axis image
    title(sprintf('Factor %g Image',i))
end

%% if there are three factors, do rgb  plot

if k==3
    figure('Name','RGBFactor%g')
    plotSvdRgb(eImages(:,:,1:3),S)
    rgb(:,:,1)=eImages(:,:,2);rgb(:,:,2)=eImages(:,:,1);rgb(:,:,3)=eImages(:,:,3);
    plotSvdRgb(rgb,S)
    rgb(:,:,1)=eImages(:,:,3);rgb(:,:,2)=eImages(:,:,2);rgb(:,:,3)=eImages(:,:,1);
    plotSvdRgb(rgb,S)
end

return
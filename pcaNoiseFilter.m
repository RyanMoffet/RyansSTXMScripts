function S = pcaNoiseFilter(Sin,PCAorder)

S=Sin;

[ymax,xmax,emax]=size(Sin.spectr);

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

% figure
% semilogy(diag(Lambda),'r+')
% title('PCA eigenvalue magnitude','FontSize',11,'FontWeight','bold')

% eigenimage matrix:
R=C'*D;

% reduce data content:

Dred=C(:,1:PCAorder)*R(1:PCAorder,:);

% reshape data matrix to original stack size:
spectr=zeros(ymax,xmax,emax);

for k=1:emax
    
    spectr(:,:,k)=reshape(Dred(k,:),ymax,xmax);
    
end;

S.spectr=spectr; 

return
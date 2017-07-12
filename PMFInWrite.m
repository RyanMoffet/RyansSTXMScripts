function Iz=PMFInWrite(S,Sraw,Name,Path)


%% original stack dimensions
[ymax,xmax,emax]=size(S.spectr);
stack=S.spectr;
rawstack=Sraw.spectr;

%% init data matrix
D=zeros(emax,ymax*xmax);
sD=D;

%% make particle mask
mask=S.LabelMat;
mask(mask>0)=1;

%% reshape 3D stack data --> 2D data matrix

for i=1:emax
    D(i,:)=reshape(stack(:,:,i),1,ymax*xmax);
    sD(i,:)=reshape(rawstack(:,:,i),1,ymax*xmax);
end

%% mask zeros and get rid of them to make smaller data matrix
Iz=find(mask);
nD=zeros(emax,length(Iz));
nsD=zeros(emax,length(Iz));
for i=1:emax
    nD(i,:)=D(i,Iz);
    nsD(i,:)=sD(i,Iz);
end
size(nD')

%% generate matrix files for PMF
Sname=strcat('std_dev');
stdev=zeros(size(nD));
% stdev(stdev==1)=0.022;
tstd=std(nD(1:5,:));
for j=1:length(nD(:,1))
    stdev(j,:)=tstd;
end
% stdev=(sqrt(nsD)./nsD).*nD;
% stdev(stdev<=0)=0.001;
% ExportMatrixDat(stdev',Sname,Path);

Dname=strcat('matrix');
ExportMatrixDat(nD',Dname,Path);


return
function colormat1=plotSvdRgbNew(svdin,Sin,cmpstr)
%% svdin is the svd matrix
%% Sin is the stack data
%% cmpstr is an array of strings that contain the different components
svdin(svdin<0)=0;
numcmp=length(cmpstr);
sootidx=find(strcmpi('sp2',cmpstr)==1); % find sp2 in component string
idx=1;
svdidx=1;
dims=size(svdin(:,:,1));
colormat=zeros(dims(1),dims(2),3);
if isempty(sootidx)                                %% red
    colormat(:,:,1)=zeros(size(svdin(:,:,1)));
    idx=idx+1;
else
    maxContrib=max(max(svdin(:,:,svdidx)));
    tmpmat=svdin(:,:,svdidx);
    tmpmat(tmpmat>.95.*maxContrib)=maxContrib; % get rid of outliers
    colormat(:,:,idx)=(255/maxContrib).*(tmpmat);
    idx=idx+1;
    svdidx=svdidx+1;
end
orgidx=find(strcmpi('COOH',cmpstr)==1);            %% green
if isempty(orgidx)
    colormat(:,:,2)=zeros(size(svdin(:,:,1)));
    idx=idx+1;
else
    maxContrib=max(max(svdin(:,:,svdidx)));
    tmpmat=svdin(:,:,svdidx); %.^2;  %% ADDED INCREASED CONTRAST!!!
    tmpmat(tmpmat>.95.*maxContrib)=maxContrib; % get rid of outliers
    colormat(:,:,idx)=(255/maxContrib).*(tmpmat);
    svdidx=svdidx+1;
    idx=idx+1;
end
inorgidx=find(strcmpi('Inorg',cmpstr)==1);           %% blue
if isempty(inorgidx)
    colormat(:,:,3)=zeros(size(svdin(:,:,1)));
    idx=idx+1;
else
    maxContrib=max(max(svdin(:,:,svdidx)));
    tmpmat=svdin(:,:,svdidx).^2;
    tmpmat(tmpmat>.95.*maxContrib)=maxContrib; % get rid of outliers
    colormat(:,:,idx)=(255/maxContrib).*(tmpmat);
    svdidx=svdidx+1;
    idx=idx+1;
end
cnt=1;


ymax=length(svdin(1,:,1));
xmax=length(svdin(:,1,1));
xticks=[1:xmax/6:xmax];
yticks=[1:ymax/6:ymax];
xticklabels=xticks.*(Sin.Xvalue./xmax);
yticklabels=yticks.*(Sin.Yvalue./ymax);

figure,
idx=find(Sin.LabelMat==0);
c1=colormat(:,:,1);
c2=colormat(:,:,2);
c3=colormat(:,:,3);

% c1(idx)=100;c2(idx)=100;c3(idx)=100; % make particle free regions gray
c1(idx)=0;c2(idx)=0;c3(idx)=0;
if numcmp==3 | numcmp==4
    colormat1(:,:,1)=c1;
%     colormat1(:,:,1)=c3;
    colormat1(:,:,2)=c2;
    colormat1(:,:,3)=c3;
elseif numcmp==2
    colormat1(:,:,1)=c1;
%     colormat1(:,:,1)=c3;
    colormat1(:,:,2)=c2;
    colormat1(:,:,3)=c3;
end
image([0,Sin.Xvalue],[0,Sin.Yvalue],uint8(colormat1));
set(gca,'TickDir','Out','FontSize',14,'FontName','Ariel')
axis image
% set(gca,'XTick',xticks,'XTickLabel',xticklabels,'YTick',yticks,'YTickLabel',...
%     yticklabels);
% plot_scale([1,1],Sin.Xvalue.*xmax,1,'w','\mum','h');
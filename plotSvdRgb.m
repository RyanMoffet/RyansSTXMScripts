function plotSvdRgb(svdin,Sin,cmpstr)
%% svdin is the svd matrix
%% Sin is the stack data
%% cmpstr is an array of strings that contain the different components
numcmp=length(cmpstr);
sootidx=find(strcmpi('sp2',cmpstr)==1) % find sp2 in component string
idx=1;
dims=size(svdin(:,:,1));
colormat=zeros(dims(1),dims(2),3);
if isempty(sootidx)
    tempa(:,:,1)=zeros(size(svdin(:,:,1)));% make zero if there is no sp2
    colomat(:,:,1)=zeros(size(svdin(:,:,1)));
else
    tempa(:,:,1)=svdin(:,:,sootidx); % make tempa = the svd matix if sp2 is present
    idx=idx+1;
end
orgidx=find(strcmpi('COOH',cmpstr)==1)
if isempty(orgidx)
    tempa(:,:,2)=zeros(size(svdin(:,:,1)));
    colomat(:,:,2)=zeros(size(svdin(:,:,1)));
else
    tempa(:,:,2)=svdin(:,:,orgidx);
    idx=idx+1;
end
inorgidx=find(strcmpi('Inorg',cmpstr)==1)
if isempty(inorgidx)
    tempa(:,:,3)=zeros(size(svdin(:,:,1)));
    colomat(:,:,3)=zeros(size(svdin(:,:,1)));
elseif isempty(sootidx)
    tempa(:,:,1)=svdin(:,:,1);
else
    tempa(:,:,3)=svdin(:,:,inorgidx);
    idx=idx+1;
end
cnt=1;
for i=1:3;  %% loop through the different matrices and scale to 255
    temp=tempa(:,:,cnt);
    temp(temp<0)=0;  % make mask
    maxContrib=max(max(temp));
    temp(temp>.95.*maxContrib)=maxContrib; % get rid of outliers
%     if i==2
%     temp(0<temp<.1.*maxContrib)=.1.*maxContrib;
%     end
    temp1=temp;
    colormat(:,:,i)=(255/maxContrib).*(temp); % normalize to 255 and store to colormat...multiply by mask to get rid of speckle
    cnt=cnt+1;
end
ymax=length(svdin(1,:,1));
xmax=length(svdin(:,1,1));
xticks=[1:xmax/6:xmax];
yticks=[1:ymax/6:ymax];
xticklabels=xticks.*(Sin.Xvalue./xmax);
yticklabels=yticks.*(Sin.Yvalue./ymax);

figure,
idx=find(Sin.LabelMat==0)
c1=colormat(:,:,1);
c2=colormat(:,:,2);
c3=colormat(:,:,3);

% c1(idx)=100;c2(idx)=100;c3(idx)=100; % make particle free regions gray
c1(idx)=0;c2(idx)=0;c3(idx)=0;
if numcmp==3 | numcmp==4
    colormat1(:,:,1)=c1;
    colormat1(:,:,2)=c2;
    colormat1(:,:,3)=c3;
elseif numcmp==2
    colormat1(:,:,1)=c1;
    colormat1(:,:,2)=c2;
    colormat1(:,:,3)=c3;   
end
image([0,Sin.Xvalue],[0,Sin.Yvalue],uint8(colormat1));
set(gca,'TickDir','Out','FontSize',14,'FontName','Ariel')
axis image
% set(gca,'XTick',xticks,'XTickLabel',xticklabels,'YTick',yticks,'YTickLabel',...
%     yticklabels);
% plot_scale([1,1],Sin.Xvalue.*xmax,1,'w','\mum','h');
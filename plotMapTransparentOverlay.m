function Sout=plotMapTransparentOverlay(Sin)

%% Choose components to map
MapMat(:,:,1)=Sin.DiffMap(:,:,1); %% inorganic
MapMat(:,:,2)=Sin.DiffMap(:,:,5); %% organic
MapMat(:,:,3)=Sin.DiffMap(:,:,1); %% inorganic

for i=1:length(MapMat(1,1,:));
    temp=MapMat(:,:,i);
    temp(temp<0)=0;
    maxContrib=max(max(temp));
    temp(temp>.95.*maxContrib)=maxContrib;
%     if i==2
%     temp(0<temp<.1.*maxContrib)=.1.*maxContrib;
%     end
    temp1=temp;
    if i==3
        colormat(:,:,i)=(100/maxContrib).*(temp);
    else
        colormat(:,:,i)=(255/maxContrib).*(temp);
    end
end
ymax=length(MapMat(1,:,1));
xmax=length(MapMat(:,1,1));
xticks=[1:xmax/6:xmax];
yticks=[1:ymax/6:ymax];
xticklabels=xticks.*(Sin.Xvalue./xmax);
yticklabels=yticks.*(Sin.Yvalue./ymax);

idx=find(Sin.LabelMat==0) %% define index for particle free regions
c1=zeros(size(colormat(:,:,1))); %% set red to zero
c2=colormat(:,:,2);
c3=colormat(:,:,3);

% c1(idx)=100;c2(idx)=100;c3(idx)=100; % make particle free regions gray
c1(idx)=0;c2(idx)=0;c3(idx)=0;

colormat1(:,:,1)=c1;
colormat1(:,:,2)=c2;
colormat1(:,:,3)=c3;
Sout=Sin;
Sout.TranspOverlay=colormat1;

figure,
image([0,Sin.Xvalue],[0,Sin.Yvalue],uint8(colormat1));
set(gca,'TickDir','Out','FontSize',14,'FontName','Ariel')
axis image




% % % % set(gca,'XTick',xticks,'XTickLabel',xticklabels,'YTick',yticks,'YTickLabel',...
% % % %     yticklabels);
% % % % plot_scale([1,1],Sin.Xvalue.*xmax,1,'w','\mum','h');
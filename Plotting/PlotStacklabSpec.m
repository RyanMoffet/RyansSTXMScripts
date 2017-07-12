function PlotStacklabSpec(varargin)


nofSpec=length(varargin);
colorTable=zeros(nofSpec+1,3);
colorTable(2:nofSpec+1,:)=jet(nofSpec);
emax=max(varargin{1}(:,1));

j=0;

figure,
for k=1:nofSpec
%     for cnt=1:emax
%         buffer=V(:,:,cnt);
%         varargin{k}(:,2)(cnt,1)=mean(mean(buffer(pcaMap==k)));
%         clear buffer
%     end
    plot(varargin{k}(:,1),varargin{k}(:,2)+j,'Color',colorTable(k+1,:),'LineWidth',1.5)
    xlim([varargin{k}(1,1) varargin{k}(end,1)])
    ylim([(min(varargin{k}(:,2))-0.05*max(varargin{k}(:,2))) (max(varargin{k}(:,2))+0.05*max(varargin{k}(:,2)))])
    j=j+max(varargin{k}(:,2));
%     clear varargin{k}(:,2)
    hold on
end
set(gca,'YTickLabel',{},'YTick',zeros(1,0),'PlotBoxAspectRatio',[1/j,1,1])
xlim([280,varargin{k}(end,1)]);
ylim([0,j+.1]);
vline([285.1,287.7,288.3,288.7,289.5,290.4,291.5,349.2,352.5],'k:')

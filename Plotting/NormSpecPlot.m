function NormSpecPlot(inspec,varargin);
% inspec={avgspec{11},avgspec{14}};
normenergy=310;
normidx=find(inspec{1}(:,1)>309 & inspec{1}(:,1)<311);
% normidx=find(inspec(:,1)>309 & inspec(:,1)<311);
colorvec={'r-','g-','b-','c-','m-','y-','k-'};
figure,
for i=1:length(inspec)
    normidx=find(inspec{i}(:,1)>319 & inspec{i}(:,1)<321);
    pltspec=inspec{i};
    pltspec(:,2)=(pltspec(:,2)-mean(pltspec(1:4,2)));
    pltspec(:,2)=pltspec(:,2)./pltspec(normidx(1),2)
    plot(pltspec(:,1),pltspec(:,2),colorvec{i}),hold on
end
legend(varargin{1})
set(gca,'XLim',[278,320]);
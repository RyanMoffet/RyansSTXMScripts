function NormSpecPlotNoCell(inspec);
% inspec={avgspec{11},avgspec{14}};
normenergy=310;
% normidx=find(inspec{1}(:,1)>309 & inspec{1}(:,1)<311);
normidx=find(inspec(:,1)>309 & inspec(:,1)<311);

colorvec={'r-','g-','b-','c-','m-','y-','k-'};
figure,
    pltspec=inspec;
    pltspec(:,2)=(pltspec(:,2)-mean(pltspec(1:4,2)));
    pltspec(:,2)=pltspec(:,2)./pltspec(normidx(1),2)
    plot(pltspec(:,1),pltspec(:,2),colorvec{3}),hold on
    


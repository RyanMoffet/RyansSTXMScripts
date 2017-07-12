function RadScanSite(RadScans,sitestr,Nclass)

classstr={'OC','ECOCIn','ECOC','InOC','NoID'};
bins=0:.1:1;
for i=1:length(RadScans) %% loop over site
    figure,
    for j=1:length(RadScans{i}(1,:)) %% loop over class
        subplot(2,3,j)
        Scan=(RadScans{i}(:,j)-min(RadScans{i}(:,j)))...
            ./max((RadScans{i}(:,j)-min(RadScans{i}(:,j))));
        if j==length(classstr)
            err=Scan.*0;
        else
            err=Scan.*(sqrt(Nclass(j,i))./Nclass(j,i));
        end
        errorbar(bins,Scan,err,'k.-')
        xlabel('relative dist. from center')
        ylabel('COOH (Norm. Abs.)')
        title(sprintf('%s-%s',sitestr{i},classstr{j}));
        
    end
end
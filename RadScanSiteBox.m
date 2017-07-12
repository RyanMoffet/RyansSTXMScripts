function RadScanSiteBox(SingRad,sitestr)

classstr={'OC','ECOCIn','ECOC','InOC','NoID'};
bins=0:.1:1;
colors={'r','b','k','c',[0 0.502 0],'m','r','g','b'};
% colors=jet(length(SingRad));
for i=1:length(SingRad) %% loop over site
    %     figure,
    for j=1:length(SingRad{1})-1 %% loop over class
%         subplot(2,3,j)
        %         for k=1:length(SingRad{i}{j}(1,:)) %% loop over particles in class
        %             Scan=(RadScans{i}{j}(:,k)-min(RadScans{i}{j}(:,k)))...
        %                 ./max((RadScans{i}{j}(:,k)-min(RadScans{i}{j}(:,k))));
        %         end
        if j==1 % to select particle class
            figure,
            labels={'','','','','','','','','','',''};
            boxplot(SingRad{i}{j}','plotstyle','compact',...
                'colors',colors{3},'labels',labels);
%             xlabel('relative dist. from center')
%             ylabel('COOH (Norm. Abs.)')
            title(sprintf('%s-%s',sitestr{i},classstr{j}));
            axis square
            ylim([0,1]);
        end
    end
end
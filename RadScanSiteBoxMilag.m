function RadScanSiteBoxMilag(SingRad,sitestr,LabelCnt)


class=4;
classstr={'OC','ECOCIn','ECOC','InOC','NoID'};
bins=0:.1:1;
colors=prism(length(SingRad));
T0Dat=zeros(11,sum(LabelCnt(class,1:3)));
T1T2Dat=zeros(11,sum(LabelCnt(class,4:end)));
colidx1=0;
colidx2=0;
for i=1:length(SingRad)
    if i<=3
        T0Dat(:,colidx1+1:colidx1+LabelCnt(class,i))=...
        SingRad{i}{class};
        colidx1=colidx1+LabelCnt(class,i);
    else
        T1T2Dat(:,colidx2+1:colidx2+LabelCnt(class,i))=...
        SingRad{i}{class};
        colidx2=colidx2+LabelCnt(class,i);
    end
end
ToMinMat=T0Dat-repmat(min(T0Dat),[size(T0Dat,1),1]);
T0Dat=ToMinMat./repmat(max(ToMinMat),[size(T0Dat,1),1]);

AgedMat=T1T2Dat-repmat(min(T1T2Dat),[size(T1T2Dat,1),1]);
AgedDat=AgedMat./repmat(max(AgedMat),[size(T1T2Dat,1),1]);
labels={'','','','','','','','','','',''};

figure,
boxplot(T0Dat','plotstyle','compact',...
            'colors',[1,1,1],'labels',labels)
figure,
boxplot(AgedDat','plotstyle','compact',...
            'colors',[1,1,1],'labels',labels),
        xlabel('relative dist. from center')
        ylabel('COOH (Norm. Abs.)')
axis square

% for i=1:length(SingRad) %% loop over site
%     figure,
%     for j=1:length(SingRad{1})-1 %% loop over class
%         subplot(2,3,j)
% %         for k=1:length(SingRad{i}{j}(1,:)) %% loop over particles in class
% %             Scan=(RadScans{i}{j}(:,k)-min(RadScans{i}{j}(:,k)))...
% %                 ./max((RadScans{i}{j}(:,k)-min(RadScans{i}{j}(:,k))));
% %         end
%         boxplot(SingRad{i}{j}','plotstyle','compact',...
%             'boxstyle','outline','colors',colors(i,:));
%         xlabel('relative dist. from center')
%         ylabel('COOH (Norm. Abs.)')
%         title(sprintf('%s-%s',sitestr{i},classstr{j}));
%     end
% end
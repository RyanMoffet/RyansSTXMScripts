function TableOut=PeakContribFig(InDat,site)

TableOut=zeros(10,length(site));
figure,
colors={'r.-','g.-','b.-','c.-','m.-','y.-','k.-','ko-','ro-','go-'};
legendstr1={'C*=C','R(C*=O)R/C*OH','C*H_{x}','R(C*=O)OH','OC*H_{2}'};

% RelP=zeros(5,length(site));
% for j=1:length(site)
%     SumP=sum(InDat(1:5,j));
%     RelP(:,j)=InDat(1:5,j)./SumP;
%     clear SumP
% end

cnt=1;
for i=1:5
    plot(1:length(site),InDat(i,:),colors{cnt},'LineWidth',3,'MarkerSize',30),hold on,
    TableOut(cnt,:)=InDat(i,:);
    cnt=cnt+1;
end
xl=xlim;
xlim([xl(1)-0.5,xl(2)+0.5]);
set(gca,'XTick',1:length(site));
set(gca,'XTickLabel',site,'FontSize',12);
ylabel(gca,'Relative Area');
legend(legendstr1,'Location','NorthOutside','Orientation','horizontal');





legendstr2={'C*O3','K','C-\sigma*','C=\sigma*','TotC'}

figure,
plot(1:length(site),InDat(6,:),colors{cnt}),hold on,
TableOut(cnt,:)=InDat(6,:);
cnt=cnt+1;
kdat=sum(InDat(7:8,:));
plot(1:length(site),kdat*20,colors{cnt}),hold on
TableOut(cnt,:)=kdat;
cnt=cnt+1;

for i=[9,10,12]
    if i==(9||10)
        plot(1:length(site),InDat(i,:)*10,colors{cnt}),hold on,
    else
        plot(1:length(site),InDat(i,:),colors{cnt})
    end
    TableOut(cnt,:)=InDat(i,:);
    cnt=cnt+1;
end

legend(legendstr2);


xl=xlim;
xlim([xl(1)-1,xl(2)+1]);
set(gca,'XTick',1:length(site));
set(gca,'XTickLabel',site);

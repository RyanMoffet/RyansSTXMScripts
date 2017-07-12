function RadialScanSpline(Sin,comp)

%% plots radial scans of components comp in STXM stack data structure
%% Sin. Must run ProcDir.m, AlignOD, DiffMaps, PartLabel and DistCent
%% first.
%% COMPONENTS: 
%% comp=1 -- inorganic
%% comp=2 -- potassium
%% comp=3 -- sp2
%% comp=4 -- total carbon
%% comp=5 -- carboxylic acid

%% Compute single particle radial scans.
for i=1:max(max(Sin.LabelMat))
    [xind,yind]=find(Sin.LabelMat==i);
    linidx=sub2ind(size(Sin.LabelMat),xind,yind);
    CmpMap=Sin.DiffMap(:,:,comp)-min(min(Sin.DiffMap(:,:,comp)));
    CmpDist{i}(:,1)=CmpMap(linidx);
    CmpDist{i}(:,2)=Sin.DistToCent(linidx);
    
    figure,plot(CmpDist{i}(:,2),CmpDist{i}(:,1),'k.','MarkerSize',10);
    title(sprintf('Particle # %g',i));
end

% %% Take average radial scan excluding EC particles.
% NormDist=[];
% bins=0:.1:1;
% figure,
% for i=1:length(CmpDist)
%     for j=1:length(Sin.PartLabel{i})
%         if isempty(strfind(Sin.PartLabel{i},'EC'))
%             NormDist=[NormDist;[CmpDist{i}(:,2)./max(CmpDist{i}(:,2)),...
%                 CmpDist{i}(:,1)./max(CmpDist{i}(:,1))]];
%             plot(CmpDist{i}(:,2)./max(CmpDist{i}(:,2))...
%                 ,CmpDist{i}(:,1)./max(CmpDist{i}(:,1)),'k.'),hold on,
%             
%         end
%     end
% end
% for i = 1:length(bins)-1
%     tidx=find(NormDist(:,1)>bins(i) & NormDist(:,1)<bins(i+1));
%     avg(i,:)=[nanmean(NormDist(tidx,1)),nanmean(NormDist(tidx,2))];
% end
% plot(avg(:,1),avg(:,2),'r.-','LineWidth',3,'MarkerSize',18),hold off,
% 
% %% Consider only EC particles & plot radial scans
% NormDistEC=[];
% figure,
% for i=1:length(CmpDist)
%     for j=1:length(Sin.PartLabel{i})
%         if ~isempty(strfind(Sin.PartLabel{i},'EC'))
%             NormDistEC=[NormDistEC;[CmpDist{i}(:,2)./max(CmpDist{i}(:,2)),...
%                 CmpDist{i}(:,1)./max(CmpDist{i}(:,1))]];
%             plot(CmpDist{i}(:,2)./max(CmpDist{i}(:,2))...
%                 ,CmpDist{i}(:,1)./max(CmpDist{i}(:,1)),'k.'),hold on,
%         end
%     end
% end
% for i = 1:length(bins)-1
%     tidx=find(NormDistEC(:,1)>bins(i) & NormDistEC(:,1)<bins(i+1));
%     avgEC(i,:)=[nanmean(NormDistEC(tidx,1)),nanmean(NormDistEC(tidx,2))];
% end
% plot(avgEC(:,1),avgEC(:,2),'r.-','LineWidth',3,'MarkerSize',18),hold off,


function [AvgRadClass,StdRadClass,npart,SingRadScans]=RadialScanSpline(Sin,comp)

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

bins=0:.1:1;
DistSpec=zeros(length(bins),length(Sin.PartLabel));
for i=1:max(max(Sin.LabelMat))
    [xind,yind]=find(Sin.LabelMat==i);
    linidx=sub2ind(size(Sin.LabelMat),xind,yind);
    CmpMap=Sin.DiffMap(:,:,comp)-min(min(Sin.DiffMap(:,:,comp)));
    RawPeak=CmpMap(linidx)./max(max(CmpMap(linidx)));
    RawDist=Sin.DistToCent(linidx)./max(max(Sin.DistToCent(linidx)));
    cnt=1;
    for j=1:length(bins)-1
        tidx=find(RawDist>=bins(j) & RawDist<bins(j+1));
        if ~isempty(tidx) | ~isnan(tidx)
            avg(cnt,:)=[nanmean(RawDist(tidx)),nanmean(RawPeak(tidx))]; % take rolling average
            cnt=cnt+1;
        end
    end
    DistSpec(:,i)=interp1(avg(:,1),avg(:,2),bins,'linear','extrap');  %% interpolate
% % %     DistSpec = ppval(sp,bins);
%     figure,plot(RawDist,RawPeak,'k.','MarkerSize',10),hold on,
%     plot(avg(:,1),avg(:,2),'b.-','LineWidth',3,'MarkerSize',30),hold on,
%     plot(bins,DistSpec(:,i),'r-','LineWidth',3),hold off;
%     title(sprintf('Particle # %g, %s',i,Sin.PartLabel{i}));
%     legend('Raw Data','boxcar average','linear interpolation');
%     xlabel('rel. dist. from center')
%     ylabel('COOH (Norm. Abs.)')

    clear avg
end

%% Now average single particle radial scans by particle type
[class,siz]=ChemSiz(Sin);
classstr={'OC','ECOCIn','ECOC','InOC','NoID'};
AvgRadClass=zeros(length(bins),5);
StdRadClass=zeros(length(bins),5);
npart=zeros(1,5);
SingRadScans=cell(1,5);
for i=1:max(class)
    cidx=find(class==i);
    npart(i)=length(cidx);
    AvgRadClass(:,i)=nanmean(DistSpec(:,cidx),2);
    SingRadScans{i}=DistSpec(:,cidx);
    StdRadClass(:,i)=std(abs(DistSpec(:,cidx)),0,2);
    figure,errorbar(bins,AvgRadClass(:,i),StdRadClass(:,i),'k.-'),
    title(sprintf('Average Radial Scan for %s',classstr{i}));
    xlabel('rel. dist. from center')
    ylabel('COOH (Norm. Abs.)')
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


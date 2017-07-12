function [AvgRadClass,StdRadClass,npart,SingRadScans]=MapRadialScanSpline(Sin,comp)

%% plots radial scans of components comp in STXM stack data structure
%% Sin. Must run CarbonMaps.m first.

%% COMPONENTS:
%% comp=1 -- Total Carbon
%% comp=2 -- Pre/Post ratio
%% comp=3 -- sp2

%% Compute single particle radial scans.
if comp==3
    sp2idx=find(Sin.eVenergy>284.5 & Sin.eVenergy<285.5);
    preidx=find(Sin.eVenergy>277 & Sin.eVenergy<283);
    if length(Sin.eVenergy)>10
        sp2idx=round(mean(sp2idx));
        preidx=preidx(1);
    end
end
bins=0:.1:1; % set relative distance values for radial scans
DistSpec=zeros(length(bins),length(Sin.Size)); % initalize y value matrix for radial scans
for i=1:max(max(Sin.LabelMat))
    [xind,yind]=find(Sin.LabelMat==i); % find index of first particle
    linidx=sub2ind(size(Sin.LabelMat),xind,yind); % change to linear index
    if comp==3
        CmpMap=Sin.spectr(:,:,sp2idx)-Sin.spectr(:,:,preidx);
        CmpMapNois=std(CmpMap(Sin.binmap==0)); % calculate the noise of the sp2 peak by 
        CmpMap(CmpMap<3*CmpMapNois)=0; % removes regions with sp2 less than 3x S/N
    else
        CmpMap=Sin.Maps(:,:,comp)-min(min(Sin.Maps(:,:,comp))); % normalize map values
    end
    RawPeak=CmpMap(linidx)./max(max(CmpMap(linidx))); % normalize single particle map values
    RawDist=Sin.DistToCent(linidx)./max(max(Sin.DistToCent(linidx))); % normailze distance values
    cnt=1;
    for j=1:length(bins)-1 % begin loop over distance value
        tidx=find(RawDist>=bins(j) & RawDist<bins(j+1)); % find pixels within given distance value
        if ~isempty(tidx) | ~isnan(tidx)
            avg(cnt,:)=[nanmean(RawDist(tidx)),nanmean(RawPeak(tidx))]; % take rolling average
            cnt=cnt+1;
        end
    end
    if exist('avg')
        if length(avg)>2
            DistSpec(:,i)=interp1(avg(:,1),avg(:,2),bins,'linear','extrap');  %% interpolate
            clear avg
            
        else
            clear avg
            continue
        end
    else
        continue
    end
    % %     DistSpec = ppval(sp,bins);
%             figure,plot(RawDist,RawPeak,'k.','MarkerSize',10),hold on,
%     %         plot(avg(:,1),avg(:,2),'b.-','LineWidth',3,'MarkerSize',30),hold on,
%             plot(bins,DistSpec(:,i),'r-','LineWidth',3),hold off;
%             title(sprintf('Particle # %g, %s',i,Sin.PartLabel{i}));
%             legend('Raw Data','boxcar average','linear interpolation');
%             xlabel('rel. dist. from center')
%             ylabel('COOH (Norm. Abs.)')
    %     i
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
%     figure,errorbar(bins,AvgRadClass(:,i),StdRadClass(:,i),'k.-'),
%     title(sprintf('Average Radial Scan for %s',classstr{i}));
%     xlabel('rel. dist. from center')
%     ylabel('COOH (Norm. Abs.)')
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


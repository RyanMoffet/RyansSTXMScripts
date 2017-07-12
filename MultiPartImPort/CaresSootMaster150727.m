QcDir{1}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T0_100627\1027_hole2';
QcDir{2}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T0_100627\1227_hole8';
QcDir{3}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T0_100627\1247_hole9';
QcDir{4}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T0_100627\1307_hole10';
QcDir{5}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T0_100627\1647_hole21';
QcDir{6}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T0_100627\1707_hole22';
QcDir{7}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T0_100627\2028_hole32';%% end To 6/27
QcDir{8}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T0_100628\0549_hole60';  
QcDir{9}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T0_100628\0809_hole67';  
QcDir{10}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T0_100628\1309_hole82';  
QcDir{11}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T0_100628\1530_hole89';  
QcDir{12}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T0_100628\2010_hole103';  
QcDir{13}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T0_100628\2211_hole109';  
QcDir{14}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T0_100628\2231_hole110';  
QcDir{15}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T0_100628\2251_hole111';  
QcDir{16}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T0_100628\2323_hole113';  %% end T0 6/28
QcDir{17}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T1_100627\0701_hole 483';
QcDir{18}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T1_100627\1222_hole499';
QcDir{19}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T1_100627\1335_hole3';
QcDir{20}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T1_100627\1355_hole4';
QcDir{21}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T1_100627\1435_hole6';
QcDir{22}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T1_100627\1455_hole7';
QcDir{23}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T1_100627\2336_hole33';
QcDir{24}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T1_100627\2356_hole34'; %% end T1 6/27
QcDir{25}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T1_100628\0016_hole35';
QcDir{26}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T1_100628\0657_hole55';
QcDir{27}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T1_100628\1137_hole69';
QcDir{28}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T1_100628\1418_hole77';
QcDir{29}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T1_100628\1618_hole83';
QcDir{30}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T1_100628\1658_hole85';

mappath='C:\Dropbox\UniversityofthePacific\Research\Projects\CaresSoot\Results\'

for i=1:length(QcDir)
    pos=strfind(QcDir{i},'\');
    sampleID{i}=sprintf('%s', QcDir{i}(pos(end)+1:end));
end


% TestDir=cell(1,3);
% TestDir=QcDir(1:3);
% [DirLabelS]=DirLabelMapsStruct({QcDir{1:3}},{sampleID(1:3)},0,mappath,0.35)
%% Working on updated version of dirlabelmaps -- make output data structure, crop out RGB maps
blab={'T0','T1'};
[DirLabelS]=DirLabelMapsStruct(QcDir,sampleID,0,mappath,0.35)

cd(mappath)
save('151009QC')

%% Combine samples according to site
% TotUnBinCount=sum(DirLabelS.LabelCnt,1);
bidx={[1:16],[17:30]};
% bidx={[1:2],[3]};
for i=1:length(bidx)
%     blab{i}=MapSite{bidx{i}(1)};
    if length(bidx{i})==1
        BMapLabCnt(:,i)=DirLabelS.LabelCnt(:,bidx{i});
        MapCompSizeBin{i}=DirLabelS.CmpSiz{bidx{i}};
        SootDistCent{i}=DirLabelS.SootDistCent{i};
        CroppedParts{i}=DirLabelS.CroppedParts{i};
        ImageProps{i}=DirLabelS.ImageProps{i};
        PartDirs{i}=DirLabelS.PartDirs{i};
        PartSN{i}=DirLabelS.PartSN{i};
    else
        BMapLabCnt(:,i)=sum(DirLabelS.LabelCnt(:,bidx{i}),2);
%         MapCompSizeBin{i}=MapCompSize{bidx{i}(1)};
%         for j=1:length(bidx{i})
%             tcell{j}=TotUnBinCount(bidx{i}(j))./sum(TotUnBinCount(bidx{i})).*OutRad{bidx{i}(j)};
%         end
%         OutRadBin{i}=sum(cat(3,tcell{:}),3);
        MapCompSizeBin{i}=cat(1,DirLabelS.CmpSiz{bidx{i}});
        SootDistCentBin{i}=cat(2,DirLabelS.SootDistCent{bidx{i}});
        CroppedParts{i}=cat(1,DirLabelS.CroppedParts{bidx{i}});
        ImageProps{i}=cat(1,DirLabelS.ImageProps{bidx{i}});
        PartDirs{i}=cat(1,DirLabelS.PartDirs{bidx{i}});
        PartSN{i}=cat(1,DirLabelS.PartSN{bidx{i}});
%         clear tcell
%         for j=1:length(bidx{i})-1
%             MapCompSizeBin{i}=[MapCompSizeBin{i};MapCompSize{bidx{i}(j+1)}]
%         end
    end
end
cd(mappath)
% % save 150716QCTestSet.mat
save '151009QC'
% %% T0 analysis
% tzerosamp=sampleID
% tzeromat=zeros(4,length(tzerosamp));
% % tzeromat(:,1)=MapLabelCnt(:,2)+MapLabelCnt(:,3);
% % tzeromat(:,2)=MapLabelCnt(:,8)+MapLabelCnt(:,9);
% tzeromat=MapLabelCnt;
% tzeromatsum=sum(tzeromat);
% tzeromatsum=sum(tzeromat);
% tzeronorm=zeros(size(tzeromat));
% for i=1:length(tzeromatsum(1,:))
%     tzeronorm(:,i)=tzeromat(:,i)./tzeromatsum(i);
% end
% ChemFrac_OCOverPlotCares(tzeronorm',tzeromatsum,sampleID)
% %% soot analysis
% bidx={[1:25],[25:41]};blab={'T0','T1'};
% 
% clear blab BMapLabCnt MapCompSizeBin BMapLabCntNorm
% TotUnBinCount=sum(MapLabelCnt,1);
% for i=1:length(bidx)
%     blab{i}=MapSite{bidx{i}(1)};
%     if length(bidx{i})==1
%         BMapLabCnt(:,i)=MapLabelCnt(:,bidx{i});
%         MapCompSizeBin{i}=MapCompSize{bidx{i}};
%         OutRadBin{i}=OutRad{bidx{i}};
%         SootDistCent{i}=SootDistCent{i};
%         SootEccBin
%     else
%         BMapLabCnt(:,i)=sum(MapLabelCnt(:,bidx{i}),2);
% %         MapCompSizeBin{i}=MapCompSize{bidx{i}(1)};
%         for j=1:length(bidx{i})
%             tcell{j}=TotUnBinCount(bidx{i}(j))./sum(TotUnBinCount(bidx{i})).*OutRad{bidx{i}(j)};
%         end
%         OutRadBin{i}=sum(cat(3,tcell{:}),3);
%         MapCompSizeBin{i}=cat(1,MapCompSize{bidx{i}});
%         SootDistCentBin{i}=cat(2,SootDistCent{bidx{i}});
%         SootEccBin{i}=cat(1,SootEcc{bidx{i}});
%         SootMajBin{i}=cat(1,SootMaj{bidx{i}});
%         SootMinBin{i}=cat(1,SootMin{bidx{i}});
%         clear tcell
% %         for j=1:length(bidx{i})-1
% %             MapCompSizeBin{i}=[MapCompSizeBin{i};MapCompSize{bidx{i}(j+1)}]
% %         end
%     end
% end
% 
% TotCount=sum(BMapLabCnt,1);
% for i=1:length(bidx)
%     BMapLabCntNorm(:,i)=BMapLabCnt(:,i)./TotCount(i);
% end
% ChemFrac(BMapLabCntNorm',TotCount,blab)
% %% Soot Analysis on binned samples
% %  plot fraction of soot particles as a function of time
% TotalSootBin=sum(BMapLabCnt(2:3,:))./sum(BMapLabCnt);
% figure
% plot(1:1:length(TotalSootBin),TotalSootBin,'.-')
% set(gca,'XTick',1:1:length(TotalSootBin))
% set(gca,'XTickLabel',blab)
% rotateticklabel(gca,45)
% grid on
% 
% %% plot inclusion size/total distributions
% for i = 1:length(blab)
%     CoreSizeDistMaps(MapCompSizeBin{i},blab{i})
% end
% CoreSizeDistMaps(MapCompSizeBin{19},blab{19})
% 
% %% radial scans
% RadScanSite(OutRadBin,blab,BMapLabCnt);
% 
% %% work with soot distances from center SootDistCentBin
% for i=1:length(blab)
%     figure,
%     hist(SootDistCentBin{i})
%     xlabel('Relative Distance of Inclusion from Particle Center')
%     ylabel('Number of Particles')
%     title(blab{i})
% end
% % %         SootEccBin{i}=cat(1,SootEcc{bidx{i}});
% % %         SootMajBin{i}=cat(1,SootMaj{bidx{i}});
% % %         SootMinBin{i}=cat(1,SootMin{bidx{i}});
% for i=1:length(blab)
%     bins=0.5:.25:5;
%     axisratio{i}=SootMajBin{i}./SootMinBin{i};
%     figure
%     [n,x]=hist(axisratio{i},bins);
%     normn=n./max(n);
%     err=normn.*(sqrt(n)./n);
%     errorbar(x,normn,err)
%     xlim([0.5,4.5])
%     xlabel('Major Axis:Minor Axis Ratio')
%     ylabel('Number of Particles');
%     title(blab{i});
% end
% %% plot stacked bars for the DirLabelMaps run
% MapLabelSum=sum(MapLabelCnt);
% MapLabelCntNorm=zeros(4,5);
% for i=1:length(MapLabelSum)
%     MapLabelCntNorm(:,i)=MapLabelCnt(:,i)./MapLabelSum(i);
% end
% ChemFrac(MapLabelCntNorm',MapLabelSum,MapSite)
% %% Plot the number of soot particles in each sample
% TotalSoot=sum(MapLabelCnt(2:3,:))
% figure
% plot(1:1:length(TotalSoot),TotalSoot,'.-')
% set(gca,'XTick',1:1:length(TotalSoot))
% set(gca,'XTickLabel',MapSite)
% rotateticklabel(gca,45)
% grid on
% %%
% for i = 1:length(MapSite)
%     CoreSizeDistMaps(MapCompSize{i},MapSite{i})
% end


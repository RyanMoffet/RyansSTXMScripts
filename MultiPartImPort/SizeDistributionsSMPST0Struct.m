clear all
close all
% smpspath='D:\LBL_Archive\CARES\Peripheral'
% cd(smpspath)
% load('SizeDistWorkspace')
%% Get STXM Size data
mappath='C:\Dropbox\UniversityofthePacific\Research\Projects\CaresSoot\Results'
% mappath='C:\Users\Ryan\Dropbox\UniversityofthePacific\Research\Projects\CaresSoot\Results'
cd(mappath)
load('151009QC.mat')
SNs=PartSN{1}
RGBIms=CroppedParts{1} %% CHANGE THIS VARIABLE FOR T0 (=1) or T1 (=2)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ImageProps=ImageProps{1} %% CHANGE THIS VARIABLE FOR T0 (=1) or T1 (=2)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
AreaEqD=(2*sqrt(MapCompSizeBin{1}./pi)); %% CHANGE THIS VARIABLE FOR T0 (=1) or T1 (=2)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
PartDirs=PartDirs{1}%% CHANGE THIS VARIABLE FOR T0 (=1) or T1 (=2)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
badparts=[1209300610003,1209300610011,1009130910018,1209300600002,1009130290005,1007250590001,1009130480004,1009130500002,1009130580004,...
    1009130720001,1009130740001,1009130840012,1207020150001,1207200450001,1209300910017,1209300910018,1209300910019,1307030870002,1209300600007,...
    1209300610005,1209300600006,1209300640002,1207220300006:1207220300015,1209300590001:1209300590022]'; %% T0 Bad Particles
% % badparts=[1104090810003:1104090810017,1104090810020,1104090770022,1104090530005]; % T1 Bad Parts
[c,ia,ib]=intersect(SNs,badparts)
AreaEqD(ia,3)=0;
AreaEqD(AreaEqD==0)=NaN;
M=[AreaEqD(isfinite(AreaEqD(:,3)),3),AreaEqD(isfinite(AreaEqD(:,3)),4)]; %% grabs the data only for particles with soot inclusions
SootRGBs=RGBIms(isfinite(AreaEqD(:,3))); %% Grab images for soot inclusions
SootImProps=ImageProps(isfinite(AreaEqD(:,3)),:);
SootPartDirs=PartDirs(isfinite(AreaEqD(:,3)),:);
SootSNs=SNs(isfinite(AreaEqD(:,3)),:);
CropPartRGBPlot(SootRGBs,SootImProps,SootPartDirs,SootSNs)






%% T0 SMPS Distribution
datT0=zeros(1,length(SMPSdatT0));
for i=2:length(SMPSdatT0)
datT0(i)=datenum(SMPSdatT0{i});
end
SmpsMicronSiz=T0SMPSDist(1,:)./1000;
figure, semilogx(SmpsMicronSiz,T0SMPSDist(2,:))
xlim([0,1000])
xticklabel={'27-Jun-2010 00:00:00','27-Jun-2010 12:00:00','28-Jun-2010 00:00:00','28-Jun-2010 12:00:00','29-Jun-2010 00:00:00','29-Jun-2010 12:00:00'};
xticknums=datenum(xticklabel);
BuildupRowIdx=find(datT0>datenum('15-Jun-2010 00:00:00') & datT0<datenum('16-Jun-2010 00:00:00'));
figure,
imagesc(datT0(BuildupRowIdx),T0SMPSDist(1,:),(T0SMPSDist(BuildupRowIdx,:)'./0.0157)), colorbar
set(gca,'clim',[0 20000])
set(gca,'Yscale','log','Ydir','normal');
% set(gca,'XTick',xticknums,'XTickLabel',xticklabel)
dynamicDateTicks(gca) 
title('T0 Number Distribution')

AveragT0NumDist=mean(T0SMPSDist(BuildupRowIdx,:),1);
figure,semilogx(T0SMPSDist(1,:),(AveragT0NumDist))
FitSizeIdx=find(T0SMPSDist(1,:)>19);
figure,semilogx(SmpsMicronSiz(FitSizeIdx),(AveragT0NumDist(FitSizeIdx)))

%% Fit SMPS data to lognormal distribution
lognfun=@(b,dp) b(1)*lognpdf(dp,b(2),b(3)); 
dp=logspace(-2,0,200);
y=lognfun([20,-2.5,0.85],dp)
figure, semilogx(dp,y,'k-')
beta = nlinfit(SmpsMicronSiz(FitSizeIdx),(AveragT0NumDist(FitSizeIdx)),lognfun,[20,-2.5,0.85])
figure,semilogx(dp,lognfun(beta,dp),'r-'),hold on,semilogx(SmpsMicronSiz(FitSizeIdx),(AveragT0NumDist(FitSizeIdx)),'k.');


% save('140630QC')
%% distout{i}=CoreSizeDistMaps(MapCompSizeBin{i},blab{i})

bins=logspace(log10(.05),log10(5),30);
dx=diff(bins)
dlogDae=diff(log10(bins));
minpart=3; %minimum particles to consider before plotting the distribution
cj=bins(1:end-1)+dx/2;% bin centers
[Nlin]=histc(AreaEqD(:,4),.05:.01:3)
figure,plot(.05:.01:3,Nlin)
[Ntotj,idx]=histc(AreaEqD(:,4),bins);
figure,semilogx(bins,Ntotj)
Ntotj=Ntotj(1:length(Ntotj)-1); % throw away the last bin, which collect any particles larger than the last bin
dNdD=Ntotj'./dx;
figure,semilogx(cj,dNdD,'.-'),title('Raw STXM Total Size Distribution')
s=dNdD./lognfun(beta,cj)
figure,semilogx(cj,s),title('Scaling Function')
sfun=@(b,dp) 10.^(b(1))*dp.^b(2); 
figure, semilogx(cj,sfun([60000,2,1],cj))
p=polyfit(log10(cj(5:end)),log10(s(5:end)),1)
figure,plot(log10(cj(5:end)),log10(s(5:end)),'k.'),hold on, plot(log10(cj(5:end)),polyval(p,log10(cj(5:end))),'r-')
figure,loglog(cj,s,'k.'),title('Scaling Function'),hold on, loglog(cj,sfun([p(2),p(1)],cj),'r-')
figure,semilogx(cj,(dNdD./sfun([p(2),p(1)],cj))),title('Corrected STXM Size Distribution');
figure,semilogx(cj,(dNdD./sfun([p(2),p(1)],cj)).*cj.^3),title('Corrected STXM Volume Distribution');

M=[AreaEqD(isfinite(AreaEqD(:,3)),3),AreaEqD(isfinite(AreaEqD(:,3)),4)]; %% grabs the data only for particles with soot inclusions
SootRGBs=RGBIms(isfinite(AreaEqD(:,3))); %% Grab images for soot inclusions
SootImProps=ImageProps(isfinite(AreaEqD(:,3)),:);
SootPartDirs=PartDirs(isfinite(AreaEqD(:,3)),:);
CropPartRGBPlot(SootRGBs,SootImProps,SootPartDirs)
[Ntot,idx]=histc(M(:,2),bins);
Ntot=Ntot(1:end-1); %% throw away last bin which collect any particles larger than the last bin
dNtotdD=Ntot'./dx;
figure,semilogx(cj,dNtotdD),title('Raw STXM Size Distribution for Soot Containing Particles')
figure,semilogx(cj,(dNtotdD./sfun([p(2),p(1)],cj))),title('Scaled STXM Number Distribution for Soot Containing Particles')
figure,semilogx(cj,(dNtotdD./sfun([p(2),p(1)],cj)).*cj.^3),title('Scaled STXM Volume Distribution for Soot Containing Particles')
%% Put some errorbars on that shit: Number distributions
ScaledNumberDist=(dNtotdD./sfun([p(2),p(1)],cj));
ScaledNumberAbsError=ScaledNumberDist'.*sqrt(Ntot)./Ntot;
% figure,semilogx(cj,ScaledCounts,'k.-');
figure,h=errorbar(cj,ScaledNumberDist./max(ScaledNumberDist),ScaledNumberAbsError./max(ScaledNumberDist));
set(get(h,'Parent'),'XScale','log');
title('whole particle distribution'),
xlabel('D_{equiv}','FontSize', 16);
ylabel('dN/dlog_{10}D_{AE}','FontSize', 16);
xlim([0.05 7])


%% Correct numbers on cores using SMPS scaling function
% MCS=[M(:,1),sigmoidfun(beta,M(:,2)),M(:,2)]; %[core size,scaling factor for overall particle size]
MCS=[M(:,1),sfun([p(2),p(1)],M(:,2)),M(:,2)];
[Nc,idx2]=histc(MCS,bins);
for i=1:length(bins)
    MeanSc(i)=mean(MCS(idx2(:,1)==i,2));
end
MeanSc(isnan(MeanSc))=1.0;
corrNc=Nc(:,1)./MeanSc';
%% plot core size distribution
% figure,bar(corrNc,bins);
corrNc=corrNc(1:end-1,:); %% throw away last bin as it appears to be a "scalar" bin
Nc=Nc(1:end-1,1); 

corrNc=corrNc./dx';
figure,semilogx(cj,(corrNc.*pi.*(cj'./2).^3*.2),'k.-');
title('Core Mass Distribution'),
xlabel('D_{equiv}','FontSize', 16);
ylabel('dM/dlog_{10}D_{AE}','FontSize', 16);
xlim([0.05 7])

% figure,semilogx(cj,(corrNc)./(dx)','k.-');
figure,
corrNcAbsError=sqrt(Nc)./Nc.*corrNc;
h=errorbar(cj,corrNc./max(corrNc),corrNcAbsError./max(corrNc));
set(get(h,'Parent'),'XScale','log');
title('Core Number Distribution'),
xlabel('D_{equiv}','FontSize', 16);
ylabel('dN/dlog_{10}D_{AE}','FontSize', 16);
xlim([0.05 7])

%% Core to shell ratio plot

figure,
ctosratio=MCS(:,1)./MCS(:,3);
hist(ctosratio);
CropPartRGBPlot(SootRGBs(ctosratio>0.8),SootImProps(ctosratio>0.8,:))
db=0.10;
CtoSBins=[0:db:1];
CtoSCenters=CtoSBins(1:end-1)+db/2;
[CtoS,idx3]=histc(ctosratio,CtoSBins);
CtoSCounts=[CtoS(1:length(CtoS)-2);CtoS(end-1)+CtoS(end)]
for i=1:length(CtoSBins)-1
    if i==length(CtoSBins)-1
        MeanScCtoS(i)=mean(MCS(idx3(:,1)==i|idx3(:,1)==i+1,2));
    else
        MeanScCtoS(i)=mean(MCS(idx3(:,1)==i,2));
    end
end
figure,
scaledCounts=CtoSCounts./MeanScCtoS'
scaledCountErr=scaledCounts.*sqrt(CtoSCounts)./CtoSCounts;
errorbar(CtoSCenters,scaledCounts,scaledCountErr)
xlabel('D_{EC}:D_{tot}')
ylabel('Number of Particles')
title('scaled')
% figure
% bar(CtoSCenters,CtoSCounts)
% xlabel('D_{EC}:D_{tot}')
% ylabel('Number of Particles')
% title('unscaled')
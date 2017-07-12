function DistOut=CoreSizeDistMaps(CompSize,TitleStr)

AreaEqD=(2*sqrt(CompSize./pi));
AreaEqD(AreaEqD==0)=NaN;
% bins=linspace(0.05,2.5,50);
bins=logspace(log10(0.05),log10(2.5),15)
[dn,x]=hist(AreaEqD,bins);
dx=diff(x);
dx=[dx;dx(end)];
for i=1:length(dn(1,:))
    dn(:,i)=dn(:,i)./dx;
end
%% Plot core and total size distributions for soot particles
figure,
% plot(x,n)
semilogx(x,dn,'MarkerSize',25,'Marker','.','LineWidth',3),grid on
legend({'OC','In','EC','Total Particle'})
xlabel('D_{equiv}','FontSize', 16);
ylabel('dN/dlog_{10}D_{AE}','FontSize', 16);
xlim([0 2.5])
% ylim([0 2.5])
%% Plot core and total size distributions for soot particles ONLY
DistOut=zeros(length(x),3);
figure,
SootAED=[AreaEqD(isfinite(AreaEqD(:,3)),3),AreaEqD(isfinite(AreaEqD(:,3)),4)]; %% grabs the data only for particles with soot inclusions
[Sdn,x]=hist(SootAED,bins);
for i=1:length(Sdn(1,:))
    Sdn(:,i)=Sdn(:,i)./dx;
end
figure,
semilogx(x,Sdn,'MarkerSize',25,'Marker','.','LineWidth',3),grid on
legend({'Soot Inclusion','Entire Particle'})
xlabel('D_{AE}','FontSize', 16);
ylabel('dN/dlog_{10}D_{AE}','FontSize', 16);
xlim([0 2.5])
DistOut(:,1)=x;
DistOut(:,2:3)=Sdn;

%% plot circular equivalent volume for each of the samples
CompVol=4/3*pi*(AreaEqD./2).^3;
BinnedCompVol=zeros(length(bins)-1,1);
bincent=zeros(length(bins)-1,1);
for i=1:length(bins)-1
    BinnedCompVolFrac(i)=nansum(CompVol(SootAED(:,2)>bins(i) & SootAED(:,2)<bins(i+1),3))%./...
       % nansum(CompVol(SootAED(:,2)>bins(i) & SootAED(:,2)<bins(i+1),4));
    bincent(i)=mean([bins(i),bins(i+1)]);
end
figure,semilogx(bincent,BinnedCompVolFrac./dx,'k.-')
xlabel('Circular Equivalent Diameter (\mum)')
ylabel('Soot Volume Fraction')

%% Bond plot - the first part calculates lines to map show the different regions
title(TitleStr)
maxy=max(AreaEqD(~isnan(AreaEqD(:,4)),4));
maxy=maxy+0.15*maxy;
OneOne=[linspace(0,maxy)];
RegOne=(500/275).*OneOne;
reg2y=zeros(1,100);
reg2y(reg2y==0)=0.500;
reg2x=linspace(0,0.175);
reg3x=zeros(1,100);
reg3x(reg3x==0)=0.175;
reg3y=linspace(0.32,maxy);
reg4x=zeros(1,100);
reg4x(reg4x==0)=0.06;
reg4y=linspace(0.500,maxy);

figure,
plot(AreaEqD(:,3),AreaEqD(:,4),'k.'),hold on,
plot(OneOne,OneOne,'r-'),hold on,
plot(OneOne,RegOne,'r-'),hold on,
plot(reg2x,reg2y,'r-'),hold on,
plot(reg3x,reg3y,'r-'),hold on,
plot(reg4x,reg4y,'r-'),hold off,

xlabel('EC Core Diameter (\mum)')
ylabel('Shell Diameter (\mum)')
xlim([0 1])
ylim([0 2.5])
title(TitleStr)

figure,
ctosratio=AreaEqD(:,3)./AreaEqD(:,4);
hist(ctosratio);
xlabel('D_{EC}:D_{tot}')
ylabel('Number of Particles')
title(TitleStr)

%% Plot soot volume fraction

SootVolFrac=SootAED(:,1).^3./SootAED(:,2).^3;
% figure,
% plot(SootAED(:,2),SootVolFrac,'k.')
BinnedAvVolFrac=zeros(length(bins)-1,1);
bincent=zeros(length(bins)-1,1);
for i=1:length(bins)-1
    BinnedAvVolFrac(i)=mean(SootVolFrac(SootAED(:,2)>bins(i) & SootAED(:,2)<bins(i+1),1));
    bincent(i)=mean([bins(i),bins(i+1)]);
end
figure,semilogx(bincent,BinnedAvVolFrac,'k.-')
xlabel('Circular Equivalent Diameter (\mum)')
ylabel('Soot Volume Fraction')


[Vfrac,xnew]=hist(SootAED,bins);


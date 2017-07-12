function CoreSizeDist(CompSize)

figure,
AreaEqD=(2*sqrt(CompSize./pi));
AreaEqD(AreaEqD==0)=NaN;
[n,x]=hist(AreaEqD);


figure,
plot(x,n)
legend({'OC','In','K','EC','Total Particle'})
xlabel('D_{equiv}','FontSize', 16);
ylabel('Particle Count','FontSize', 16);

maxy=max(AreaEqD(~isnan(AreaEqD(:,4)),5));
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
plot(AreaEqD(:,4),AreaEqD(:,5),'k.'),hold on,
plot(OneOne,OneOne,'r-'),hold on,
plot(OneOne,RegOne,'r-'),hold on,
plot(reg2x,reg2y,'r-'),hold on,
plot(reg3x,reg3y,'r-'),hold on,
plot(reg4x,reg4y,'r-'),hold off,

xlabel('EC Core Diameter (\mum)')
ylabel('Shell Diameter (\mum)')
xlim([0 (maxy-0.2*maxy)])
ylim([0 maxy])

figure,
ctosratio=AreaEqD(:,4)./AreaEqD(:,5);
hist(ctosratio);

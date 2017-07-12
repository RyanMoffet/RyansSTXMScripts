% % FeCalCurve

fe2ref_raw=load('C:\RyanM_LBL\Matlab\STXMNew\basefreeFe2.txt');
fe3ref_raw=load('C:\RyanM_LBL\Matlab\STXMNew\basefreeFe3.txt');

TotFeIdx2=find(fe2ref_raw>779.5 & fe2ref_raw<780.7)
TotFeIdx3=find(fe3ref_raw>779.5 & fe3ref_raw<780.7)

fe2ref_raw(:,2)=fe2ref_raw(:,2)./fe2ref_raw(TotFeIdx2,2);
fe3ref_raw(:,2)=fe3ref_raw(:,2)./fe3ref_raw(TotFeIdx3,2);

specfig=figure
axes('Parent',specfig,'FontSize',14);
plot(fe2ref_raw(:,1),fe2ref_raw(:,2),'LineWidth',3),hold on,
plot(fe3ref_raw(:,1),fe3ref_raw(:,2),'r-','LineWidth',3),
set(gca,'YTickLabel',{},'YTick',zeros(1,0))
xlim([695,730])
ylim([0,10])
xlabel('Energy (eV)')
ylabel('Normalized Absorption')
% Create legend
legend({'FeCl_{2}','FeCl_{3}'});
% Create textarrow
annotation(specfig,'textarrow',[0.5625 0.4661],[0.6847 0.8881],...
    'TextEdgeColor','none',...
    'FontSize',14,...
    'FontName','Arial',...
    'String',{'H(709.5 eV)'});
% Create textarrow
annotation(specfig,'textarrow',[0.3232 0.4107],[0.6919 0.7786],...
    'TextEdgeColor','none',...
    'FontSize',14,...
    'FontName','Arial',...
    'String',{'H(707.8 eV)'});


% figure,plot(fe2ref_raw(:,1),fe2ref_raw(:,2)),hold on,
% plot(fe3ref_raw(:,1),fe3ref_raw(:,2),'r-'),
% xlim([705,715])

a=8.285;
c=3.89;
b=4.684;
d=9.579;

xe=[a:-(a-b)/100:b];
ye=[c:(d-c)/100:d];
re=xe./ye;
TobiAlpha=(b-d.*re)./(re.*c-d.*re-a+b);
r2=a/c;
r3=b/d;
arbAlpha=0:.01:1;
re=r2.*arbAlpha+(1-arbAlpha).*r3;
RyAlpha=(re-r3)./(r2-r3)

% figure,plot(RyAlpha,re)
      %%fe(II)                                                    %%fe(III)
% vany=[24.7,23.8,21.5,21.1,18.0,19.2,20.1,19.45,22.4,25.26,15.9,16.14,19.2,20.3]; %% 
% vanx=[8.56,10.1,10.8,13.2,17.5,21.9,24.1,27,32.1,39.3,47.24,58.83,71.2,84.9]; %% 
vany=[100,100,100,100,100,84,86,67,59,51,29,28,26,23]; %% 
vanx=[33,41,51,61,95,100,100,100,100,100,100,100,100,100]; %% 


vanR=vanx./vany;
vana=100;
vanb=33;
vanc=23;
vand=100;
vanxc=[vana:-(vana-vanb)/100:vanb];
vanyc=[vanc:(vand-vanc)/100:vand];
vanrc=vanxc./vanyc;
vanOx=1-[1,.905,.787,.704,.514,.461,.428,.375,.345,.215,.123,.091,.045,.03];
vanAlpha=(vanb-vand.*vanrc)./(vanrc.*vanc-vand.*vanrc-vana+vanb);

bux=[47,100];
buy=[100,28];    
bua=100;
bub=47;
buc=28;
bud=100;
bur=bux./buy;
burp=[bur(1):(bur(2)-bur(1))/100:bur(2)];
bualpha=(bub-bud.*burp)./(burp.*buc-bud.*burp-bua+bub);

fe3a=[.5,.34,.57]./[.799,.55,.88]
s=std(fe3a)
majesticx=[0,.1,.3,.5,.7,.9,1];
majesticy=[.36,.4,.58,.9,1.5,2.27,2.7];
mr=majesticx./majesticy;
p=polyfit(majesticx,majesticy,2)
f=polyval(p,[0:0.01:1]);
% figure,plot(majesticx,majesticy,'o',[0:0.01:1],f,'-')
TobiAlpha=(b-d.*re)./(b-a+c.*re-d.*re);
figure1=figure
axes('Parent',figure1,'FontSize',14);
plot(TobiAlpha,re,'g-','LineWidth',3),hold on,
plot(vanOx,vanR,'r.','MarkerSize',25),hold on,
plot(vanAlpha,vanrc,'r-','LineWidth',3),hold on;
plot(bualpha,burp,'b-','LineWidth',3),hold on;
% plot(bux,buy,'b.','MarkerSize',25),hold on,
plot(majesticx,majesticy,'k.','MarkerSize',25),hold on,
plot([0:0.01:1],f,'k-','LineWidth',3)
errorbar(0,mean(fe3a),3*s,3*s,'ko','MarkerSize',5)
xlim([-.1,1.1])
ylabel('Peak Height Ratio, r','FontSize',18)
xlabel('Fe(II) Fraction ({\bf\alpha})','FontSize',18);
legend({'Eq 1 - Fe Chlorides','Van Aken','Eq 1 - Van Aken','Eq 1 - Buseck et al','Majestic et al.','Majestic Fit',...
    'Fe_{2}O_{3}'},'FontSize',14,'Location','NorthEast');

re2=0.3:.01:2.7;
majAlpha=(267+sqrt(61000000*re2-22681711))./12200;
TobiAlpha2=(b-d.*re2)./(re2.*c-d.*re2-a+b);
VanAlpha2=(vanb-vand.*re2)./(re2.*vanc-vand.*re2-vana+vanb);
err=(TobiAlpha2-majAlpha)./majAlpha*100;
vanerr=(TobiAlpha2-VanAlpha2)./VanAlpha2*100;
majvanerr=(VanAlpha2-majAlpha)./VanAlpha2*100;
figure2=figure;
axes('Parent',figure2,'FontSize',14);
plot(TobiAlpha2,err,'k-','LineWidth',3),hold on
plot(TobiAlpha2,vanerr,'r-','LineWidth',3),hold on,
plot(TobiAlpha2,majvanerr,'g-','LineWidth',3)
xlim([0,1])
ylabel('% error in {\bf\alpha}','FontSize',18)
xlabel('{\bf\alpha}','FontSize',18);
legend({'Iron Chloride - Sulfate','Iron Chloride - Garnet','Garnet - Sulfate'})


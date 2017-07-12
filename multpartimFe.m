function [sumspec,recspeca,alphaout,frachipix]=multpartimFe(InDir)


cd(InDir)
startingdir=dir;
LabelCnt=zeros(4,length(InDir));
figsiz=1;
scrsz=get(0,'ScreenSize');
figure('units','normalized','position',[0,0,figsiz.*scrsz(4)/scrsz(3),figsiz]);


evmax=719;
load('C:\My Dropbox\Ryan_LBL\Matlab\STXMNew\IronrefeV.mat')
IronRefMax=find(IronrefeV<=719);
IronrefeV=IronrefeV(IronRefMax);
sumspec(:,1)=IronrefeV;
sumspec(:,2)=0;
recspeca(:,1)=IronrefeV;
recspeca(:,2)=0;
%% begin loop over sample directories
directory=dir;
subnum=ceil(sqrt(length(directory)-2));
nstack=length(directory)-2;
msize=ceil(sqrt(nstack));

x=zeros(msize,msize);y=x;
ctr=1;
for j=1:length(directory)
    ind=strfind(directory(j).name,'.mat');
    if ~isempty(ind)
        load(directory(j).name)
        x(ctr)=Snew.Xvalue;
        y(ctr)=Snew.Yvalue;
        ctr=ctr+1;
    end
end
maxdim=max([sum(x')+x(:,end)',sum(y)+y(end,:)]);
x=x./maxdim;y=y./maxdim;
xmax=max(x');
ymax=max(y);
rcnt=1;
ccnt=1;
ybot=1-ymax(1);
xpos=0;
xmove=0;
ctr=1;
totalarea=0;
nofPix=0;
hipixRT=0;
for j=1:length(directory)  %%
    ind=strfind(directory(j).name,'.mat');
    if ~isempty(ind)
        load(directory(j).name);
        sprintf(directory(j).name)
        %% Get image parameters (pixel size, etc.)
        MatSiz=size(Snew.spectr(:,:,1));
        XSiz=x(ctr)/MatSiz(1);
        YSiz=y(ctr)/MatSiz(2);
        pixelArea=XSiz*YSiz;
        xdat=[0:XSiz:x(ctr)];
        ydat=[0:YSiz:y(ctr)];
        sprintf('%s',Snew.particle);
        %         subplot(subnum,subnum,l-2),
        %         subimage(xdat,ydat,uint8(Sinp.RGBCompMap))
        %         set(gca, 'XTick', [], 'YTick', [])
        %% Test to see where we are in the figure and set positions
        if ccnt<=msize  %% if the column count <= the sqrt(#stacks)...
            ccnt=ccnt+1;
            xpos=xpos+xmove;
            ypos=ybot+(ymax(rcnt)-y(ctr))./2;
        else
            ccnt=1;
            xpos=0;
            rcnt=rcnt+1;
            ybot=ybot-ymax(rcnt);
            ypos=ybot+(ymax(rcnt)-y(ctr))./2;
            %             xpos=xpos+x(j)./2;
            ccnt=ccnt+1;
        end
        %% setup figure and run Fe speciation function
        
        axes('position',[xpos,ypos,x(ctr),y(ctr)])
        [SingAlpha{ctr},SingAvspec{ctr},SingRecspec{ctr},binmap{ctr},hipix{ctr}]=...
            Fe_Peak2Peak_Map_Trace(Snew,0,1);
        set(gca, 'XTick', [], 'YTick', [])
        nofPix=sum(sum(binmap{ctr}))+nofPix;
        hipixRT=hipix{ctr}+hipixRT;
        FeArea=pixelArea*nofPix;
        totalarea=totalarea+FeArea;
        %         axis('image')
        if isempty(setdiff(Snew.eVenergy,IronrefeV)) ...
                && isempty(setdiff(IronrefeV,Snew.eVenergy))
            sumspec(:,2)=sumspec(:,2)+FeArea*SingAvspec{ctr}(:,2);
            recspeca(:,2)=recspeca(:,2)+FeArea*SingRecspec{ctr}(:,2);
        else
            tempspec=spline(SingAvspec{ctr}(:,1),SingAvspec{ctr}(:,2),IronrefeV);
% %             figure,plot(IronrefeV,tempspec)
% %             close all
            sumspec(:,2)=sumspec(:,2)+FeArea*tempspec(:,1);
            tempspeca=spline(SingRecspec{ctr}(:,1),SingRecspec{ctr}(:,2),IronrefeV);
            recspeca(:,2)=recspeca(:,2)+FeArea*tempspeca(:,1);
        end
        xmove=x(ctr);
        ctr=ctr+1;
    end
end

%% Take grand average spectrum and fit to standard Fe2 and Fe3 spectra
sumspec(:,2)=sumspec(:,2)/totalarea;
recspeca(:,2)=recspeca(:,2)/totalarea;
fe2ref_raw=load('C:\My Dropbox\Ryan_LBL\Matlab\STXMNew\basefreeFe2.txt');
fe3ref_raw=load('C:\My Dropbox\Ryan_LBL\Matlab\STXMNew\basefreeFe3.txt');
TotFeIdx2=find(fe2ref_raw>779.5 & fe2ref_raw<780.7);
TotFeIdx3=find(fe3ref_raw>779.5 & fe3ref_raw<780.7);

fe2ref_raw(:,2)=fe2ref_raw(:,2)./fe2ref_raw(TotFeIdx2,2);
fe3ref_raw(:,2)=fe3ref_raw(:,2)./fe3ref_raw(TotFeIdx3,2);

a=8.285;
c=3.89;
b=4.684;
d=9.579;

fe2ref=spline(fe2ref_raw(:,1),fe2ref_raw(:,2),IronrefeV);
fe3ref=spline(fe3ref_raw(:,1),fe3ref_raw(:,2),IronrefeV);

peak1min=find((IronrefeV>707.7 &  IronrefeV<708.3),1,'first');               %Locate Fe(II) and Fe(III) peak energy ranges
peak1max=find((IronrefeV>707.7 &  IronrefeV<708.3),1,'last');

peak2min=find((IronrefeV>709.6 &  IronrefeV<710.3),1,'first');
peak2max=find((IronrefeV>709.6 &  IronrefeV<710.3),1,'last');

fe2max=max(sumspec(peak1min:peak1max,2));
fe3max=max(sumspec(peak2min:peak2max,2));

r=fe2max/fe3max;

% calculate Fe(II) fraction alpha of particle
ClAlpha=(c-d*r)/(c-a+b*r-d*r);
[alpha,maxalpha,minalpha]=FeFractionMinMax(r); %% using best fit to all studies
alphaout=[alpha,maxalpha,minalpha];
% reconstruct sample data with linear combination of reference spectra
recspec(:,1)=IronrefeV;
recspec(:,2)=ClAlpha*fe2ref+(1-ClAlpha)*fe3ref;
recmax=max(recspec(:,2));
samplemax=max(sumspec(:,2));

scale=samplemax/recmax;


recspec(:,2)=recspec(:,2)*scale;

figure
plot(sumspec(:,1),sumspec(:,2),'LineWidth',2)
hold on
plot(recspec(:,1),recspec(:,2),'--r','LineWidth',2)
hold off
legend('Global sample data average','Reference spectra LC');
title(sprintf('Global average Fe(II) / (Fe(II)+Fe(III)) ratio: %0.2f$\pm$%0.2f',...
    alphaout(1),(alphaout(2)-alphaout(3))/2),'FontSize',14,'FontWeight','bold')
xlim([700,715]),ylim([0,max(sumspec(:,2))+.1.*max(sumspec(:,2))]);

frachipix=hipixRT./nofPix;
nofPix=0;
hipixRT=0;

return



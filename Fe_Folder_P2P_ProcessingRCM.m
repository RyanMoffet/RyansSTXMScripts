% Fe_Folder_P2P_Processing

% sumspec: total average sample data spectrum
% recspec: reference spectra linear combination

function [sumspec,recspec]=Fe_Folder_P2P_Processing(inputdir)

cd (inputdir)
a=dir;

load('C:\RyanM_LBL\Matlab\STXMNew\IronrefeV.mat')

sumspec(:,1)=IronrefeV;
sumspec(:,2)=0;
totalarea=0;

for k=3:size(a,1)
    
    load(a(k).name)
%     [avspec,recspec,binmap]=Fe_Peak2Peak_Map(pcaNoiseFilter(S,8));
    [avspec,recspec,binmap]=Fe_Peak2Peak_Map(Snew);
    [ymax,xmax,eVmax]=size(Snew.spectr);
    pixelArea=Snew.Xvalue*Snew.Yvalue/(xmax*ymax);
    nofPix=sum(sum(binmap));
    
    FeArea=pixelArea*nofPix;
    
    totalarea=totalarea+FeArea;
    
    if isempty(setdiff(Snew.eVenergy,IronrefeV)) && isempty(setdiff(IronrefeV,Snew.eVenergy))

        sumspec(:,2)=sumspec(:,2)+FeArea*avspec(:,2);
        
    else
        tempspec=spline(avspec(:,1),avspec(:,2),IronrefeV);
        sumspec(:,2)=sumspec(:,2)+FeArea*tempspec(:,1);
    end
    close all
end

sumspec(:,2)=sumspec(:,2)/totalarea;

% total Fe(II) fraction for particle, linear combinaion of reference spectra
fe2ref_raw=load('C:\RyanM_LBL\Matlab\STXMNew\basefreeFe2.txt');
fe3ref_raw=load('C:\RyanM_LBL\Matlab\STXMNew\basefreeFe3.txt');

a = 0.0057;                                                  %Fit Parameters
b = 0.0026;
c = 0.0085;
d = 0.0192;

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
alpha=(c-d*r)/(c-a+b*r-d*r);

clear recspec
% reconstruct sample data with linear combination of reference spectra
recspec(:,1)=IronrefeV;
recspec(:,2)=alpha*fe2ref+(1-alpha)*fe3ref;
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
title(sprintf('Global average Fe(II) / (Fe(II)+Fe(III)) ratio: %0.2f',alpha),'FontSize',14,'FontWeight','bold')

totalarea

return

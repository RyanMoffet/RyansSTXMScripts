%% Fe_Peak2Peak_Map
% returns an image of the Fe2 / Fe(II)+Fe(III) ratio

function [avspec,recspec,binmap]=Fe_Peak2Peak_Map(S)

        [ymax,xmax,emax]=size(S.spectr);
        
        peak1min=find((S.eVenergy>707.7 &  S.eVenergy<708.3),1,'first');               %Locate Fe(II) and Fe(III) peak energy ranges
        peak1max=find((S.eVenergy>707.7 &  S.eVenergy<708.3),1,'last');
    
        peak2min=find((S.eVenergy>709.6 &  S.eVenergy<710.3),1,'first');
        peak2max=find((S.eVenergy>709.6 &  S.eVenergy<710.3),1,'last');


        preedgemax=find(S.eVenergy<704,1,'last');
        %L3min=find(S.eVenergy<708.5,1,'last');
        %L3max=find(S.eVenergy<710.5,1,'last');
        
        for y=1:ymax
            for x=1:xmax
                temp=subtractbackground(S.eVenergy,squeeze(S.spectr(y,x,:)));
                S.spectr(y,x,:)=temp(:,2);
            end
        end
                
                
        
        %imagebuffer=mean(S.spectr(:,:,L3min:L3max),3)-mean(S.spectr(:,:,1:preedgemax),3);
        imagebuffer=1/2*(mean(S.spectr(:,:,peak1min:peak1max),3)+mean(S.spectr(:,:,peak2min:peak2max),3))-mean(S.spectr(:,:,1:preedgemax),3);

        imagebuffer(imagebuffer<0)=0;  %Filter negative values
        imagebuffer=medfilt2(imagebuffer);
        
        graybuffer=mat2gray(imagebuffer);

        threshlevel=graythresh(imagebuffer);
        binmap=im2bw(graybuffer,threshlevel);
        
        
        returnimage=zeros(ymax,xmax);
        returnimage2=zeros(ymax,xmax);

        a = 0.0057;                                                  %Fit Parameters
        b = 0.0026;
        c = 0.0085;
        d = 0.0192;
        
        fraction_vector=[];
        avspec(:,1)=S.eVenergy;
        avspec(:,2)=0;
        for y=1:ymax
            
            for x=1:xmax
                
                if binmap(y,x)==1
                    

                    specout(:,1)=S.eVenergy;
                    specout(:,2)=S.spectr(y,x,:);
                    avspec(:,2)=avspec(:,2)+specout(:,2);
                    %specout=subtractbackground(S.eVenergy,spec);
                    
                    fe2max=max(specout(peak1min:peak1max,2));
                    fe3max=max(specout(peak2min:peak2max,2));
                    
                    if(negfilter(fe2max/fe3max)<2.5)
                    
                        returnimage(y,x)=negfilter(fe2max/fe3max);
                    
                    elseif(negfilter(fe2max/fe3max)>=2.5)
                        
                        returnimage(y,x)=2.5;
                        
                    end
                    
                    r=returnimage(y,x);
                    returnimage(y,x)=negfilter((c-d*r)/(c-a+b*r-d*r)); 
                    returnimage2(y,x)=1-returnimage(y,x);
                    fraction_vector(end+1,:)=returnimage(y,x);
                                       
                end
                
            end
            
        end

% total Fe(II) fraction for particle, linear combinaion of reference spectra
fe2ref_raw=load('C:\RyanM_LBL\Matlab\STXMNew\basefreeFe2.txt');
fe3ref_raw=load('C:\RyanM_LBL\Matlab\STXMNew\basefreeFe3.txt');

fe2ref=spline(fe2ref_raw(:,1),fe2ref_raw(:,2),S.eVenergy);
fe3ref=spline(fe3ref_raw(:,1),fe3ref_raw(:,2),S.eVenergy);

avspec(:,2)=avspec(:,2)/sum(sum(binmap));

fe2max=max(avspec(peak1min:peak1max,2));
fe3max=max(avspec(peak2min:peak2max,2));

r=fe2max/fe3max;

% calculate Fe(II) fraction alpha of particle
alpha=(c-d*r)/(c-a+b*r-d*r);

% reconstruct sample data with linear combination of reference spectra
recspec(:,1)=S.eVenergy;
recspec(:,2)=alpha*fe2ref+(1-alpha)*fe3ref;
recmax=max(recspec(:,2));
samplemax=max(avspec(:,2));

scale=samplemax/recmax;

recspec(:,2)=recspec(:,2)*scale;

figure
plot(avspec(:,1),avspec(:,2),'LineWidth',2)
hold on
plot(recspec(:,1),recspec(:,2),'--r','LineWidth',2)
hold off
legend('sample data','Reference spectra LC');
title(sprintf('Average Fe(II) / (Fe(II)+Fe(III)) ratio: %0.2f',alpha),'FontSize',14,'FontWeight','bold')



        
figure
subplot(1,3,1)
imagesc([0, S.Xvalue],[0,S.Yvalue],returnimage)
set(gca,'Clim',[0 1])
xlabel('X-Position (µm)','FontSize',11,'FontWeight','normal')
ylabel('Y-Position (µm)','FontSize',11,'FontWeight','normal')
title(sprintf('Fe(II) / (Fe(II)+Fe(III)) ratio'),'FontSize',14,'FontWeight','bold')
axis image
colorbar

subplot(1,3,2)
imagesc([0, S.Xvalue],[0,S.Yvalue],returnimage2)
set(gca,'Clim',[0 1])
xlabel('X-Position (µm)','FontSize',11,'FontWeight','normal')
ylabel('Y-Position (µm)','FontSize',11,'FontWeight','normal')
title(sprintf('Fe(III) / (Fe(II)+Fe(III)) ratio'),'FontSize',14,'FontWeight','bold')
axis image
colorbar

subplot(1,3,3)
hist(fraction_vector,0.05:0.1:0.95);
xlabel('Relative Fe(II) Fraction','FontSize',11,'FontWeight','normal')
ylabel('Counts','FontSize',11,'FontWeight','normal')
title(sprintf('Rel. Fe(II) fraction Histogram'),'FontSize',14,'FontWeight','bold')
xlim([0 1])
        
return
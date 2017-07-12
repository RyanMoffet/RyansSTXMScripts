%% Fe_Peak2Peak_Map
% returns an image of the Fe2 / Fe(II)+Fe(III) ratio

function [alphaout,avspec,recspec,binmap,varargout]=Fe_Peak2Peak_Map_Trace(S,showplots,maskHiOD)

[ymax,xmax,emax]=size(S.spectr);

peak1min=find((S.eVenergy>707.7 &  S.eVenergy<708.3),1,'first');               %Locate Fe(II) and Fe(III) peak energy ranges
peak1max=find((S.eVenergy>707.7 &  S.eVenergy<708.3),1,'last');

peak2min=find((S.eVenergy>709.6 &  S.eVenergy<710.3),1,'first');
peak2max=find((S.eVenergy>709.6 &  S.eVenergy<710.3),1,'last');

Sold=S;
preedgemax=find(S.eVenergy<704,1,'last');
preedgeidx=find(S.eVenergy<704);
%L3min=find(S.eVenergy<708.5,1,'last');
%L3max=find(S.eVenergy<710.5,1,'last');

%         for y=1:ymax
%             for x=1:xmax
%                 temp=subtractbackground(S.eVenergy,squeeze(S.spectr(y,x,:)));
%                 S.spectr(y,x,:)=temp(:,2);
%             end
%         end
S=SubBack(S,preedgeidx);

% STACKLab(Sold)
%imagebuffer=mean(S.spectr(:,:,L3min:L3max),3)-mean(S.spectr(:,:,1:preedgemax),3);

%% find total particle area
imagebuffer=mean(Sold.spectr,3);
dispim=mat2gray(Sold.spectr(:,:,1));
rmat=dispim;
gmat=dispim;
bmat=dispim;
rgbmat(:,:,1)=rmat;
rgbmat(:,:,2)=gmat;
rgbmat(:,:,3)=bmat;
%         figure,image(rgbmat)
%         figure,imagesc(imagebuffer)
imagebuffer(imagebuffer<0)=0;  %Filter negative values
imagebuffer=medfilt2(imagebuffer);

graybuffer=mat2gray(imagebuffer);
grayim=ind2rgb(graybuffer,'gray');
%         figure,imagesc(graybuffer),colormap gray
GrayImage=imadjust(graybuffer,[0 1],[0 1],.5); %% increase contrast

%         figure,imagesc(GrayImage),colormap gray
threshlevel=graythresh(GrayImage);
binmap=im2bw(GrayImage,threshlevel);
graybuffer=graybuffer.*binmap;
%         figure,imagesc(imagebuffer),hold on,
[B,L] = bwboundaries(binmap);
%         for k = 1:length(B)
%             boundary = B{k};
%             plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
%         end
%         axis image
%% find Fe containing region
imagebuffer2=1/2*(mean(S.spectr(:,:,peak1min:peak1max),3)+mean(S.spectr(:,:,peak2min:peak2max),3))-mean(S.spectr(:,:,1:preedgemax),3);
noise=mean(mean(std(Sold.spectr(:,:,1:preedgemax),0,3)));
imagebuffer2(imagebuffer2<3*noise)=0;  %Filter negative values
imagebuffer2=medfilt2(imagebuffer2);

graybuffer2=mat2gray(imagebuffer2);
%         figure,imagesc(graybuffer2),colormap gray
GrayImage2=imadjust(graybuffer2,[0 1],[0 1],.5); %% increase contrast
%         figure,imagesc(GrayImage2),colormap gray
threshlevel2=graythresh(GrayImage2);
binmap2=im2bw(GrayImage2,threshlevel2);
hiodcnt=0;
%% screen high OD areas
if maskHiOD==1
    binmap2(Sold.spectr(:,:,peak2max)>1.8)=0;
    hiodx=find(Sold.spectr(:,:,peak2max)>1.8);
    varargout{1}=length(hiodx)
end
graybuffer2=graybuffer2.*binmap2;
%         figure,imagesc(binmap2),hold on,



returnimage=zeros(ymax,xmax);
returnimage2=zeros(ymax,xmax);

a=8.285;
c=3.89;
b=4.684;
d=9.579;

fraction_vector=[];
avspec(:,1)=S.eVenergy;
avspec(:,2)=0;
for y=1:ymax
    
    for x=1:xmax
        
        if binmap2(y,x)==1
            
            
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
fe2ref_raw=load('C:\My Dropbox\Ryan_LBL\Matlab\STXMNew\basefreeFe2.txt');
fe3ref_raw=load('C:\My Dropbox\Ryan_LBL\Matlab\STXMNew\basefreeFe3.txt');
TotFeIdx2=find(fe2ref_raw>779.5 & fe2ref_raw<780.7);
TotFeIdx3=find(fe3ref_raw>779.5 & fe3ref_raw<780.7);

fe2ref_raw(:,2)=fe2ref_raw(:,2)./fe2ref_raw(TotFeIdx2,2);
fe3ref_raw(:,2)=fe3ref_raw(:,2)./fe3ref_raw(TotFeIdx3,2);


fe2ref=spline(fe2ref_raw(:,1),fe2ref_raw(:,2),S.eVenergy);
fe3ref=spline(fe3ref_raw(:,1),fe3ref_raw(:,2),S.eVenergy);

avspec(:,2)=avspec(:,2)/sum(sum(binmap2));

fe2max=max(avspec(peak1min:peak1max,2));
fe3max=max(avspec(peak2min:peak2max,2));

r=fe2max/fe3max;

%% calculate Fe(II) fraction alpha of particle
% alpha=(c-d.*r)/(c-a+b.*r-d.*r); %% using only Fe chlorides
[alpha,maxalpha,minalpha]=FeFractionMinMax(r); %% using best fit to all studies
alphaout=[alpha,maxalpha,minalpha];
% alpha=polyval(polyparams,r);
% reconstruct sample data with linear combination of reference spectra
recspec(:,1)=S.eVenergy;
recspec(:,2)=alpha.*fe2ref+(1-alpha).*fe3ref;
recmax=max(recspec(:,2));
samplemax=max(avspec(:,2));

scale=samplemax/recmax;

recspec(:,2)=recspec(:,2).*scale;
%% Plot figure
% figure
plot(avspec(:,1),avspec(:,2),'LineWidth',2)
hold on
plot(recspec(:,1),recspec(:,2),'--r','LineWidth',2)
hold off
legend('sample data','Reference spectra LC');
title(sprintf('Average Fe(II) / (Fe(II)+Fe(III)) ratio: %0.2f',alpha),'FontSize',14,'FontWeight','bold')



% figure,
for k = 1:length(B)
    boundary = B{k};
    plot(boundary(:,2).*(S.Xvalue./xmax), ...
        boundary(:,1).*(S.Yvalue./ymax), 'w', 'LineWidth', 2)
end

returnimage=returnimage.*binmap;
if showplots==1
    figure
    plot(avspec(:,1),avspec(:,2),'LineWidth',2)
    hold on
    plot(recspec(:,1),recspec(:,2),'--r','LineWidth',2)
    hold off
    legend('sample data','Reference spectra LC');
    title(sprintf('Average Fe(II) / (Fe(II)+Fe(III)) ratio: %0.2f',alpha),'FontSize',14,'FontWeight','bold')
    figure
    
    subplot(1,3,1)
    imagesc(imagebuffer),hold on,
    [B,L] = bwboundaries(binmap);
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
    end
    axis image
    colorbar
    
    subplot(1,3,2)
    imagesc([0, S.Xvalue],[0,S.Yvalue],returnimage),hold on,
    set(gca,'Clim',[0 1])
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2).*(S.Xvalue./xmax), ...
            boundary(:,1).*(S.Yvalue./ymax), 'w', 'LineWidth', 2)
    end
    axis image
    colorbar
    title('Fe(II) Fraction')
    subplot(1,3,3)
    hist(fraction_vector,0.05:0.1:0.95);
    xlabel('Relative Fe(II) Fraction','FontSize',11,'FontWeight','normal')
    ylabel('Counts','FontSize',11,'FontWeight','normal')
    title(sprintf('Rel. Fe(II) fraction Histogram'))
    xlim([0 1])
else
    returnimage=returnimage.*255;
    returnimage=uint8(returnimage);
    ctable=jet(255);    
    for i=1:length(returnimage(:,1))
        for j=1:length(returnimage(1,:))
            if returnimage(i,j)>0
                rmat(i,j)=ctable(returnimage(i,j),1);
                gmat(i,j)=ctable(returnimage(i,j),2);
                bmat(i,j)=ctable(returnimage(i,j),3);
            end
        end
    end
    rgbmat(:,:,1)=rmat;
    rgbmat(:,:,2)=gmat;
    rgbmat(:,:,3)=bmat;
    image([0, S.Xvalue],[0,S.Yvalue],rgbmat),hold on,

    %     imagesc([0, S.Xvalue],[0,S.Yvalue],returnimage),hold on,
    %     set(gca,'Clim',[0 1])
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2).*(S.Xvalue./xmax), ...
            boundary(:,1).*(S.Yvalue./ymax), 'w', 'LineWidth', 2)
    end
end

% subplot(1,3,3)
% hist(fraction_vector,0.05:0.1:0.95);
% xlabel('Relative Fe(II) Fraction','FontSize',11,'FontWeight','normal')
% ylabel('Counts','FontSize',11,'FontWeight','normal')
% title(sprintf('Rel. Fe(II) fraction Histogram'),'FontSize',14,'FontWeight','bold')
% xlim([0 1])

return
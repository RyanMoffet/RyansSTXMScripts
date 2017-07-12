function MapGeneral(Sin,Element,varargin)
if length(varargin)==1
    thresh=varargin{1};
end
energy=Sin.eVenergy;
if strcmp(Element,'C')==1
   ptA=find(energy > 277 & energy < 280);
   ptB=find(energy > 310 & energy < 321);
   elstr={'Carbon'};
end
if strcmp(Element,'O')==1
   ptA=find(energy > 519 & energy < 525);
   ptB=find(energy > 549 & energy < 551);
   elstr={'Sulfur'};
end
if strcmp(Element,'S')==1
   ptA=find(energy > 166.0 & energy < 170.5);
   ptB=find(energy > 172.0 & energy < 174.25);
   elstr={'Sulfur'};
end
if strcmp(Element,'Ca')==1
   ptA=find(energy > 340.8 & energy < 348.0);
   ptB=find(energy > 352.3 & energy < 352.55);
   if isempty(ptB)
       ptB=find(energy > 349.0 & energy < 349.3);
   end
   elstr={'Calcium'};
end
if strcmp(Element,'Cl')==1
   ptA=find(energy > 196 & energy < 200.6);
   ptB=find(energy > 203.8 & energy < 208.0);
   elstr={'Chloride'};
end

MatSiz=size(Sin.spectr);
XSiz=Sin.Xvalue/MatSiz(1);
YSiz=Sin.Yvalue/MatSiz(2);
xdat=[0:XSiz:Sin.Xvalue];
ydat=[0:YSiz:Sin.Yvalue];
[ymax,xmax,emax]=size(Sin.spectr);

map=mean(Sin.spectr(:,:,ptB),3)-mean(Sin.spectr(:,:,ptA),3);
% ptA=round(median(ptA)); ptB=round(median(ptB));
% map=Sin.spectr(:,:,ptB)-Sin.spectr(:,:,ptA);

%% Place find particle boundries
LabelMat=Sin.LabelMat; 
% tmpmask=DiffMap(:,:,1);
% tmpmask(tmpmask>0)=1;
% tmpmask(tmpmask<=0)=0;
binmap=LabelMat;
binmap(binmap>0)=1;
[B,L] = bwboundaries(binmap);
[ymax,xmax,emax]=size(Sin.spectr);

%% Plot figure

map(map<0)=0;
if length(varargin)==1
    thresh=varargin{1};
    map(map>thresh)=thresh;
end

figure,imagesc(xdat,ydat,map), hold on,
for k = 1:length(B)
    boundary = B{k};
    plot(boundary(:,2).*(Sin.Xvalue./xmax), ...
        boundary(:,1).*(Sin.Yvalue./ymax), 'w', 'LineWidth', 2)
end


axis image
% colormap('gray')
title(elstr)
colorbar
xlabel('X (\mum)');
ylabel('Y (\mum)'); 

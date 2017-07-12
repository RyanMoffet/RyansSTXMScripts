function [Sout]=DirLabelOrgVolFrac(Snew)

%% Calculates organic volume fraction
%% Need to run CarbonMaps.m first

%% OUTPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sout.VolFrac is a vector of individual particle volume fractions
%% Sout.ThickMap is a map of inorganic and inorganic thicknesses as well as a volume fraction map

%% To do list:
%% 1. handle thick inorganic regions
%% 2. Incorporate to DirLabelMapsStruct.m (which feeds the ParticleAnalysis2 app)



%% Define varibles from CarbonMaps
Mask=Snew.binmap;
LabelMat=Snew.LabelMat;
%% Find energies
preidx=find(Snew.eVenergy<283)
ccidx=find(Snew.eVenergy>284 & Snew.eVenergy<286)
postidx=length(Snew.eVenergy);
cidx=find(Snew.eVenergy>288 & Snew.eVenergy<289)
if isempty(cidx)
    cidx=postidx;
end

postim=Snew.spectr(:,:,postidx);
preim=Snew.spectr(:,:,preidx);

%%
[uorgpre,uorgpost,uinorgpre,uinorgpost]=PreToPostRatioVolFrac('NaCl','adipic'); %% get calculated cross sections
inorgDens=2.16;
orgDens=1.36;
xin=uinorgpost./uinorgpre;
xorg=uorgpre./uorgpost; % added 1/9/17
% torg=(postim-xin.*preim)./(uorgpost.*orgDens+xin.*uorgpre.*orgDens); %
% old def before 1/9/2017 - note sign difference with the following:
torg=(postim-xin.*preim)./(uorgpost.*orgDens-xin.*uorgpre.*orgDens);
torg(torg<0)=0;
torg=torg./100; % convert to meters
% figure,imagesc(torg),colorbar;
% tinorg=(preim-uorgpre.*((postim-xin.*preim)./(uorgpost+xin.*uorgpre)))./...
%     (uinorgpre.*inorgDens);
tinorg=(preim-xorg.*postim)./(uinorgpre.*inorgDens-xorg.*uorgpost.*inorgDens);% updated due to error 1/9/17

tinorg(tinorg<0)=0;
tinorg=tinorg./100; % convert to meters
% figure,imagesc(tinorg),colorbar;
volFraction=torg./(torg+tinorg);
volFraction(Mask==0)=0;
% figure,imagesc(volFraction),colorbar
MatSiz=size(LabelMat);
XSiz=Snew.Xvalue/MatSiz(1);
YSiz=Snew.Yvalue/MatSiz(2);
xdat=[0:XSiz:Snew.Xvalue];
ydat=[0:YSiz:Snew.Yvalue];
pixelsize=mean([XSiz,YSiz]);
%% Correct for thick inorganic regions assuming thickness is that of a cube
if sum(preim(preim>1.5))>0 % if the particle contains thick regions with OD>1.5
    for i=1:max(max(LabelMat)) % loop over each particle
        npix=length(preim(LabelMat==i & preim>1.5)); % count pixels in ith particle that have OD>1.5
        thickness=sqrt(npix).*pixelsize.*1e-6; % calculate inorganic the thickness based on that of a cube (works for big NaCl inclusions)
        tinorg(LabelMat==i & preim>1.5)=thickness; % for the ith particle, replace OD>1.5 thicknesses with geometric correction
    end
end
%% Integrate volume fractions for individual particles
volFrac=zeros(max(max(LabelMat)),1);
for i=1:max(max(LabelMat)) % loop over particles
    sumOrgThick=sum(torg(LabelMat==i));
    sumInorgThick=sum(tinorg(LabelMat==i));
    volFrac(i)=sumOrgThick./(sumOrgThick+sumInorgThick);
end

% %% Do figures
% figure('Name',Snew.particle,'NumberTitle','off','Position',[1,1,715,869]);
% subplot(2,2,1),imagesc(xdat,ydat,torg),colorbar, 
% axis image, 
% title('organic thickness (m)'), 
% xlabel('X (\mum)');
% ylabel('Y (\mum)'); 
% subplot(2,2,2),imagesc(xdat,ydat,tinorg),colorbar,axis image,
% title('inorganic thickness (m)'), 
% xlabel('X (\mum)');
% ylabel('Y (\mum)');
% subplot(2,2,3),imagesc(xdat,ydat,volFraction),colorbar,
% axis image,
% title('organic volume fraction'),
% xlabel('X (\mum)');
% ylabel('Y (\mum)');
% subplot(2,2,4),hist(volFrac), 
% title('Organic Volume Fraction'),
% xlabel('volume fraction'),
% ylabel('#');
% 
%% prepare outputs
Snew.VolFrac=volFrac;
ThickMap(:,:,1)=torg;
ThickMap(:,:,2)=tinorg;
ThickMap(:,:,3)=volFraction;
Snew.ThickMap=ThickMap;
Snew.VolFrac=volFrac;
Sout=Snew;
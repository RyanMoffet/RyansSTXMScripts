function S=OdExcludeAvSpec(S,odhi)
%% Define variables 
BinaryMap=S.LabelMat;  %% this is a binary matrix having non zero integers where particles are
Spectr=S.spectr;  %% stack data
Energy=S.eVenergy; %% energy values

%% loop to find images with OD>odhi
for i=1:length(Energy)
    junkmat=Spectr(:,:,i); 
    [k,l]=find(junkmat>odhi); %% find pixels with OD>odhi
    loc=sub2ind(size(junkmat),k,l);
    BinaryMap(loc)=0; %% set particle map of high OD pixels to zero
    clear loc junkmat k l
end
BinMap=BinaryMap;
BinMap(BinMap>1)=1; %% set all particle regions to 1

[k,l]=find(BinMap==1);  %% find particle containing regions
loc=sub2ind(size(BinMap),k,l); %% turn into linear index...very important!
for j=1:length(Energy) %% loop over all energy images
    junkmat=Spectr(:,:,j); 
    Partspec(j)=mean(mean(junkmat(loc))); %% take mean of regions containing particles
end
clear k,l;

%% Do the figure
figure,
subplot(2,1,1),imagesc(BinMap),colormap gray,axis image
subplot(2,1,2),plot(Energy,Partspec,'LineWidth',3);
legend(sprintf('OD < %g',odhi),'FontSize',16)
% %% Average Particle Spectra
% junkmat=zeros(size(S.spectr(:,:,1)));
% for i=1:numofps
%     [k,l]=find(BinaryMap==i);
%     loc=sub2ind(size(junkmat),k,l);
%     for j=1:length(Energy)
%         junkmat=Spectr(:,:,j);
%         Partspec(j,i)=mean(mean(junkmat(loc)));
%     end
%     clear k,l;
% end
% 
% % function [particle_spectra,locationMap,numofps,particleComposition,particleSVD,particleArea,label_Mat,particleComposition2] = particle_average(energy,matstruct,Xvalues,Yvalues)
% 
% figure('Name',S.particle,'NumberTitle','off')
% 
% subnum=ceil(sqrt(numofps));
% 
% for c=1:numofps
%     subplot(subnum,subnum,c)
%     plot(S.eVenergy,Partspec(:,c))
%     plottitle=strcat(num2str(c),S.PartLabel{c});
%     title(plottitle);
%     ylim([min(Partspec(:,c)),max(Partspec(:,c))])
%     xlim([min(Energy),max(Energy)])
%     xpos=(max(Energy)-min(Energy))/10;
%     ypos=0.9*max(Partspec(:,c));
% end
% 
% S.PartSpec=Partspec;

return

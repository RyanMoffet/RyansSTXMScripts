function S=PartLabel(S)

%% PartLabel Assigns particle labels to particles
%% based on features in the carbon edge spectrum. Note that DiffMaps.m must
%% be run on S prior to execution of this function.
%% 081201 Ryan C. Moffet

% Thresh=[0.05,0.10,0.20,0.05,.01];   %% Thresholds for Inorg, K, EC, TotC, carbox
particle=S.particle;

ColorVec=[0,170,0;0,255,255;255,170,0;255,0,0]; %% rgb colors of the different components

MatSiz=size(S.DiffMap(:,:,1));
RgbMat=zeros([MatSiz,3]);
RedMat=zeros(MatSiz);
GreMat=zeros(MatSiz);
BluMat=zeros(MatSiz);
cnt=1;

%% This first loop creates masks for the individual components over the
%% entire field of view. Each component is then defined as a colored
%% component for visualization.
for i=[5,1,2,3] %% loop over chemical components
%     if i==1 || i==2
%         BinCompMap{cnt}=ConstThresh(S.DiffMap(:,:,i),0.1); %% Give binary matrix with labels greater than specified threshold
%     else
        GrayImage=mat2gray(S.DiffMap(:,:,i)); %% Turn into a greyscale with vals [0 1]
        GrayImage=imadjust(GrayImage,[0 1],[0 1],0.1); %% increase contrast
        GrayImage=medfilt2(GrayImage);
        Thresh=graythresh(GrayImage); %% Otsu thresholding
        Mask=im2bw(GrayImage,Thresh); %% Give binary image
        BinCompMap{cnt}=bwlabel(Mask,8);
%     end
    [j,k]=find(BinCompMap{cnt}>0); %% find index of >0 components
    if ~isempty(j) || ~isempty(k)  %% this conditional defines a color for the component areas (if it exists)
        linidx=sub2ind(size(BinCompMap{cnt}),j,k); %% change to linear index
        RedMat(linidx)=ColorVec(cnt,1); %% define the color for the ith component
        GreMat(linidx)=ColorVec(cnt,2);
        BluMat(linidx)=ColorVec(cnt,3);
    end
    cnt=cnt+1;
    clear j k linidx GrayImage Thresh Mask;
end

%% This second loop assigns labels over individual particles defined
%% previously in Diffmaps.m

LabelStr={'OC','In','K','EC'};
for i=1:max(max(S.LabelMat))  %% Loop over particles defined in Diffmaps.m
    PartLabel{i}='';
    for j=1:4  %% Loop over chemical components
        [a1,b1]=find(S.LabelMat==i);  %% get particle i
        [a2,b2]=find(BinCompMap{j}>0); %% get component j
        if ~isempty([a1,b1]) && ~isempty([a2,b2])
            linidx1=sub2ind(size(S.LabelMat),find(S.LabelMat==i)); %% Linear index for particle
            linidx2=sub2ind(size(BinCompMap{j}),a2,b2); %% Linear index for component
            IdxCom=intersect(linidx1,linidx2); %% find common indices
            if length(IdxCom)>0.02*length(linidx1) %% if component makes up greater than 2% of the pixels of the particle...
                if j==4 %% if it contains sp2 peak...
                    [sp2out]=PercSp2Region(S,IdxCom);  %% calculate %sp2 using HOPG
                    if sp2out > 0.3 %% if %sp2 is greater than 50%, label as EC
                        PartLabel{i}=strcat(PartLabel{i},LabelStr{j});
                    else %% otherwise label as "sp2"
                        PartLabel{i}=strcat(PartLabel{i},'sp2');
                    end
                else
                    PartLabel{i}=strcat(PartLabel{i},LabelStr{j}); %% give label of component.
                end
            end
        end
    end
    if isempty(PartLabel{i})
        PartLabel{i}='NoID'; %% Particles identified by Otsu's mehod here but not in Particle map script
    end
    clear linidx1 linidx2 IdxCom;
end

S.PartLabel=PartLabel;
S=ParticleSize(S);

RgbMat(:,:,1)=RedMat;
RgbMat(:,:,2)=GreMat;
RgbMat(:,:,3)=BluMat;
% Show DiffMaps
figure('Name',particle,'NumberTitle','off')
subplot(3,2,1)
imagesc(BinCompMap{1})
axis image
title('Carbox')
colorbar

subplot(3,2,2)
imagesc(BinCompMap{2})
axis image
title('Inorg')
colorbar

subplot(3,2,3)
imagesc(BinCompMap{3})
axis image

title('Potassium')
colorbar
subplot(3,2,4)
imagesc(BinCompMap{4})
axis image

title('sp2')
colorbar
subplot(3,2,5)
LabelMat=raw2mask(S);
axis image

title('Particle Map')
colorbar
subplot(3,2,6)
image(uint8(RgbMat))
title('Mixed')
colorbar
axis image

S=MultPartAvSpec(S);

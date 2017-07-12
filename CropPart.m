function Snew=CropPart(Snew,plotfig,type)

%% need to run CarbonMaps.m first!
%% Input-------------------------------------------------------------------
% Snew: the STXM data structure obtained from SingStackProc.m or ProcDir.m AND CarbonMaps.m

%% Output------------------------------------------------------------------
% Snew.ImageProps - matrix containing [XLength,YLength,NXPix,NYPix] and
%   rows corresponding to the number of particles
% Snew.CroppedParts - cell array of cropped rgb images for later plotting
%   by CropRGBPlot.m
%% 2016 RCMoffet

%% Crop Particles ---------------------------------------------------------
% Portions of cropping code below was posted on the matlab forum by  Anton
% Semechko: https://www.mathworks.com/matlabcentral/answers/28158#answer_36447

im=Snew.binmap; % get mask
siz=size(im); % image dimensions
if strcmp('SVD',type)==1 % do SVD image
    ECSum=sum(sum(Snew.RGBCompMap(:,:,1)));
    OCSum=sum(sum(Snew.RGBCompMap(:,:,2)));
    InSum=sum(sum(Snew.RGBCompMap(:,:,3)));
    compvec=[ECSum,OCSum,InSum];
    compvec=compvec>1;
    if sum(compvec)==1 % if there is only one component found, dont do svd and just give mean image
        Timage = uint8(zeros([size(Snew.binmap),3]));
        slice = mean(Snew.spectr,3);
        slice(Snew.binmap==0)=0;
        slice = slice./max(max(slice)).*255;
        Timage(:,:,compvec>0)=uint8(slice);
    elseif sum(compvec)==2 % if two components are found, determine what they are and do SVD
        if compvec(2)>0 && compvec(3)>0 && compvec(1)==0
            [orgspec]=ComponentSpecSVD(Snew,'COOH',0);
            [inorgspec]=ComponentSpecSVD(Snew,'Inorg',0);
            Timage = stackSVD(Snew,{'COOH','Inorg'},orgspec,inorgspec);
        elseif compvec(1)>0 && compvec(2)>0 && compvec(3)==0
            [orgspec]=ComponentSpecSVD(Snew,'COOH',0);
            [ecspec]=ComponentSpecSVD(Snew,'sp2',0);
            Timage = stackSVD(Snew,{'sp2','COOH'},ecspec,orgspec);
        end
    elseif sum(compvec)==3 % do SVD on three components
        [inorgspec]=ComponentSpecSVD(Snew,'Inorg',0);
        [orgspec]=ComponentSpecSVD(Snew,'COOH',0);
        [ecspec]=ComponentSpecSVD(Snew,'sp2',0);
        Timage = stackSVD(Snew,{'sp2','COOH','Inorg'},ecspec,orgspec,inorgspec);
    end
else % or just use RGB comp map from CarbonMaps.m
    Timage=Snew.RGBCompMap;
end
% Label the disconnected foreground regions (using 8 conned neighbourhood)
L=Snew.LabelMat;
% Get the bounding box around each object
bb=regionprops(L,'BoundingBox');
% Crop the individual objects and store them in a cell
n=max(L(:)); % number of objects
RGBIm=cell(n,1);
for i=1:n
    % Get the bb of the i-th object and offest by 2 pixels in all
    % directions
    bb_i=ceil(bb(i).BoundingBox);
    idx_x=[bb_i(1)-2 bb_i(1)+bb_i(3)+2];
    idx_y=[bb_i(2)-2 bb_i(2)+bb_i(4)+2];
    if idx_x(1)<1, idx_x(1)=1; end
    if idx_y(1)<1, idx_y(1)=1; end
    if idx_x(2)>siz(2), idx_x(2)=siz(2); end
    if idx_y(2)>siz(1), idx_y(2)=siz(1); end
    % Crop the object and write to ObjCell
    im=L==i;
    %       RGBIm{i}=im(idx_y(1):idx_y(2),idx_x(1):idx_x(2));
    %     RGBIm{i}=Snew.RGBCompMap(idx_y(1):idx_y(2),idx_x(1):idx_x(2),:);
    RGBIm{i}=Timage(idx_y(1):idx_y(2),idx_x(1):idx_x(2),:);
end

%% Prepare output
ImProps=[Snew.Xvalue,Snew.Yvalue,siz(2),siz(1)];
Xres=Snew.Xvalue./siz(2);Yres=Snew.Yvalue./siz(1);
ImProps=repmat(ImProps,n,1);
for i=1:length(RGBIm)
    SubImSiz=size(RGBIm{i});
    ImProps(i,:)=[SubImSiz(2).*Xres,SubImSiz(1).*Yres,SubImSiz(2),SubImSiz(1)];
end
Snew.ImageProps=ImProps;
Snew.CroppedParts=RGBIm;

%% plot interactive figure if needed
if plotfig==1
    CropPartRGBPlot(Snew.CroppedParts,Snew.ImageProps,Snew.PartDirs,Snew.PartSN);
end
clear im L bb n i bb_i idx_x idx_y siz
function F = loadFunctions()

F = struct('getbad',@getbad,'thresh',@thresh,'getRadius',@getRadius,...
    'findcenter',@findcenter,'calcR',@calcR,'constructS',@constructS,...
    'replaceBad',@replaceBad,'distfun',@distfun,'getLargestLabel',@getLargestLabel,...
    'fullRadius',@fullRadius,'getMaxR',@getMaxR,...
    'equivSphereRadius',@equivSphereRadius,'convexity',@convexity,...
    'elongation',@elongation,'plotImageMetrics',@plotImageMetrics,...
    'getEdges',@getEdges,'inner_outer',@inner_outer,...
    'elongationPlotparams',@elongationPlotparams);

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Smerge = getbad(filenm1,fieldnm1,filenm2,fieldnm2,filenm3,fieldnm3)

L = cell(1,3);
for k = 1:3,
    filenm = eval(strcat('filenm',num2str(k)));
    fieldnm = eval(strcat('fieldnm',num2str(k)));
    try, fid= fopen(filenm,'r');
    catch, fid = -1;
    end
    if fid < 0,
        L{k} = struct('particle','');
        continue;
    end
	S = struct([]);
	for i=1:1000,
        txt = fgetl(fid);
        if isequal(-1,txt), break, end
        C = strsplit(' : ',txt,'omit');
        S(i).particle = C{1};
        S(i).(fieldnm) = cell2mat(mapfun(@str2num,strsplit(',',C{2},'omit')))';
	end
	fclose(fid);
    L{k} = S;
end

allparticles = sort(union(union({L{1}.particle},{L{2}.particle}),{L{3}.particle}));
allparticles = allparticles(~cellfun('isempty',allparticles));
Smerge = struct('particle',allparticles,fieldnm1,[],fieldnm2,[],fieldnm3,[]);
for iPart = 1:length(allparticles),
    for k = 1:length(L),
        fieldnm = eval(strcat('fieldnm',num2str(k)));
        iMatch = strmatch(allparticles{iPart},{L{k}.particle});
        if ~isempty(iMatch), Smerge(iPart).(fieldnm) = L{k}(iMatch).(fieldnm); end
    end
end   

% for i=1:length(Smerge),
%     Smerge(i).particle = regexprep(Smerge(i).particle,'[ ]$','');
% end

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [thres,newBW,aveSpec] = thresh(im,S,method,badPnts)

% Median filter
im(~isfinite(im)) = NaN;
im2 = medfilt2(im);

% Thresholding
if isequal(method,'Otsu')
	% Without using Gaussian Blur
    thres = graythresh(im2);
	BW = im2bw(im2,thres);
elseif isequal(method,'Kmeans'),
    ysub = reshape(im(isfinite(im)),[],1);     
    IDX = kmeans(ysub,2,'Replicates',10);
    thres = max([min(ysub(find(IDX==1))),min(ysub(find(IDX==2)))]);  
    BW = im >= thres;
end
try, BW(badPnts) = 0; end
    

% Labelling
newBW = getLargestLabel(BW);

% Average Spectra
x = reshape(S.spectr,size(S.spectr,1)*size(S.spectr,2),size(S.spectr,3));    
x(~isfinite(x)) = NaN;

for i=1:max(max(newBW))
    aveSpec(i,:) = nanmean(x(find(newBW==i),:));
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [radius,xybar,theta,allxy] = getRadius(S,totalArr,maskArr)

xybar = findcenter(S,totalArr,maskArr);
xmat = repmat(S.XValues,1,length(S.YValues));
ymat = repmat(S.YValues',length(S.XValues),1);
allxy = struct('x',xmat,'y',ymat);

radius = sqrt((xmat(:)-xybar{1}).^2 + (ymat(:)-xybar{2}).^2);
radius = reshape(radius,size(xmat));

DX = xmat(:)-xybar{1};
DY = ymat(:)-xybar{2};
theta = atan(abs(DY)./abs(DX)).*180/pi;
theta = (DX >= 0 & DY >= 0) .* theta + ...
    (DX < 0 & DY >= 0) .* (180-theta) + ...
    (DX < 0 & DY < 0) .* (180+theta) +...
    (DX >= 0 & DY < 0) .* (360-theta);
theta = reshape(theta,size(xmat));
return

%% subfunction
function xybar = findcenter(S,totalArr,maskArr)
TotalMap = totalArr;
TotalMap(~logical(maskArr)) = NaN;
TotalMap(~isfinite(TotalMap)) = NaN;

wx = repmat(S.XValues,1,length(S.YValues)).*TotalMap;
wy = repmat(S.YValues',length(S.XValues),1).*TotalMap;
xbar = nansum(wx(:))/nansum(TotalMap(:));
ybar = nansum(wy(:))/nansum(TotalMap(:));

xybar = {xbar,ybar};
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [maxR, edgeDist] = calcR(radius,theta,n,rm)

if nargin ==4,
    radius(rm) = NaN;
    theta(rm) = NaN;
end

if nargin < 3, n=31; end
nTheta = linspace(0,360,n);
maxR = repmat(NaN,length(nTheta)-1,1);
edgeDist = repmat(NaN,size(theta));
for m=2:length(nTheta),
    sub = find(theta >= nTheta(m-1) & theta < nTheta(m));
    subr = radius(sub);
    if isempty(subr) | all(isnan(subr)), continue, end
    R = nanmax(subr);
    edgeDist(sub) = R - subr;            
    maxR(m-1) = R;        
end
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function S = constructS(directory,particle,bad,threshmethod,refEn)
% function S = constructS(directory,particle,bad,threshmethod)

whichBad = strmatch(particle,{bad.particle});
if isempty(whichBad), badEnergies = [];
else badEnergies = bad(whichBad).Energies;
end
%% Data Import
try, S = read_bypix(directory,particle,badEnergies,0);
catch, return
end

% Set bad Pixels to NaN
if length(whichBad)>0
    if ~isempty(bad(whichBad).totPix),
        S.Total = replaceBad(S.Total,bad(whichBad).totPix);
    end
    if ~isempty(bad(whichBad).partPix),
        for z=1:size(S.spectr,3),
            S.spectr(:,:,z) = replaceBad(S.spectr(:,:,z),bad(whichBad).partPix);    
        end
    end
end
%% Thresholding
minEn = getElem(abs(S.eVenergy-refEn),@min,2);
[S.thresParticle,S.MaskedParticle] = ...
    thresh(S.spectr(:,:,minEn),S,threshmethod,bad(whichBad).partPix);

[S.thres,S.Masked,S.aveSpec] = ...
    thresh(S.Total,S,threshmethod,bad(whichBad).totPix);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function arr = replaceBad(arr,badPts)
% function arr = replaceBad(arr,badPts)

arr(badPts) = NaN;

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [edgemat,xmat,ymat] = distfun(S,M)
% function [edgemat,xmat,ymat] = distfun(S)

xmat = repmat(S.XValues,1,length(S.YValues));
ymat = repmat(S.YValues',length(S.XValues),1);
edgemat = double(S.(M));
for pix = find(S.(M))',
    edgemat(pix) = min(reshape(sqrt((xmat(~S.(M)) - xmat(pix)).^2 + ...
        (ymat(~S.(M)) - ymat(pix)).^2),[],1));
end
edgemat(~S.(M)) = NaN;

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newBW = getLargestLabel(BW)
% function newBW = getLargestLabel(BW)

newBW = bwlabel(BW,8);
% imlabels = unique(newBW(newBW~=0))';
% a = repmat(NaN,1,max(imlabels));
% for i=imlabels,
%     a(i) = length(find(newBW==i));
% end
% newBW(find(newBW ~= getElem(a,@max,2))) = 0;
% newBW = logical(newBW);

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [aveR,r,edgePts] = fullRadius(S,tmpmat,M),
% function [aveR,r] = fullRadius(S),


[edgemat,xmat,ymat] = distfun(S,M);
xybar = findcenter(S,tmpmat,S.(M));
edgePts = getEdges(S,M);
r = sqrt((xmat(edgePts) - xybar{1}).^2 + (ymat(edgePts) - xybar{2}).^2);
aveR = mean(r); % only good for convex shapes

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [a,b] = getMaxR(S,tmpmat,M,n)

if nargin < 3, n=31; end
[edgemat,xmat,ymat] = distfun(S,M);
xybar = findcenter(S,tmpmat,S.(M));
edgePts = getElem({S,M},@fullRadius,3);
DX = xmat(edgePts) - xybar{1};
DY = ymat(edgePts) - xybar{2};
theta = atan(abs(DY)./abs(DX)).*180/pi;
theta = (DX >= 0 & DY >= 0) .* theta + ...
    (DX < 0 & DY >= 0) .* (180-theta) + ...
    (DX < 0 & DY < 0) .* (180+theta) + ...
    (DX >= 0 & DY < 0) .* (360-theta);
thetdiv = linspace(0,360,n);
a = repmat(NaN,n-1,1);
b = repmat(NaN,n-1,1);
for i=2:length(thetdiv),
        j = find(theta(:) >= thetdiv(i-1) & theta(:) < thetdiv(i));
        [a(i-1),c] = max(sqrt(DX(j).^2+DY(j).^2));
        b(i-1) = theta(j(c));
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = equivSphereRadius(S,M),

dx = median(diff(S.XValues));
dy = median(diff(S.YValues));
shapearea = dx*dy*length(find(logical(S.(M)(:))));
r = sqrt(shapearea/pi);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tmpf,huLL] = convexity(arr)
% convexity
% function [convx,tmpf,huLL] = conveXity(arr)

cvh = regionprops(double(arr),{'ConvexImage','ConvexHull','BoundingBox'});

flrceil = {@floor,@ceil};
oldmetric = 1e3; metric = 1e3;
for i = 1:2,
    if metric < 1,
        break
    end    
    for j = 1:2,
        xrg = feval(flrceil{i},cvh.BoundingBox(2)) + (1:cvh.BoundingBox(4));
        yrg = feval(flrceil{j},cvh.BoundingBox(1)) + (1:cvh.BoundingBox(3));
        tmp = zeros(size(arr));
        tmp(xrg,yrg) = cvh.ConvexImage;        
        metric = sum( (tmp(:)-arr(:) < 0) );
        if metric < 1,
            tmpf = tmp;
            break       
        else
            if( metric < oldmetric ),
                tmpf = tmp;
                oldmetric = metric;
            end
        end
    end
end

huLL = cvh.ConvexHull;
%tmpf

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [a,b,th,z] = elongation(arr)
% elongation
% function [a,b,th,z] = eLongation(arr,d)
% d = median(diff([S.XValues;S.YValues]));

th = cell2mat(struct2cell(regionprops(double(arr'),'Orientation')))/180*pi;
c = struct2cell(regionprops(double(arr'),...
    {'MajorAxisLength','MinorAxisLength'}));
[a,b] = deal(c{:}); clear c;

return

function z = elongationPlotparams(a,b,th,d,scale)
	B = [cos(th),-sin(th);sin(th),cos(th)];
	thet = linspace(-pi,pi,100);
	x = (a .* cos(thet)) .* d;
	y = (b .* sin(thet)) .* d;
	z = (inv(B) * [x/max(x)*scale;y/max(x)*scale])';

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotImageMetrics(S,arrnm,convIm,convHull,edgePts,xybar,z,maxr,minr)
% function plotImageMetrics(S,arr,convIm,convHull,edgePts,xybar,z)

xmin = getElem(abs(S.XValues-xybar{1}),@min,2);
ymin = getElem(abs(S.YValues-xybar{2}),@min,2);
d = median([diff(S.XValues);diff(S.YValues)]);
arr = S.(arrnm);

thet = linspace(-pi,pi,100);

colormap(bone)
subplot(1,2,1)
tmp = zeros(size(arr));
tmp(find(convIm - arr > 0)) = 1;
tmp(find(arr > 0)) = 2;
myimagesc(S,tmp)
set(gca,'xlimmode','auto','ylimmode','auto')
line(xybar{1}+z(:,1),xybar{2}+z(:,2),'color','r','linew',1.5)
line((convHull(:,2) - xmin).*d+xybar{1},(convHull(:,1) - ymin).*d + xybar{2},...
    'color','y','linew',1.5)
xrg = get(gca,'xlim');
yrg = get(gca,'ylim');
subplot(1,2,2)
myimagesc(S,arr + edgePts)
x = maxr .* cos(thet);
y = maxr .* sin(thet);
line(x+xybar{1},y+xybar{2},'color','r','linew',1.5);
x = minr .* cos(thet);
y = minr .* sin(thet);
line(x+xybar{1},y+xybar{2},'color','r','linew',1.5);
set(gca,'xlim',xrg,'ylim',yrg);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edgePts = getEdges(S,M),
% function edgePts = getEdges(S,M)

epsilon = 0.005;    
[edgemat,xmat,ymat] = distfun(S,M);
allEdgePts = (edgemat(:) <= sqrt(max(diff(S.XValues))^2 +...
    max(diff(S.YValues))^2)+epsilon);
tmp = logical(S.(M));
tmp(~allEdgePts) = 0;
labeledIm = bwlabel(tmp,8);
edgePts = getLargestLabel(labeledIm);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [maxr,minr] = inner_outer(varargin)

r = getElem(varargin,...
    @fullRadius,2);
maxr = nanmax(r(:));
minr = nanmin(r(:));
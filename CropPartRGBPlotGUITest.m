function CropPartRGBPlotGUITest(DirLabelS,sample)


RGBIn=DirLabelS.CroppedParts{sample};
ImProps=DirLabelS.ImageProps{sample};
PartDirs=DirLabelS.PartDirs{sample};
PartSN=DirLabelS.PartSN{sample};

%% Plots cropped RGB images from carbon maps. When you click on a particle, carbon maps is run and STACKLab is opened.
n=length(RGBIn);
msize=ceil(sqrt(n));
figsiz=1;
scrsz=get(0,'ScreenSize');
figure('units','normalized','position',[0,0,figsiz.*scrsz(4)/scrsz(4),figsiz.*scrsz(3)/scrsz(4)]);
% figure('units','normalized','position',[0,0,1,1]);
set(gcf, 'color', 'k');
% set(gca, 'color', 'k');
%% loop over directories and store x and y dimensions in matrices x and y
x=zeros(msize,msize);y=x; % initialize x and y - the x and y dimensions of each individual image
XSiz=zeros(1,n);YSiz=XSiz;
for i=1:n
    XSiz(i)=ImProps(n,1)./ImProps(n,3); %extract x size from imageprops matrix
    YSiz(i)=ImProps(n,2)./ImProps(n,4);% extract y size from imageprops matrix
    imsiz=size(RGBIn{i}(:,:,1));
    x(i)=imsiz(2).*XSiz(i);% x dimension of image = # pixels*pixel size
    y(i)=imsiz(1).*YSiz(i);% y dimension of image = # pixels*pixel size
end
x=x';y=y';

%% Calculate maximum dimensions of the entire figure, initialize variables
% maxdim=max([max(x,[],2)',max(y)]);
ymax=sum(max(y,[],2));
xmax=max(sum(x,2));
xymax=max([ymax,xmax]);
x=x./xymax;y=y./xymax; %% normalize image dimensions to the dimension of the entire figure.
NormXPixSize=XSiz./xymax; %% calculate pixel size in normalized units
NormYPixSize=YSiz./xymax; %% should be the same as the line above
xmax=max(x);
ymax=max(y,[],2);

rcnt=1;% initialize subplot row counters
ccnt=1;% initialize subplot column counters
ybot=1; % define y coordinate of the bottom of the larger overall figure
xpos=0;
ypos=ybot-ymax(rcnt);
xmove=0;
ctr=1;
emptycnt=0;
xT=x';yT=y';
for i=1:n
    if  isempty(RGBIn{i})
        ctr=ctr+1;
        emptycnt=emptycnt+1
        continue
    end
    ydat=[0:NormYPixSize(ctr):yT(ctr)]; % vector of pixel centers
    xdat=[0:NormYPixSize(ctr):xT(ctr)];
    if ccnt<=msize % if you havent exceed the available row position...
        ccnt=ccnt+1; % step column counter
        xpos=xpos+xmove; % move x position
    else  % if you have exceeded the available row positoin
        ccnt=1; % set column counter to 1
        xpos=0; % move relative x position to zero
        rcnt=rcnt+1; % step row counter
        ypos=ypos-ymax(rcnt);% reposition y coordinate after row is done...
        ccnt=ccnt+1;
    end
    axes('position',[xpos,ypos,xT(ctr),yT(ctr)])
    image(xdat,ydat,uint8(RGBIn{i}),'ButtonDownFcn',{@DispDataFile,[DirLabelS,sample]});% plot image and pass file info into callback fcn
    set(gca, 'XTick', [], 'YTick', [],'visible','off');
    xmove=xT(ctr);
    ctr=ctr+1;
end

function DispDataFile(src,evt,FileInfo)
% Construct a questdlg with two options
choice = questdlg('What would you like to do?', ...
    'Cropped Particle Dataset', ...
    'Explore','Delete Particle','third option');
% Handle response
switch choice
    case 'Explore'
        ActionItem = 1;
    case 'Delete Particle'
        ActionItem = 2;
end
if ActionItem==1
    cd(FileInfo{1});
    load(FileInfo{2});
    Snew=CarbonMaps(Snew);
    STACKLab(Snew);
    sprintf('%d',round(FileInfo{3}))
elseif ActionItem==2
    assignin('base', 'ToDelete', FileInfo{3});
    set(handle, 'UserData', arg1);
end
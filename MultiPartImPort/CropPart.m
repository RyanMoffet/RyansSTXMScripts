function Snew=CropPart(Snew,plotfig)

% Get the image
% im=imread('http://i43.tinypic.com/2w1tlwh.jpg');
% im=rgb2gray(im); % convert to gray scale
im=Snew.binmap;%im>graythresh(im)*255; % covert to binary
siz=size(im); % image dimensions


% Label the disconnected foreground regions (using 8 conned neighbourhood)
L=Snew.LabelMat;
% Get the bounding box around each object
bb=regionprops(L,'BoundingBox');
% Crop the individual objects and store them in a cell
n=max(L(:)); % number of objects
out=cell(n,1);
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
    %       out{i}=im(idx_y(1):idx_y(2),idx_x(1):idx_x(2));
    out{i}=Snew.RGBCompMap(idx_y(1):idx_y(2),idx_x(1):idx_x(2),:);
end

% Visualize the individual objects
XSiz=Snew.Xvalue/siz(2); % x pixel size
YSiz=Snew.Yvalue/siz(1); % y pixel size
ImProps=[Snew.Xvalue,Snew.Yvalue,siz(2),siz(1)];
if plotfig==1
    figsiz=1;
    scrsz=get(0,'ScreenSize');
    figure('units','normalized','position',[0,0,figsiz.*scrsz(4)/scrsz(3),figsiz]);
    set(gcf, 'color', 'k');
    set(gca, 'color', 'k');
        %% loop over directories and store x and y dimensions in matrices x and y
    msize=ceil(sqrt(n));
    x=zeros(msize,msize);y=x; % initialize x and y - the x and y dimensions of the stack
    for i=1:n
        imsiz=size(out{i}(:,:,1));
        x(i)=imsiz(2).*XSiz;% x dimension of image = # pixels*pixel size
        y(i)=imsiz(1).*YSiz;% y dimension of image = # pixels*pixel size
    end
    x=x';y=y';
    
    %% Calculate maximum dimensions of the entire figure, initialize variables
    xmax=max(sum(x,2));
    ymax=sum(max(y,[],2));
    xymax=max([xmax,ymax]); %% find maximum dimension of the figure
    x=x./xymax;y=y./xymax;  %% normalize image dimensions
    NormXPixSize=XSiz./xymax; %% calculate pixel size in normalized units
    NormYPixSize=YSiz./xymax; %% should be the same as the line above
    ymax=max(y,[],2);
    
    %% Initialize counters for plotting figure.
    rcnt=1;% initialize subplot row counters
    ccnt=1;% initialize subplot column counters
    xpos=0; % starting x position
    ypos=1-ymax(1); % starting y position 
    xmove=0; % amount to move x position
    xT=x';yT=y'; %% arrange elements for easy indexing
    %% loop over cropped particles
    for i=1:n
        ydat=[0:NormYPixSize:yT(i)]; % vector of pixel centers
        xdat=[0:NormXPixSize:xT(i)];
        xpixsizecheck=sum(xdat)./length(xdat)
        ypixsizecheck=sum(ydat)./length(ydat)
        if ccnt<=msize % if you havent exceed the available row position...
            ccnt=ccnt+1; % step column counter
            xpos=xpos+xmove; % move x position
        else  % if you have exceeded the available row positoin
            ccnt=1; % set column counter to 1
            xpos=0; % move relative x position to zero
            rcnt=rcnt+1; % step row counter
            ypos=ypos-ymax(rcnt); 
            ccnt=ccnt+1;
        end
        axes('position',[xpos,ypos,xT(i),yT(i)])
        image(xdat,ydat,uint8(out{i}))
        set(gca, 'XTick', [], 'YTick', [])
        xmove=xT(i);
    end
end

Snew.ImageProps=repmat(ImProps,n,1);
Snew.CroppedParts=out;
clear im L bb n i bb_i idx_x idx_y siz
%SliceMovie

function SliceStackMovie(S,Mask)

ydivider=3;
xdivider=3;
eVdivider=2;
[ymax,xmax,eVmax]=size(S.spectr);

%calculate average spectra
cnt=0;
sum_spec=zeros(size(S.eVenergy,1),1);
temp_spec=zeros(size(S.eVenergy,1),1);

for y=1:ymax
    
    for x=1:xmax
        
        if Mask(y,x)==1
            
            cnt=cnt+1;
            temp_spec(:,1)=S.spectr(y,x,:);
            sum_spec(:,1)=sum_spec(:,1)+temp_spec(:,1);
            
        end
        
    end
    
end

return_spec(:,1)=S.eVenergy(:,1);
return_spec(:,2)=sum_spec(:,1)/cnt;

%Find plot limits 
spec_min=min(return_spec(:,2));
spec_max=max(return_spec(:,2));
eV_min=min(return_spec(:,1));
eV_max=max(return_spec(:,1));


%reduce stack resolution
mody=mod(ymax,ydivider);
modx=mod(xmax,xdivider);

V=zeros((ymax-mody)/ydivider,(xmax-modx)/xdivider,eVmax);
V(:,:,:)=S.spectr(1:ydivider:(ymax-mody),1:xdivider:(xmax-modx),:);

%generate slice movie
scrsz = get(0,'ScreenSize');
figure('Position',[100 scrsz(4)/2 1200 500])

sy=[];
sx=[];

for i=1:eVdivider:(length(S.eVenergy)-mod(length(S.eVenergy),eVdivider))
    
    subplot(1,2,1)
    slice(V,sy,sx,[0,i])
    zlim([0,eVmax])
    
    subplot(1,2,2)
    plot(return_spec(:,1),smooth(return_spec(:,2)))
    hold on
    stem(return_spec(i,1),return_spec(i,2)+5,'r')    % remove the "+5" to make the red point follow the data plot line
    xlim([eV_min,eV_max])
    ylim([spec_min-0.1,spec_max+0.1])
    hold off
    F(i)=getframe;
    clear F
  
end

return
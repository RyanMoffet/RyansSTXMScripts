%SliceMovie

function F=SliceStackMovie(S)

Mask=S.LabelMat;
Mask(Mask>0)=1;
ydivider=1;
xdivider=1;
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
% hf=figure('Position',[100 scrsz(4)/2 1200 500])
hf=figure('Position',[100,scrsz(4)/2,1475,725]);
set(gcf,'Color',[1,1,1])

sy=[];
sx=[];
cnt=1;
[xpl,ypl,zpl]=size(V);
ypl=(S.Xvalue./length(1:ypl)).*[1:ypl];
xpl=(S.Yvalue./length(1:xpl)).*[1:xpl];
% sy=[ypl(1),ypl(end)];
% sx=[xpl(1),xpl(end)];
aviobj = avifile('example.avi','FPS',2);
for i=1:eVdivider:length(S.eVenergy)
    subplot1=subplot(1,2,1,'Parent',hf,'FontSize',14)
    [x,y,z] = meshgrid(ypl,xpl,S.eVenergy);
    Sh=slice(x,y,z,V,sy,sx,[eV_min,S.eVenergy(i)]);
    set(gca,'LineWidth',1.5);
    set(Sh, 'LineStyle','none')
    view([-40.5 18]);
    xlabel('X (\mum)','Rotation',25,'FontSize',24,'FontName','Arial');
    ylabel('Y (\mum)','Rotation',-30,'FontSize',24,'FontName','Arial');
    zlabel('Energy (eV)','FontSize',24,'FontName','Arial');
    hold on
    zlim([eV_min,eV_max])
    subplot2=subplot(1,2,2,'Parent',hf,'LineWidth',3,'FontSize',14)
    set(gca,'LineWidth',3);
    plot1=plot(return_spec(:,1),return_spec(:,2),'LineWidth',3)
    set(plot1,'LineWidth',3,'Color',[0 0.498 0]);
    hold on
    %     stem(return_spec(i,1),return_spec(i,2)+5,'r')    % remove the "+5" to make the red point follow the data plot line
    xlim([eV_min,eV_max])
    ylim([spec_min-0.1,spec_max+0.1])
    plot([return_spec(i,1),return_spec(i,1)],[spec_min-0.1,spec_max+0.1],'r-');
    xlabel('Energy (eV)','FontSize',24);
    ylabel('Optical Density','FontSize',24,'FontName','Arial');
    rect = get(hf,'Position');
    rect(1:2) = [0 0];
    F(cnt)=getframe(hf,rect);
    aviobj = addframe(aviobj,F(cnt));
    cnt=cnt+1;
end
% close(hf)
aviobj=close(aviobj);

% hf=figure; 
% rect = get(hf,'Position'); 
% rect(1:2) = [0 0]; 
% 
% 
% % Generate and record the frames 
% for x = 1:5 
%    t = 0:pi/10:x*pi; 
%    subplot(2,1,1) 
%    plot(t,sin(t)) 
%    axis([0 5*pi -1 1]) 
%    subplot(2,1,2) 
%    plot(t,cos(t)) 
%    axis([0 5 -1 1]) 
%    M(:,x) = getframe(hf,rect); 
% end 
% 
% 
% % Play the MATLAB movie 
% clf 
% N = 1; 
% FPS = 10; 
% movie(hf,M,N,FPS,rect) 
return
function FancyStackMovie(S, Mask)


%Calculate average spectrum
[ymax,xmax]=size(Mask);

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

scrsz = get(0,'ScreenSize');
figure('Position',[200 scrsz(4)/2 1000 400])
for i=1:length(S.eVenergy)
    
    subplot(1,2,1)
    imagesc(S.spectr(:,:,i))
    text(1,10,sprintf('E=%6.2f eV',S.eVenergy(i)),...
        'FontSize',18,'BackgroundColor',[1,1,1],'FontWeight','bold')
    colormap(gray)
    axis image
    
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

return;

% movie(F)
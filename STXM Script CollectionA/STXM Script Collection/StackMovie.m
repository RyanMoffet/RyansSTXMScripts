function StackMovie(S)
%function StackMovie(S)
%
%Generates stack movie by successively displaying the single stack 
%absorption images. The sample's average spectrum is extracted by 
%locating the image background using Otsu's method. The average spectrum
%used in this script is the mean of the non-background pixels' absorption 
%spectra. The average stack spectrum is displayed together with an energy 
%position indicating bar in a second subplot figure
%R.C. Moffet, T.R. Henn February 2009
%
%Inputs
%------
%S          aligned and optical density converted raw data stack structure array
%
%Outputs
%-------
%           none

% particle masking & thresholding using Otsu's method
imagebuffer=mean(S.spectr,3);  %% Use average of all images in stack
GrayImage=mat2gray(imagebuffer); %% Turn into a greyscale with vals [0 1]
Thresh=graythresh(GrayImage); %% Otsu thresholding
Mask=im2bw(GrayImage,Thresh); %% Give binary image

%Average particle spectrum calculation
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

% generation of stack movie frames
scrsz = get(0,'ScreenSize');
figure('Position',[200 scrsz(4)/2 1000 400],'MenuBar','none')
for i=1:length(S.eVenergy)
    
    subplot(1,2,1)
    imagesc([0,S.Xvalue],[0,S.Yvalue],S.spectr(:,:,i))
    colormap(gray)
    xlabel('X-Position (µm)','FontSize',11,'FontWeight','bold')
    ylabel('Y-Position (µm)','FontSize',11,'FontWeight','bold')
    axis image
    
    subplot(1,2,2)
    plot(return_spec(:,1),smooth(return_spec(:,2)))
    hold on
    stem(return_spec(i,1),return_spec(i,2)+20000,'r')    % remove the "+20000" to make the red point follow the data plot line
    xlim([eV_min,eV_max])
    ylim([spec_min-0.1,spec_max+0.1])
    hold off
    title('Average stack spectrum','FontSize',11,'FontWeight','bold')
    xlabel('Photon energy (eV)','FontSize',11,'FontWeight','bold')
    ylabel('Absorbance (OD)','FontSize',11,'FontWeight','bold')
    
    %show generated movie frame
    F(i)=getframe;
    clear F
end

return;
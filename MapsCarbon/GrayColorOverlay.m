function GrayColorOverlay(Snew)

%% Run Diffmaps first!
%% set grayscale image to pre edge
figure1=figure('Name',Snew.particle,'NumberTitle','off','Position',[1,1,715,869]);
[ymax,xmax,emax]=size(Snew.spectr);
energy=Snew.eVenergy;
preidx=find(energy > min(energy) & energy < 283);
imagebuffer=mean(Snew.spectr(:,:,preidx),3);
dispim=mat2gray(imagebuffer);
rmat=dispim;
gmat=dispim;
bmat=dispim;
rgbmat(:,:,1)=rmat;
rgbmat(:,:,2)=gmat;
rgbmat(:,:,3)=bmat;

%% Overlay carboxylic diffmap in colorscale
% imagesc(returnimage), colormap gray
returnimage=Snew.DiffMap(:,:,5);
returnimage(returnimage<0.03)=0;
returnimage=returnimage./max(max(returnimage));
returnimage=returnimage.*255;
returnimage=uint8(returnimage);
ctable=jet(255);    
for i=1:length(returnimage(:,1))
    for j=1:length(returnimage(1,:))
        if returnimage(i,j)>0
            rmat(i,j)=ctable(returnimage(i,j),1);
            gmat(i,j)=ctable(returnimage(i,j),2);
            bmat(i,j)=ctable(returnimage(i,j),3);
        end
    end
end
rgbmat(:,:,1)=rmat;
rgbmat(:,:,2)=gmat;
rgbmat(:,:,3)=bmat;
image([0, Snew.Xvalue],[0,Snew.Yvalue],rgbmat),hold on,
axis image
%     imagesc([0, S.Xvalue],[0,S.Yvalue],returnimage),hold on,
%     set(gca,'Clim',[0 1])

% for k = 1:length(B)
%     boundary = B{k};
%     plot(boundary(:,2).*(Snew.Xvalue./xmax), ...
%         boundary(:,1).*(Snew.Yvalue./ymax), 'w', 'LineWidth', 2)
% end

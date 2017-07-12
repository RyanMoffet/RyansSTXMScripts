function PMFWorkup(S,f,g,h,Iz)


%% original stack dimensions
[ymax,xmax,emax]=size(S.spectr);
stack=S.spectr;
% mask=S.LabelMat;
% mask(mask>0)=1;
% for i=1:emax
%     stack(:,:,i)=stack(:,:,i).*mask;
% end
%% reshape eigenimages to original stack structur
fg=f*g;
eImages=zeros(ymax,xmax,h);

ng=zeros(h,xmax*ymax);
for i=1:h
    ng(i,Iz)=g(i,:);
    eImages(:,:,i)=reshape(ng(i,:),ymax,xmax);
end
% for i=1:emax
%     tempspec(:,:,i)=reshape(fg(i,:),ymax,xmax);
% end
%% plot factors
for i=1:h
    figure('Name',sprintf('Factor%g',i))
    subplot(1,2,1),plot(S.eVenergy,f(:,i)),axis square,
    xlim([S.eVenergy(1),S.eVenergy(end)]),
    title(sprintf('Factor %g Spectrum',i))
    subplot(1,2,2),imagesc(eImages(:,:,i)),colormap gray,colorbar,axis image
    title(sprintf('Factor %g Image',i))
end
% if h==3
    rgb(:,:,1)=eImages(:,:,1);rgb(:,:,2)=eImages(:,:,4);rgb(:,:,3)=eImages(:,:,2)+eImages(:,:,3)/4;
    plotSvdRgb(rgb,S)
% end

% TempS=S;
% TempS.spectr=tempspec;
% STACKLab(TempS)

return
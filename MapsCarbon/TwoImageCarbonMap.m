function TwoImageCarbonMap(Sin)

energy=Sin.eVenergy;
stack=Sin.spectr;

preidx=min(find(energy>277 & energy<283));
postidx=max(find(energy>310 & energy<325));
%% Carbon Map
carb=stack(:,:,postidx)-stack(:,:,preidx);
carb1=carb;                  % taking STD of regions not having particles
carb1(carb1<0)=0; % removes regions having negative total carbon

figure,
imagesc([0, Sin.Xvalue],[0,Sin.Yvalue],carb1),colormap gray,colorbar
axis image
title('PostEdge-PreEdge');
xlabel('X (\mum)');
ylabel('Y (\mum)');



function SpecRegionPlot(stack,energy,roi)

[j,k]=find(roi>0);
linidx=sub2ind(size(roi),j,k);

for j=1:length(energy)
    junkmat=stack(:,:,j);
    Partspec(j)=mean(mean(junkmat(linidx)));
end

figure,
plot(energy,Partspec,'LineWidth',3);

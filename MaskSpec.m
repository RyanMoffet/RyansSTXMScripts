function specout=MaskSpec(mask,Snew)

for j=1:length(Snew.eVenergy)
    junkmat=Snew.spectr(:,:,j);
    Partspec(j)=mean(mean(junkmat(mask>0)));
% %     junkmat(mask>0)=0;
% %     junkmat(mask<0)=1;
% %     figure,imagesc(junkmat);
% %     figure,imagesc(mask)
end
figure,plot(Snew.eVenergy,Partspec);
specout=Partspec;
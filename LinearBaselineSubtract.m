function S=LinearBaselineSubtract(S)

stack=S.spectr;
energy=S.eVenergy;
peakregion1=find(energy > min(energy) & energy < 283);  %% Pre edge

da=diff(stack(:,:,peakregion1),1,3);
de=diff(energy(peakregion1));
dade=zeros(size(stack(:,:,peakregion1)));
for i=1:length(de)
    dade(:,:,i)=da(:,:,i)./de(i);
end
avdade=mean(dade,3);
newstack=stack;
dep=diff(energy);
% calculate y intercept of preedge
for i=1:length(peakregion1)
    b(:,:,i)=stack(:,:,i)-avdade.*energy(i);
end
avb=mean(b,3);
% subtract linear preedge obtained above
for i=1:length(energy)
    newstack(:,:,i)=stack(:,:,i)-(avdade.*energy(i)+avb);
end
S.spectr=newstack;
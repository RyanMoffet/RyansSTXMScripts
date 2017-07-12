function S=SubBack(S,bRange)

%% take linear subtraction of background for stack given the range of
%% pre-edge energy points (bRange)


energy=S.eVenergy;
stack=S.spectr;

% calculate slope of preedge 
da=diff(stack(:,:,bRange),1,3);
de=diff(energy(bRange));
dade=zeros(size(stack(:,:,bRange)));
for i=1:length(de)
    dade(:,:,i)=da(:,:,i)./de(i);
end
avdade=mean(dade,3);
newstack=stack;
dep=diff(energy);
% calculate y intercept of preedge
for i=1:length(bRange)
    b(:,:,i)=stack(:,:,i)-avdade.*energy(i);
end
avb=mean(b,3);
% subtract linear preedge obtained above
for i=1:length(energy)
    newstack(:,:,i)=stack(:,:,i)-(avdade.*energy(i)+avb);
end
S.spectr=newstack;

return
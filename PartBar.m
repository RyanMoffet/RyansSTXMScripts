function S=PartBar(S)
NumPart=max(max(S.LabelMat));
workingmat=zeros(size(S.LabelMat));
CompFrac=zeros(NumPart,4);
for i=1:NumPart
    [j,k]=find(S.LabelMat==i);
    idx=sub2ind(size(S.LabelMat),j,k);
    cnt=1;
    for m=[5,1,2,3]
        workingmat=S.DiffMap(:,:,m);
        CompFrac(i,cnt)=mean(workingmat(idx));
        cnt=cnt+1;
    end
end

S.CompFrac=CompFrac;

figure,
h=bar(CompFrac,'stacked');
legend('Carbox','Inorg','Potassium','Sp2')
xlabel('Particle Number')
ylabel('OD/particle')
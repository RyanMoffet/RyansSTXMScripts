function Sout=OdStackOtsu(S)

%% this function takes in the stxm data structure and converts the data to
%% optical density. The result is stored in the "Sout" data structure. 
%% Ryan C. Moffet 090311

stack=S.spectr; %% initalize simple variable names
energy=S.eVenergy;

if length(stack(1,1,:))<length(energy)  %% check dimensions of stack and energy vector
   disp('warning: stack dimensions do not equal expected number of energies defined in .hdr file')
   energy=energy(length(stack(1,1,:)));
   Sout.eVenergy=energy;
end

TotImage=medfilt2(mean(stack,3));  %% Use average of all images in stack
GrayImage=mat2gray(TotImage); %% Turn into a greyscale with vals [0 1]
GrayImage=imadjust(GrayImage,[0 1],[0 1],15); %% increase contrast 
Thresh=graythresh(GrayImage); %% Otsu thresholding
Mask=im2bw(GrayImage,Thresh); %% Give binary image

[j,k]=find(Mask==1);
[l,m]=find(Mask==0);
if ~isempty(j) || ~isempty(k)
    linidx1=sub2ind(size(Mask),j,k);
    linidx2=sub2ind(size(Mask),l,m);
else
    disp('Watch out! Hardly any Io region!!');
end

for i=1:length(energy)
    junkmat=stack(:,:,i);
    Io(i)=mean(mean(junkmat(linidx1)));
    clear junkmat;
end

warning off
for k=1:length(energy)
    S.spectr(:,:,k)=-log(stack(:,:,k)/Io(k));
    S.spectr(S.spectr(:,:,k)==Inf | S.spectr(:,:,k)==-Inf)=0;
    meanio(k)=mean(mean(linidx1));
%     S.spectr(:,:,k)=inffilter(S.spectr(:,:,k));
%     S.spectr(:,:,k)=negfilter(S.spectr(:,:,k));
end
% S.spectr=S.spectr-mean(meanio);
warning on


figure
subplot(2,2,1)
imagesc(TotImage)
colormap(gray)
subplot(2,2,2)
imagesc(GrayImage)
subplot(2,2,3)
imagesc(Mask)
subplot(2,2,4)
plot(energy,Io)

Sout=S;

return
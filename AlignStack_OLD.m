%% AlignStack

function S=AlignStack(stack)

S=stack;
stackcontainer=stack.spectr;

clear S.spectr

[ymax,xmax,emax]=size(stackcontainer);

xresolution=S.Xvalue/xmax;
yresolution=S.Yvalue/ymax;

center=ceil(emax/2);

spectr=zeros(ymax,xmax,emax);

shifts=zeros(emax,4);

for k=1:emax                    %calculate image shifts for each energy  
    
    shifts(k,:)=dftregistration(fft2(stackcontainer(:,:,center)),fft2(stackcontainer(:,:,k)));
    
end

shiftymax=max(abs(shifts(:,3)));
shiftxmax=max(abs(shifts(:,4)));



for k=1:emax                    %The shift process... 
   
    shiftMatrix=zeros(ymax+2*shiftymax,xmax+2*shiftxmax);
    
    shiftMatrix((1+shiftymax+shifts(k,3)):(shiftymax+ymax+shifts(k,3)),(1+shiftxmax+shifts(k,4)):(shiftxmax+xmax+shifts(k,4)))=stackcontainer(:,:,k);
    spectr(:,:,k)=shiftMatrix((1+shiftymax):(shiftymax+ymax),(shiftxmax+1):(shiftxmax+xmax));

    clear shiftMatrix
    
    
end

%Image size reduction

[specymax,specxmax,emax]=size(spectr);

S.spectr=zeros(specymax-abs(min(shifts(:,3)))-abs(max(shifts(:,3))),specxmax-abs(min(shifts(:,4)))-abs(max(shifts(:,4))),emax);

S.spectr(:,:,:)=spectr((1+abs(min(shifts(:,3)))):(specymax-abs(max(shifts(:,3)))),(1+abs(min(shifts(:,4)))):(specxmax-abs(max(shifts(:,4)))),:);

%Calculate new real space image size:

S.Xvalue=xresolution*(size(S.spectr,2));
S.Yvalue=yresolution*(size(S.spectr,1));

return
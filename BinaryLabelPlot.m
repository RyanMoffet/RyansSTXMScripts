function [label_Mat] = BinaryLabelPlot(Image,energy)

% energy=S.eVenergy;
% matstruct=stack;
% Xvalues=S.Xvalue;Yvalues=S.Yvalue;


% post=ceil(length(energy)/4*3);
input_Mat=Image;  %% Image to threshold

input_Mat(~isfinite(input_Mat)) = NaN;                      %Remove Bad Data

filtered_Mat=medfilt2(input_Mat);                       %Median Filter Image 

thres = graythresh(filtered_Mat);                           %Calculate threshold level using Otsu's method
BW = im2bw(filtered_Mat,thres);      %% produce particle binary image                                  

label_Mat=bwlabel(BW,8);%Produce Matrix with particle labels
% imagesc(label_Mat),
for i=1:max(max(label_Mat))
    [k,j]=find(label_Mat==i);
    text(j(1),k(1),num2str(i),'color',[1,1,1],'FontWeight','bold')
    clear i j
end

%% LabelStack

function LabelMatrix=LabelStack(stack)

[ymax,xmax,emax]=size(stack);

postedge=ceil(emax/5*4);                                        %calculate post edge data point numer

inputMatrix=stack(:,:,postedge);

inputMatrix(~isfinite(inputMatrix)) = NaN;                      %Remove Bad Data

filteredMatrix=medfilt2(inputMatrix);                           %Median Filter Image

thres = graythresh(filteredMatrix);                             %Calculate threshold level using Otsu's method

BW = im2bw(filteredMatrix,thres);                               %Produce the binary matrix (1 = itensity above thresh)

LabelMatrix=bwlabel(BW,8);                                      %Produce Matrix with particle labels

return
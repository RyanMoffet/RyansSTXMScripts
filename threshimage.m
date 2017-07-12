function mask=threshimage(mat)

grayim=mat2gray(mat);
thresh=graythresh(grayim);
mask=im2bw(grayim,thresh);
figure,imagesc(mask),colormap gray
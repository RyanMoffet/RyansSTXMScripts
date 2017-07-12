%% inffilter
%filter +-infs from a Matrix

function[M]=inffilter(M)

M(isinf(M))=0;

return
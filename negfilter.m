%% negfilter
%filters negative components from a Matrix

function [M]=negfilter(M)

M(M<0)=0;
            
return
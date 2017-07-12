function y=NexafsPlotFun(xdata,M,gauss,asygauss,edgestep)


ngauss=length(gauss(:,1));
nasygauss=length(asygauss(:,1));
nedgestep=length(edgestep(:,1));
sumfun=ngauss+nasygauss+nedgestep;
y=zeros(sumfun,length(xdata));
asycnt=1;
ioncnt=1;
for i=1:sumfun
    if i<=ngauss
        y(i,:)=[M(i).*gaussian(xdata,gauss(i,1),gauss(i,2))];
    elseif i>ngauss && i<=ngauss+nasygauss
        y(i,:)=[M(i).*AsyGaussian(xdata,asygauss(asycnt))];
        asycnt=asycnt+1;
    elseif i>nasygauss+ngauss
        y(i,:)=[NexafsStep(xdata,edgestep(ioncnt),M(sumfun-1),M(sumfun))];
        ioncnt=ioncnt+1;
    end
end

y(isnan(y) | isinf(y))=0;

return

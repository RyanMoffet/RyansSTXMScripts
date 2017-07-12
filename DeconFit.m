function [fitpars,ci2] = DeconFit(spec,gauss,asygauss,edgestep)

%% INPUT
%% spec is the nexafs spectrum = [energy,OD]
%% gauss is the gaussian function parameters [energy,width]
%% asygauss is the asymmetric gaussian function parameters [energy,width]
%% edgestep is the ionization edge function params [energy,...]

%% OUTPUT
%% fitpars are the fitted parameters
%% ci2 are the 95% confidence intervals

global gauss asygauss edgestep sumfun
    [output,bgC,totC] = normalizeC(spec)
    xdata=output(:,1);
    ydata=output(:,2);
    enidx = find(xdata > 290 & xdata < 291);
    lb = repmat(0,10,1); %% setup all lower bounds
    lb(7:10) = 0;
    ub = [repmat(1e3,1,6),ydata(enidx(1)),1,ydata(enidx(1)),1]';
    sumfun=length(gauss(:,1))+length(asygauss)+length(edgestep);
    x0 = [repmat(0.1,sumfun,1);0.01];
    newx = linspace(xdata(1),xdata(end),500)';
    newy = interp1(xdata,ydata,newx);
    [fitpars,resid,J2,covb,mse] = nlinfit(newx,newy,@Nexfun,x0);
    ci2=nlparci(fitpars,resid,'jacobian',J2);
    colors={'r.-','g.-','b.-','c.-','m.-','y.-','k.-','ko-','ro-','go-'};
    Integral = [trapz(spec(:,1),NexafsPlotFun(xdata,fitpars,gauss,asygauss,edgestep)')]'
    figure,
    plot(xdata(:,1),NexafsPlotFun(xdata,fitpars,gauss,asygauss,edgestep)),hold on, %% this plot the individual components
        legendstr={'C=C','R(C*=O)R/C*OH','CH_{x}','R(C*=O)OH','OC*H_{2}','C*O_{3}',...
    'K L_{2} 2p_{1/2}','K L_{3} 2p_{3/2}','C-\sigma*','C=\sigma*','','TotC'};
    legend(legendstr);
    plot(xdata,sum(NexafsPlotFun(xdata,fitpars,gauss,asygauss,edgestep)),'b-'),hold on,
    plot(xdata,ydata,'k-'),hold off;
    clear global
    sprintf('CRASH!!!!!!!!!!!!!')
return

function fit = Nexfun(M,xdata)

global gauss asygauss edgestep sumfun

ngauss=length(gauss(:,1));
nasygauss=length(asygauss(:,1));
nedgestep=length(edgestep(:,1));
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
fit = sum(y)';
return

function [output,bgC,totC] = normalizeC(A);

try, bgC = integrave(A,[278,283]);
catch, bgC = nanmean(A(find(A(:,1) > 278 & A(:,1) < 283),2));
end    
bgSubtracted = (A(:,2)-bgC);
    
try, totC = integrave(A,[301,305]);
catch, totC = nanmean(A(find(A(:,1) > 301 & A(:,1) < 305),2));
end
output=[A(:,1),bgSubtracted];
return
 
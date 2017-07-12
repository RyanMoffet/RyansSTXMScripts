function F = loadCfunctions()

F = struct('normalizeC',@normalizeC,'Cpeakfits',@Cpeakfits,'Carbonfit',@Carbonfit,...
    'CarbonfitKernel',@CarbonfitKernel,'Cbypix',@Cbypix);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fitpars,ci2] = Cpeakfits(xdata,ydata)
% fitpars = Cpeakfits(xdata,ydata)
%
% lb = repmat(0,11,1); lb(9:10) = 1;
% ub = [repmat(1e3,1,6),3,3,5,8,1e3]';
% x0 = repmat(0.1,11,1);
enidx = find(xdata > 290 & xdata < 291);
lb = repmat(0,10,1); %% setup all lower bounds
lb(7:10) = 0;
ub = [repmat(1e3,1,6),ydata(enidx(1)),1,ydata(enidx(1)),1]';
x0 = [repmat(0.1,14,1);0.01];


%
newx = linspace(xdata(1),xdata(end),500)';
newy = interp1(xdata,ydata,newx);
% [fitpars,RESNORM,Resid,EXITFLAG,OUTPUT,LAMBDA,J1] = lsqcurvefit(@Carbonfit,x0,newx,newy,lb,ub);
[fitpars,resid,J2,covb,mse] = nlinfit(newx,newy,@Carbonfit,x0);
% ci1=nlparci(beta,resid,'covar',covb)
ci2=nlparci(fitpars,resid,'jacobian',J2);
% [ypred1,delta1] = nlpredci(@Carbonfit,newx,beta,resid,'covar',covb)
% [ypred2,delta2] = nlpredci(@Carbonfit,newx,beta,resid,'jacobian',J2)
% [YPRED3, DELTA3] = nlpredci(@Carbonfit,x0,fitpars,Resid,'jacobian',J1) 
return

%%%
function fit = Carbonfit(M,xdata)
% fit = Carbonfit(M,xdata)

y = CarbonfitKernel(M,xdata);
fit = sum(y)';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fit = CarbonfitKernel(M,xdata)
% fit = Carbonfit(M,xdata)
peakloc = [285.1,286.5,287.7,288.48,289.5,290.4,297.1,299.7,293,300];  %% T0 12:35

tanloc=[294.5];
% 1-7, pi* height
% 8-9, sigma* height
% 10-11, sigma* half-width
% 12, arctanstep
wid=[1.00;repmat(1.1,7,1)];
y = zeros(13,length(xdata));
for i=1:12
    if i <= 8, % pi*
        y(i,:) = [M(i)*gaussian(xdata,peakloc(i),wid(i))]';
    elseif i > 8 & i < 11, % sigma*
        y(i,:) = [M(i)*AsyGaussian(xdata,peakloc(i))]';        
    elseif i >= 9  % arctanstep
        %         y(i,:) = [M(i)*arctanstep(xdata,en,1) - min(M(i)*arctanstep(xdata,en,1))]';
        if i==12
            y(i,:) = NexafsStep(xdata,290,M(i),M(i+1))'; %% M(i) is height, M(i+1) between 0 and 1
%         elseif i==9
%             y(i,:) = NexafsStep(xdata,293,M(i),M(i+1))'; 
        end
    end      
end
fit = y;
fit(isnan(fit) | isinf(fit))=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Ccoeffs,bgtotC] = Cbypix(S,badEnergies)
% function [Fecoeffs,Ccoeffs,Cspecies,peakAreas] = bypix(S,FeCl2,FeCl3,badEnergies)

if nargin < 2
    badEnergies = []
end

%% Empty arrays
Ccoeffs = repmat(NaN,[size(S.spectr,1),size(S.spectr,2),11]);
bgtotC = repmat(NaN,[size(S.spectr,1),size(S.spectr,2),2])
%%
for i=1:size(S.spectr,1)
    for j=1:size(S.spectr,2)
        disp([i,j]);        
        if ~S.Masked(i,j) %| ~all(reshape(isfinite(S.spectr(i,j,:)),[],1)), continue, end
            continue,
        end
        try,
            [Cspec,bgC,totC] = normalizeC([S.eVenergy,reshape(S.spectr(i,j,:),[],1)]); 
            bgtotC(i,j,:) = [bgC,totC];
            Ccoeffs(i,j,:) = Cpeakfits(Cspec(:,1),Cspec(:,2));
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [output,bgC,totC] = normalizeC(A);

try, bgC = integrave(A,[278,283]);
catch, bgC = nanmean(A(find(A(:,1) > 278 & A(:,1) < 283),2));
end    
bgSubtracted = (A(:,2)-bgC);
    
try, totC = integrave(A,[301,305]);
catch, totC = nanmean(A(find(A(:,1) > 301 & A(:,1) < 305),2));
end
% subandnorm = bgSubtracted/totC;
% 
% output = [A(:,1),subandnorm];
output=[A(:,1),bgSubtracted];
return
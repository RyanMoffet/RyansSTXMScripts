function TableVals=DeconNexafsSpecSingPart(Sin,particle,pathstr,sample)
Integral=zeros(13,length(Sin.PartLabel));
% namestr={'T0_08_35','T0_10_30','T0_12_35','T1_08_30','T1_13_00','T1_18_00','T2_14_00','T2_19_00'};
colors={'r.-','g.-','b.-','c.-','m.-','y.-','k.-','ko-','ro-','go-'};

for i = 1:length(Sin.PartLabel)
    fitspec=[Sin.eVenergy,Sin.PartSpec(:,i)];
    F = loadFunctions;
    Fc = loadCFunctions;
    [A,bgC,totC] = feval(Fc.normalizeC,fitspec);
    coefs =feval(Fc.Cpeakfits,A(:,1),A(:,2));
    % % % Func=feval(Fc.CarbonfitKernel,coefs,fitspec(:,1))
    % % % plot(fitspec(:,1),Func(1,:))
%     figure,
%     plot(fitspec(:,1),feval(Fc.CarbonfitKernel,coefs,fitspec(:,1))),hold on, %% this plot the individual components
%         legendstr={'C=C','R(C*=O)R/C*OH','CH_{x}','R(C*=O)OH','OC*H_{2}','C*O_{3}',...
%     'K L_{2} 2p_{1/2}','K L_{3} 2p_{3/2}','C-\sigma*','C=\sigma*','','TotC'};
%     legend(legendstr);
%     plot(fitspec(:,1),sum(feval(Fc.CarbonfitKernel,coefs,fitspec(:,1))),'b-'),hold on,
%     plot(A(:,1),A(:,2),'k-'),hold off;
%     title(site{i})
% %     pathstr='C:\RyanM_LBL\Milagro\Analysis\NewAnalysis\Figs\';
    Dnamestr=sprintf('%s%s%s_Decon',sample,Sin.particle,particle{i});
    DeconName=strcat(pathstr,Dnamestr);
%     saveas(gcf,DeconName,'tiff');
    Integral(:,i) = [trapz(fitspec(:,1),feval(Fc.CarbonfitKernel,coefs,fitspec(:,1))')]'%%./...
    %%trapz(sum(feval(Fc.CarbonfitKernel,coefs,fitspec(:,1))))']'
end

TableVals=PeakContribFig(Integral,Sin.PartLabel);
% ExportMatrixIgor(TableVals,site,'Dnamestr',pathstr)

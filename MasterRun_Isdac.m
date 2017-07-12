% RawDir='C:\RyanM_LBL\ISDAC\Data\STXM\Flight30\Sample9\Stacks'  %% directory where raw data is found
% P1Dir='C:\RyanM_LBL\ISDAC\Data\STXM\Flight30\Sample9\Raw'  %% Directory containing raw stack data as .mat files (1 per stack)
% FinDir='C:\RyanM_LBL\ISDAC\Data\STXM\Flight30\Sample9\Fin';  %% Directory containing aligned stack data in OD as .mat files
% % % % % 
% ProcDir(RawDir,P1Dir);
% AlignOD(P1Dir,FinDir);


% % LabelMat=BinaryLabelPlot(Snew.spectr,Snew.eVenergy)
% % MultPartAvSpec(Snew,LabelMat)

Snew=Diffmaps(Snew);
PartLabel(Snew);
PartBar(Snew)
% [T.SVDMap,T.RGBMap]=produceSVDmat(Snew);
% LabelMatrix=LabelStack(Snew.spectr);
% 
% MultPartAvSpec(Snew)
% F=StackMovie(Snew)
% 
% figure,movie(F,1,20)
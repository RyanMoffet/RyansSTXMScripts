% RawDir='C:\RyanM_LBL\Milagro\Mar22Data\T0\1235CST'  %% directory where raw data is found
% P1Dir='C:\RyanM_LBL\Milagro\Mar22Data\MatFiles\T0\1235\Raw'  %% Directory containing raw stack data as .mat files (1 per stack)
% FinDir='C:\RyanM_LBL\Milagro\Mar22Data\MatFiles\T0\1235\Fin';  %% Directory containing aligned stack data in OD as .mat files
% % % 
% ProcDir(RawDir,P1Dir);
% AlignOD(P1Dir,FinDir);
Deglitch=298.3;

Snew=DeglitchStack(Snew,Deglitch)
Snew=Diffmaps(Snew);
Snew=PartLabel(Snew);

% F=StackMovie(Snew)
% figure,movie(F,1,20)
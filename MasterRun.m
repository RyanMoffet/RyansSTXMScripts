% RawDir='C:\RyanM_LBL\Milagro\Mar22Data\T0'  %% directory where raw data is found
% P1Dir='C:\RyanM_LBL\Matlab\STXMNew\P1'  %% Directory containing raw stack data as .mat files (1 per stack)
% FinDir='C:\RyanM_LBL\Matlab\STXMNew\Final';  %% Directory containing aligned stack data in OD as .mat files
% % % 
% ProcDir(RawDir,P1Dir);
% AlignOD(P1Dir,FinDir);

% Diffmaps(Snew.spectr,Snew.eVenergy,Snew.particle);

[T.SVDMap,T.RGBMap]=produceSVDmat(Snew);

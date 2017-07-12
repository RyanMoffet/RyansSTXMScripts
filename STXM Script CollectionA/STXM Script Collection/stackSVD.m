
function svdM = stackSVD(S,varargin)
%function svdM = stackSVD(S,varargin)
%
%Generation of component maps from STXM stack data using Singular Value Decomposition (SVD) analysis with reference spectra
%%R.C. Moffet, T.R. Henn February 2009
%
%Inputs
%------
%S          Standard stack structure array containing the STXM data converted to optical density
%varargin   arbitrary number of two-column vectors representing the chemical component's reference spectra.
%           The first column of the reference spectra vectors contains the energy points (in eV), the second column
%           holds the corresponding absorbance in optical density.
%
%Output
%------
%svdM       m x n x k array containing the component maps. (m, n correspond to the number of stack pixels in y and x dimension,
%           k is determined by the number of component reference spectra passed to the script as varargin.
%           svdM(:,:,i) contains the component map corresponding to the ith reference spectrum in varargin 





% varargin contains the reference data for the # nofcps of components cpnts  
cps=varargin;

% determine number of components:
nofcps=length(varargin);

SeVmin=min(S.eVenergy);
SeVmax=max(S.eVenergy);

% determin energy range of reference spectra
cpseVmin=min(cps{1}(:,1));
cpseVmax=max(cps{1}(:,1));

for k=2:nofcps
    
    if min(cps{k}(:,1)) > cpseVmin
        cpseVmin=min(cps{k}(:,1));
    end
    
    if max(cps{k}(:,1)) < cpseVmax
        cpseVmax=max(cps{k}(:,1));
    end
    
end

% truncate experimental data if reference spectra energy range is smaller than experimental data
if cpseVmin > SeVmin
    
    fstidx=find(S.eVenergy < cpseVmin,1,'first');
    lstidx=find(S.eVenergy < cpseVmin,1,'last');
    % remove experimental data that is out of reference spectra data range
    S.eVenergy(fstidx:lstidx)=[];
    S.spectr(fstidx:lstidx)=[];
    
end

if cpseVmax < SeVmax
    
    fstidx=find(S.eVenergy > cpseVmax,1,'first');
    lstidx=find(S.eVenergy > cpseVmax,1,'last');
    
    % remove experimental data that is out of reference spectra data range
    S.eVenergy(fstidx:lstidx)=[];
    S.spectr(fstidx:lstidx)=[];
    
end

% construction of the reference components coefficient matrix

M=zeros(length(S.eVenergy),nofcps);

for k=1:nofcps
    
    M(:,k)=spline(cps{k}(:,1),cps{k}(:,2),S.eVenergy);
    
end

%construction of the coefficient matrix pseudo inverse using SVD
pseudoInvM=pinv(M);

svdM=zeros(size(S.spectr,1),size(S.spectr,2),nofcps);

for y=1:size(S.spectr,1)
    for x=1:size(S.spectr,2)
        temp(:,1)=S.spectr(y,x,:);
        svdM(y,x,:)=pseudoInvM*temp;
    end
end


return
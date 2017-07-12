function [D,carbox] = OCdataCollector(S,Din)

%load energy vector containing reference energies 280 eV -> 303 eV
load refeV
emax=length(refeV);

chopeVmin=find(S.eVenergy<280,1,'last')+1;
chopeVmax=find(S.eVenergy>303,1,'first')-1;

V=S.spectr(:,:,chopeVmin:chopeVmax);
S.eVenergy=S.eVenergy(chopeVmin:chopeVmax);


% check energy point definition - if different energy definition was used stack needs to be splined.


if isempty(setdiff(S.eVenergy,refeV)) && isempty(setdiff(refeV,S.eVenergy))
    needspline=0;
else
    needspline=1;
end


% find Pixels containing Carbox NOT sp2  && NOT K
[carboxY, carboxX]=find(S.BinCompMap{1}>0);
[sp2Y, sp2X]=find(S.BinCompMap{3}>0);
[potY, potX]=find(S.BinCompMap{4}>0);

carbox(:,1)=carboxY;
carbox(:,2)=carboxX;
sp2(:,1)=sp2Y;
sp2(:,2)=sp2X;
pot(:,1)=potY;
pot(:,2)=potX;

carbox=setdiff(carbox,sp2,'rows');
carbox=setdiff(carbox,pot,'rows');

    
[Dinymax, Dinxmax]=size(Din);
addX=size(carbox,1);

D=zeros(emax,Dinxmax+addX);

if isempty(Din)==0
    D(1:Dinymax,1:Dinxmax)=Din;
end

% loop over pixels containing Carbox NOT sp2  && NOT K, add data to D (and spline if needed)
for k=1:addX
    
    pixSpec=squeeze(V(carbox(k,1),carbox(k,2),:));
    
    if needspline==1
        pixSpec=spline(S.eVenergy,pixSpec,refeV);
    end
    
    % scale extracted spectrum
    specmin=min(pixSpec);
    pixSpec=(pixSpec-specmin);
    pixSpec=pixSpec./max(pixSpec);
    
    D(:,Dinxmax+k)=pixSpec;
    
    
end

return 


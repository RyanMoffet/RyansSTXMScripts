%% subtractbackground - subtracts linear background from NEXAFS spectra and returns baseline subtracted spestrum
%  Uses the linear pre-Edge regime < 704 eV


function [spec_out]=subtractbackground(eV,spec)

input(:,1)=eV(:,1);
input(:,2)=spec(:,1);

energylength=size(input,1);                                     %Total # of data points in NEXAFS spectrum 

preedgeend=find(input(:,1)<704,1,'last');                       %Locate index of last data Point with Energy < 705eV

%p=polyfit(input(1:preedgeend,1),smooth(input(1:preedgeend,2)),1);       %least square linear fit of pre edge data       
p=polyfit(input(1:preedgeend,1),input(1:preedgeend,2),1);       %least square linear fit of pre edge data       

baseline=zeros(energylength,1);

for k=1:energylength                                            %Construction of the baseline vector
    
    baseline(k,1)=p(1,1)*input(k,1)+p(1,2);
    
end

spec_out=zeros(size(input,1),size(input,2));

spec_out(:,1)=input(:,1);
spec_out(:,2)=input(:,2)-baseline(:,1);

return

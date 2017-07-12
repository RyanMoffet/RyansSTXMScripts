%% DeglitchStack
% removes images from stack
% S = complete stack struct
% badEnergy=

function Snew=DeglitchStackDefocus1(S,badEnergy)

numbad=length(badEnergy);
resolution=0.1;            % Half of best energy resolution in scan definition

Snew=S;
lengthE=length(Snew.eVenergy);

% for counter=1:numbad            % Find bad energy points

fidx=find(Snew.eVenergy < badEnergy(1)+resolution & ...
    Snew.eVenergy > badEnergy(1)-resolution);
lidx=find(Snew.eVenergy < badEnergy(2)+resolution & ...
    Snew.eVenergy > badEnergy(2)-resolution);
if isempty(lidx)==0
    diffim=Snew.spectr(:,:,lidx)-Snew.spectr(:,:,fidx);
    
    %         Snew.eVenergy(rmindex)=[];
    for i=lidx:lengthE
        Snew.spectr(:,:,i)=Snew.spectr(:,:,i)-diffim;
    end
    %     else
    %
    %         displayeV=num2str(badEnergy(counter));
    %         display(strcat('Error: no energy match for input = ',displayeV,' eV! Image not removed!!!'))
    %         clear displayeV;
    %
    %     end
    
    clear rmindex
    
end

return
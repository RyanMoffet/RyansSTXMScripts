function Out=ExtractOCSpec(Sin)

%% Extracts spectra from OC Mask
%% RC Moffet, 2010

energy=Sin.eVenergy;
Specs=Sin.PartSpec;
labels=Sin.PartLabel;
OCSpec=zeros(length(energy),1);
cnt=1;
for i=1:length(labels)
    ecidx=findstr(labels{i},'EC');
    if isempty(ecidx)
        OCSpec=OCSpec+Specs(:,i); %% take spectrum from particles w/o ec
        cnt=cnt+1;
    end
    clear ecidx;
end

OCSpec=OCSpec./cnt; %% divide by the number of particles
Out=[energy,OCSpec];
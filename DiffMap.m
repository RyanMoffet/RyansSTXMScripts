    %% Differential Maps
    
    DiffMap=zeros(size(S.spectr,1),size(S.spectr,2),4);
    
    % Pre Edge Map
    peakregion1=find(S.eVenergy <284 & S.eVenergy>283);
    k0=min(peakregion1);
    
    %Calculate average Pre-edge value
    
    for k=(k0-2):(k0+2)
        
        DiffMap(:,:,1)=DiffMap(:,:,1)+negfilter(inffilter(S.spectr(:,:,k)));
        
    end
    
    DiffMap(:,:,1)=1/5*DiffMap(:,:,1);
    %% Potassium Minus Post Edge Map
    
    %locate 1st K peak at 297.3 eV
    Kpeak1pos=find(S.eVenergy<297.4 & S.eVenergy > 297.2);    
    %locate 2nd K peak at 299.8 eV
    Kpeak2pos=find(S.eVenergy<299.9 & S.eVenergy > 299.7); 
    
    a=negfilter(inffilter(S.spectr(:,:,Kpeak1pos)))+negfilter(inffilter(S.spectr(:,:,Kpeak2pos)));
    postedge=negfilter(inffilter(S.spectr(:,:,size(S.eVenergy,1))))+negfilter(inffilter(S.spectr(:,:,(size(S.eVenergy,1)-3))));
    
    DiffMap(:,:,2)=a-postedge;
    %% 285 eV sp2 peak Minus post edge Map
    
    ECpeakpos=find(S.eVenergy<284.9 & S.eVenergy > 284.75);
    
    buffer=zeros(size(S.spectr,1),size(S.spectr,2));
    
    buffer(:,:)=S.spectr(:,:,ECpeakpos);
    
    DiffMap(:,:,3)=buffer(:,:)-DiffMap(:,:,1);
    %% Post Edge Minus Pre Edge Map
    
    DiffMap(:,:,4)=postedge(:,:)-DiffMap(:,:,1);
    
    T.DiffMap=DiffMap;
    
    % Show DiffMaps
    figure('Name',particle,'NumberTitle','off')
    subplot(2,2,1)
    imagesc(DiffMap(:,:,1))
    title('Inorganic')
    colorbar
    subplot(2,2,2)
    imagesc(DiffMap(:,:,2))
    title('Potassium')
    colorbar
    subplot(2,2,3)
    imagesc(DiffMap(:,:,3))
    title('EC')
    colorbar
    subplot(2,2,4)
    imagesc(DiffMap(:,:,4))
    title('OC')
    colorbar

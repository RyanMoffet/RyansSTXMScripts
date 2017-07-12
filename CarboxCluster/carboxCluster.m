function carboxInfo = carboxCluster(nofC,varargin)

% collect carbox pixel data for all nargin Stacks in D matrix
for z=1:size(varargin,2)
    
    S=varargin{z};
   
    if z==1
        [D,carbox] = OCdataCollector(S,[]);
    else
        [D,carbox] = OCdataCollector(S,D);
    end
    
    carboxInfo{z}.ymax=size(S.spectr,1);
    carboxInfo{z}.xmax=size(S.spectr,2);
    carboxInfo{z}.carbox=carbox;
    carboxInfo{z}.Xvalue=S.Xvalue;
    carboxInfo{z}.Yvalue=S.Yvalue;
    
end

% perform cluster analysis on global carbox spectra collection
idx=kmeans(transpose(D),nofC,'EmptyAction','singleton');

% extract & plot global average cluster spectra
colorTable={'b','r','k','g','m','c','b--','r--','k--','g--','m--','c--'};
load refeV
specs=zeros(98,nofC);
figure

 for z=1:nofC
        
        cc=0;
        
        for k=1:length(idx)
            
            if idx(k)==z
                
                specs(:,z)=specs(:,z)+D(:,k);
                cc=cc+1;
                
            end
            
        end
        
        specs(:,z)=specs(:,z)./cc;
        
        hold on
        plot(refeV,specs(:,z),colorTable{mod(z,12)+1},'LineWidth',1.5)
        warning off
        legend({'C1','C2','C3','C4','C5','C6','C7','C8','C9','C10','C11','C12','C13','C14','C15','C16','C17','C18','C19','C20'})
        warning on
        xlabel('Photon Energy (eV)','FontSize',12,'FontWeight','bold')
        ylabel('Absorbance (a.u.)','FontSize',12,'FontWeight','bold')
        title('Global average cluster spectra','FontSize',14,'FontWeight','bold')
 end

% generate single stack cluster average spectra and cluster maps
sumcounter=0;


for z=1:size(varargin,2)
    figure
    nofpx=size(carboxInfo{z}.carbox,1);
    M=zeros(carboxInfo{z}.ymax,carboxInfo{z}.xmax);
    subspecs=zeros(98,nofC);
    
    
    for counter=1:nofC
        
        cc=0;
        
        for k=(sumcounter+1):(sumcounter+nofpx)
            
            if idx(k)==counter
                
                subspecs(:,counter)=subspecs(:,counter)+D(:,k);
                cc=cc+1;
                
            end
            
            M(carboxInfo{z}.carbox((k-sumcounter),1),carboxInfo{z}.carbox((k-sumcounter),2))=idx(k);
            
        end
        
        subspecs(:,counter)=subspecs(:,counter)./cc;
        
        subplot(1,2,2)
        hold on
        plot(refeV,subspecs(:,counter),colorTable{mod(counter,12)+1},'LineWidth',1.5)
        warning off
        legend({'C1','C2','C3','C4','C5','C6','C7','C8','C9','C10','C11','C12','C13','C14','C15','C16','C17','C18','C19','C20'})
        warning on
        xlabel('Photon Energy (eV)','FontSize',12,'FontWeight','bold')
        ylabel('Absorbance (a.u.)','FontSize',12,'FontWeight','bold')
        
    end
    
    carboxInfo{z}.M=M;
    carboxInfo{z}.subspecs=subspecs;
    sumcounter=sumcounter+nofpx;
    
    subplot(1,2,1)
    imagesc([0 carboxInfo{z}.Yvalue],[0,carboxInfo{z}.Xvalue],M)
    axis image
    colorbar
    xlabel('X-Position (µm)','FontSize',11,'FontWeight','normal')
    ylabel('Y-Position (µm)','FontSize',11,'FontWeight','normal')
    %title(sprintf('KMeans cluster distribution map'),'FontSize',12,'FontWeight','bold')
    
    
end
        

return
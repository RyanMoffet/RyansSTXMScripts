function carboxInfo = carboxCluster(nofC,varargin)

% collect carbox pixel data for all nargin Stacks in D matrix
for z=1:size(varargin,2)
    
    S=varargin{z};
   %% this conditional tests for multiple stacks in one set
    if z==1 % if we have one stack or are at the first stack...
        [D,carbox] = OCdataCollector(S,[],0);
    else % else combine data...
        [D,carbox] = OCdataCollector(S,D,0);
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
% colorTable={'b','r','k','g','m','c','r','r--','k--','g--','m--','c--'};
% colorTable=[1,1,1;0,0,1;1,0,0;0,1,0]
colorTable=zeros(nofC+1,3);
colorTable(2:nofC+1,:)=jet(nofC);
% load refeV
refeV=S.eVenergy;
nev=length(refeV);
specs=zeros(nev,nofC);
% figure

 for z=1:nofC
        
        cc=0;
        
        for k=1:length(idx)
            
            if idx(k)==z
                
                specs(:,z)=specs(:,z)+D(:,k);
                cc=cc+1;
                
            end
            
        end
        
        specs(:,z)=specs(:,z)./cc;
        
%         hold on
%         plot(refeV,specs(:,z),'Color',colorTable(z+1,:),'LineWidth',1.5)
%         warning off
%         legend({'C1','C2','C3','C4','C5','C6','C7','C8','C9','C10','C11','C12','C13','C14','C15','C16','C17','C18','C19','C20'})
%         warning on
%         xlabel('Photon Energy (eV)','FontSize',12,'FontWeight','bold')
%         ylabel('Absorbance (a.u.)','FontSize',12,'FontWeight','bold')
%         title('Global average cluster spectra','FontSize',14,'FontWeight','bold')
 end

% generate single stack cluster average spectra and cluster maps
sumcounter=0;


for z=1:size(varargin,2)
    figure
    nofpx=size(carboxInfo{z}.carbox,1);
    M=zeros(carboxInfo{z}.ymax,carboxInfo{z}.xmax);
    subspecs=zeros(nev,nofC);
    
    j=0;
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
        plot(refeV,subspecs(:,counter)+j,'Color',colorTable(counter+1,:),'LineWidth',1.5)
        xlim([min(refeV),max(refeV)]);
        warning off
        legend({'C1','C2','C3','C4','C5','C6','C7','C8','C9','C10','C11','C12','C13','C14','C15','C16','C17','C18','C19','C20'})
        warning on
        xlabel('Photon Energy (eV)','FontSize',12,'FontWeight','bold')
        ylabel('Absorbance (a.u.)','FontSize',12,'FontWeight','bold')
        j=j+max(subspecs(:,counter))
%         j=j+1;
    end
    set(gca,'YTickLabel',{},'YTick',zeros(1,0),'PlotBoxAspectRatio',[1/j,1,1])
    xlim([280,320]);
    ylim([0,j+.1]);
    vline([285,288.6],'k:')
    
    
    % figure,
% j=0;
% for i=1:length(ecspec)
%     plot(ecspec{i}(:,1),ecspec{i}(:,2)+j,'k-','LineWidth',2),hold on,
% %     legendstr{j+1}=textdata{i};
% %     textstr{j+1}=strcat(['Cluster ' textdata{i} sprintf(' N=%g',TakNums(i-1))]);
%     text(290,j+0.25,textstr{i});
%     j=j+max(ecspec{i}(:,2))
% %     j=j+1;
% end

    
    
    
    [nx,ny]=size(M);
    rmat=zeros(nx,ny);
    gmat=zeros(nx,ny);
    bmat=zeros(nx,ny);
    for i=0:nofC
        tidx=sub2ind(size(M),find(M==i));
        rmat(tidx)=colorTable(i+1,1);
        gmat(tidx)=colorTable(i+1,2);
        bmat(tidx)=colorTable(i+1,3);
    end
    colormat=zeros(nx,ny,3);
    colormat(:,:,1)=rmat;
    colormat(:,:,2)=gmat;
    colormat(:,:,3)=bmat;

    carboxInfo{z}.M=M;
    carboxInfo{z}.subspecs=subspecs;
    sumcounter=sumcounter+nofpx;
    
    subplot(1,2,1)
    
    
    image([0 carboxInfo{z}.Yvalue],[0,carboxInfo{z}.Xvalue],colormat)
    colormap('jet')
    axis image
%     caxis([1 nofC]);
%     colorbar
    xlabel('X-Position (µm)','FontSize',11,'FontWeight','normal')
    ylabel('Y-Position (µm)','FontSize',11,'FontWeight','normal')
    title(sprintf('KMeans cluster distribution map'),'FontSize',12,'FontWeight','bold')
    
    
end
        

return
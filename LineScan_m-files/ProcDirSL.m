function ProcDirSL(RawDir,FinDir,varargin)

%% This script processes stxm data found in "RawDir" and places it in FinDir

datafolder=RawDir;
cd(datafolder) %% move to raw data folder
foldstruct=dir;

if ~isempty(varargin)
    badE=varargin{1};
else
    badE=[];
end

numobj=length(dir);
j=1;
for i = 3:numobj %% loops through stack folders in raw data folder
    
    if isdir(fullfile(datafolder,foldstruct(i).name))
        
        cd(fullfile(datafolder,foldstruct(i).name)); %% move to data folder
        currfoldstruct=dir;
        numobj2=length(dir);
        j=1;
        while j<numobj2
            hdridx=findstr(currfoldstruct(j).name,'hdr');
            if ~isempty(hdridx)
                type=ReadHdrScanType(currfoldstruct(j).name);
                
                if strcmp(type,'Image Scan')
                    
                    S=LoadStackRaw(pwd); %% load stack data
                    S.particle=sprintf('%s',foldstruct(i).name); %% print particle name
                    S=DeglitchStack(S,badE);
                    figure,plot(S.eVenergy,squeeze(mean(mean(S.spectr))))
                    S=AlignStack(S);
                    Snew=OdStack(S,'O');
                    cd(FinDir);
                    save(sprintf('%s%s','F',foldstruct(i).name))
                    j=numobj2+1;
                else j=j+1;
                end
            else j=j+1;
            end
        end
        
        cd(datafolder);
        
    else    hdridx=findstr(foldstruct(i).name,'hdr');
        
        if ~isempty(hdridx)
            type=ReadHdrScanType(foldstruct(i).name);
            
            if strcmp(type,'NEXAFS Line Scan')
                
                [L.eVenergy,L.Xvalue,L.Yvalue]=ReadHdrLineScan(foldstruct(i).name);
                L.particle=sprintf('%s',foldstruct(i).name); %% print particle name
                token = strtok(L.particle,'.');
                L.particle=token;
                ximfile=[L.particle '_a.xim'];
                rawspec(1,:,:)=flipud(load(fullfile(datafolder,ximfile)));
                L.spectr(1,:,:)=rawspec(1,:,1:end-1);
                Lnew=OdStack(L,'O');
                cd(FinDir);
                save(sprintf('%s%s','L',L.particle)); %% save stack data in .mat file
                clear L;
                clear rawspec;
                cd(datafolder);
                
            elseif strcmp(type,'Image Scan')
                
                %                 S=LoadStackRaw(pwd); %% load stack data
                S.spectr=flipud(load(foldstruct(i+1).name));
                [S.eVenergy,S.Xvalue,S.Yvalue]=ReadHdr(foldstruct(i).name);
                S.particle=sprintf('%s',foldstruct(i).name); %% print particle name
                %                 S=DeglitchStack(S,badE);
                %                 figure,plot(S.eVenergy,squeeze(mean(mean(S.spectr))))
                %                 S=AlignStack(S);
                Snew=OdStack(S,'O');
                cd(FinDir);
                save(sprintf('%s%s','F',foldstruct(i).name))
%                 j=numobj2+1;
            else j=j+1;
            end
        end
    end
end

end

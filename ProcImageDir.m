function ProcImageDir(RawDir,FinDir,varargin)

%% This script processes stxm data found in "RawDir" and places it in FinDir

datafolder=RawDir;
cd(datafolder) %% move to raw data folder
foldstruct=dir;
numobj=length(dir);

j=1;
for i = 3:numobj %% loops through stack folders in raw data folder
    hdridx=findstr(foldstruct(i).name,'hdr');
    if ~isempty(hdridx)
        type=ReadHdrScanType(foldstruct(i).name);
        if strcmp(type,'Image Scan')
            S.spectr=flipud(load(foldstruct(i+1).name));
            [S.eVenergy,S.Xvalue,S.Yvalue]=ReadHdr(foldstruct(i).name);
            nidx=findstr(foldstruct(i).name,'.');
            S.particle=sprintf('%s',foldstruct(i).name(1:nidx-1)); %% print particle name
            Snew=OdStack(S,'O');
            cd(FinDir);
            save(sprintf('%s%s','F',S.particle))
        end
    end
    cd(datafolder);
end

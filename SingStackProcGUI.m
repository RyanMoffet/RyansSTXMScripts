function SingStackProcGUI(datafolder,plotfig,varargin)

%% This script processes stxm data found in "RawDir" and places it in
%% "FinDir". In FinDir, the stack data will be saved in the array Snew.
%% INPUT: RawDir - string containing path to raw stxm data
%%        FinDir - string containing path to aligned data in OD
%%        Name - name of raw stxm data folder to be processed
%%        varargin{1} - vector of energies to be removed from stack
%% OCT 2009 RCM

% datafolder=RawDir;
cd(datafolder) %% move to raw data folder
foldstruct=dir;
disp(sprintf('Processing %s',foldstruct(3).name))
if ~isempty(varargin)
    x = inputdlg('Enter energies to remove separated by a space:',...
        'Sample', [1 50]);
    badE = str2num(x{:});
else
    badE=[];
end
ImpTest=0;
cnt=1;
numobj=length(dir);
%     if strcmp(foldstruct(i).name,Name)
%         righti=i;
%         try cd(fullfile(datafolder,foldstruct(i).name)); %% move to data folder
S=LoadStackRaw(pwd); %% load stack data
sdim=size(S.spectr);
if sdim(3)>length(S.eVenergy)
    S.spectr=S.spectr(:,:,1:length(S.eVenergy));
end

for i = 3:numobj %% loops through stack folders in raw data folder
    bidx=strfind(foldstruct(i).name,'.hdr');
    if ~isempty(bidx)
        S.particle=sprintf('%s',foldstruct(i).name(1:bidx-1));
        clear bidx
    end
end

%% Remove bad energies
%             S.particle=sprintf('%s',foldstruct.name); %% print particle name
S=DeglitchStack(S,badE);
%             filename=sprintf('%s%s%s',P1Dir,'\S',foldstruct(i).name); %% define directory to save file in
%             save(sprintf('%s%s','S',foldstruct(i).name)) %% save stack data in .mat file

%% align the stack
% figure,plot(S.eVenergy,squeeze(mean(mean(S.spectr))))
S=AlignStack(S);
if length(S.eVenergy)<10
    Snew=OdStack(S,'map',plotfig);
else
    Snew=OdStack(S,'O',plotfig);
end
%             cd(FinDir)
cd ..
save(sprintf('%s%s','F',S.particle))
ImpTest=1;
%         catch
%
%             cd(datafolder); %% move back to raw data folder
%             %         cd ..
%             disp('wrong path?')
%             cnt=cnt+1;
%         end
%     else
%         continue
%     end
% end


if ImpTest==0
    error('No import performed: Wrong filename or path?');
end
% cd(P1Dir)
% numobj=length(dir);
% for i = 3:numobj %% loops through stack matfiles
%     if strcmp(foldstruct(i).name,Name)
%         foldstruct=dir;
%         load(sprintf('%s',foldstruct(i).name));
%         Snew=AlignStack(S);
%         Snew=OdStack(Snew,'C');
%         S
%         cd(FinDir)
%         save(sprintf('%s%s','F',foldstruct(i).name))
%         cd(P1Dir);
%     else
%         continue
%     end
% end
if plotfig==1
    load(sprintf('%s%s','F',S.particle));
    Snew=CarbonMaps(Snew,0.35);
%     STACKLab(Snew)
end
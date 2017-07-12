function SingStackProcGUI(datafolder)

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

% if ~isempty(varargin)
%     badE=varargin{1};
% else
%     badE=[];
% end

ImpTest=0;
cnt=1;
numobj=length(dir);
%     if strcmp(foldstruct(i).name,Name)
%         righti=i;
%         try cd(fullfile(datafolder,foldstruct(i).name)); %% move to data folder
S=LoadStackRaw(pwd); %% load stack data
for i = 3:numobj %% loops through stack folders in raw data folder
    bidx=strfind(foldstruct(i).name,'.hdr');
    if ~isempty(bidx)
        S.particle=sprintf('%s',foldstruct(i).name(1:bidx-1));
        clear bidx
    end
end
%             S.particle=sprintf('%s',foldstruct.name); %% print particle name
%             S=DeglitchStack(S,badE);
            %             filename=sprintf('%s%s%s',P1Dir,'\S',foldstruct(i).name); %% define directory to save file in
            %             cd(P1Dir)
            %             save(sprintf('%s%s','S',foldstruct(i).name)) %% save stack data in .mat file
            figure,plot(S.eVenergy,squeeze(mean(mean(S.spectr))))
            S=AlignStack(S);
            if length(S.eVenergy)<5
                Snew=OdStack(S,'map',1);
            else
                Snew=OdStack(S,'O',1);
            end
%             cd(FinDir)
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

load(sprintf('%s%s','F',S.particle));
Snew=CarbonMaps(Snew);
STACKLab(Snew)
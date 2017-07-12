function [LabelCnt,size,label,CmpSiz,SootCarbox,TotalCarbon,Carbox,Sp2,OutRad,RadStd,SingRad]=...
    DirLabelMaps(InDir,sample,saveflg,savepath,sp2)


%%  [LabelCnt,OutSpec,size,label,CmpSiz,OutOCSpec,OutRad,RadStd,OutCmp]...
%%     =DirLabel(InDir,sample,saveflg,savepath,sp2)
%% INPUT: InDir - cell array of strings containing directory where stacks are saved as
%%                .mat files
%%        sample - cell array of strings indicating sample names
%%
%% OUTPUT: LabelCnt - matrix containing counts for particle classes
%%                    columns: [OC,ECOC,INECOC,INOC] rows: [sample1,
%%                    sample2, sample3...]
%%         OutSpec - cell array containing grand average spectra for the
%%                   different samples. [energy,OD]
%%         size - cell array containing sizes for individual particles
%%                within the different samples
%%         label - cell array containing labels for individual particles
%%         CmpSiz - cell array of sample matrices containing component
%%                  areas (in um^2). Rows correspond to particles and columns are as
%%                  follows: ['OCArea','InArea','Sp2Area','KArea','CO3Area','Total
%%                  Area']
%%         SootCarbox is ??
%%         TotalCarbon is the height of total carbon/particle
%%         OutOCSpec - Cell array of spectra for OC particles only
%%         OutRad - Cell array of average radial particle scans for each
%%                  class. Row is relative dist from center and column is
%%                  particle type.
%%         OutCmp - cell array of average spectra for component specified
%%                  in call to ComponentSpec.m
%% OCT 2009, RCMoffet

startingdir=dir;
LabelCnt=zeros(4,length(InDir));

% savepath='C:\RyanM_LBL\ISDAC\Results\STXMAnalysis\SingleParticleResults\';

%% begin loop over sample directories
for j=1:length(InDir)  %% loop over different sample directories
    
    cd(InDir{j});
    directory=dir;
    loopctr=1;
    size{j}=[];
    label{j}=[];
    CmpSiz{j}=[];
    TotPix=0;
    SootCarbox{j}=[];
    TotalCarbon{j}=[];
    Carbox{j}=[];
    Sp2{j}=[];
    for l=1:length(directory)  %% loop over stacks
        %         try
        ind=strfind(directory(l).name,'.mat');
        if ~isempty(ind)
            load(directory(l).name);
            sprintf(directory(l).name)
            if length(Snew.eVenergy)<3
                beep
                disp('too few images for CarbonMaps');
                continue
            end
            test=Snew.eVenergy(Snew.eVenergy<325 & Snew.eVenergy>275);
            if isempty(test)
                disp('this is not the carbon edge')
                continue
            end
            if max(test)<315
                disp('no post edge, stack skipped')
                continue
            end
            %% Run DiffMaps and label particles
            if saveflg==1  %% test for figure saving option "saveflg"
                Sinp=CarbonMaps(Snew,sp2,savepath,sample{j});
                %                 Sinp=SootCarboxMap(Sinp,0);
                Sinp=SootCarboxSizeHist(Sinp,1)
            else
                Sinp=CarbonMaps(Snew,sp2,1); %% call without producing figures
                %                 Sinp=SootCarboxMap(Snew,0);
                Sinp=SootCarboxSizeHist(Sinp,1)
            end
            %% count particle classes
            NewCount=LabelCount(Sinp)';
            LabelCnt(:,j)=LabelCnt(:,j)+NewCount;
            %% perform radial scans
            Sinp=DistCent(Sinp);
            [AvgRadClass{loopctr},AvgStdClass{loopctr},npart{loopctr},SingRadScans{loopctr}]=...
                MapRadialScanSpline(Sinp,1);
            %% collect size, particle classes, map values and component areas
            [class,siz]=ChemSiz(Sinp);
            size{j}=[size{j},siz];
            label{j}=[label{j},class];
            CmpSiz{j}=[CmpSiz{j};Sinp.CompSize];  %% area of the different components
            SootCarbox{j}=[SootCarbox{j},Sinp.AvSootCarb];
            TotalCarbon{j}=[TotalCarbon{j},Sinp.AvTotC]; %% height of total carbon/particle
            Carbox{j}=[Carbox{j},Sinp.AvCarbox]; %% this is the height of the carbox peak/particle
            Sp2{j}=[Sp2{j},Sinp.AvSp2]; %% This is the height of the Sp2 peak/particle
            %             OutRad={};RadStd={};SingRad={};
            [OutRad{j},RadStd{j},SingRad{j}]=SumRad(AvgRadClass,AvgStdClass,npart,SingRadScans);
            %     figure,boxplot(SingRad{j}{4}','plotstyle','compact')
            %     figure,errorbar([1:11],OutRad{j}(:,4),RadStd{j}(:,4))
            %     OutRad=NaN;
            %% clean house
            clear ind NewCount;
            loopctr=loopctr+1;
            clear siz;
            close all;
        end
        %         catch ME
        %             ME.stack
        %             ME.message
        %             disp('.mat file probably not a STXM stack')
        %         end
    end
    %% clean house
    clear loopctr ColLab collabel %SingPTab;
end

return



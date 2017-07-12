function [LabelCnt,OutSpec,size,label,CmpSiz,OutOCSpec,OutRad,RadStd,SingRad,OutCmp]...
    =DirLabel(InDir,sample,saveflg,savepath,sp2)


%%  [LabelCnt,OutSpec,size,label,CmpSiz,OutOCSpec,OutRad,RadStd,OutCmp]...
%%     =DirLabel(InDir,sample,saveflg,savepath,sp2)
%% INPUT: InDir - string containing directory where stacks are saved as
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
    for l=1:length(directory)  %% loop over stacks
        
        ind=strfind(directory(l).name,'.mat');
        if ~isempty(ind)
            load(directory(l).name);
            
            sprintf(directory(l).name)
            %% Run DiffMaps and label particles
            if saveflg==1  %% test for figure saving option "saveflg"
                Sinp=DiffmapsForDirLabel(Snew,sp2,savepath,sample{j});
                if isempty(Sinp.DiffMap)
                    continue
                end
                Sinp=PartLabelCompSize(Sinp,savepath,sample{j});
            else
                Sinp=DiffmapsForDirLabel(Snew,sp2);
                if isempty(Sinp.DiffMap)
                    continue
                end
                Sinp=PartLabelCompSize(Sinp,0);
            end
            %% count particle classes
            NewCount=LabelCount(Sinp)';
            LabelCnt(:,j)=LabelCnt(:,j)+NewCount;
            %% sum individual particle spectra
            spec{loopctr}=[Sinp.eVenergy,sum(Sinp.PartSpec',1)'];
            %% extract component spectra
%             [CmpSpec{loopctr},npix]=ComponentSpec(Sinp,'all'); 
            [CmpSpec{loopctr},npix]=ComponentSpec(Sinp,'COOH',0);%% extract spec for all COOH regions. This is the mean OD for the COOH containing pixels
%             [K{loopctr},npix]=ComponentSpec(Sinp,'K');
%             [Inorg{loopctr},npix]=ComponentSpec(Sinp,'Inorg');
%             [EC{loopctr},npix]=ComponentSpec(Sinp,'EC');

           %% Single Particle Deconvolution Analysis
           for k=1:length(Sinp.PartLabel)
               particleId{k}=sprintf('P%d',k);
           end
           for k=1:length(Sinp.PartLabel)
               ColLab{loopctr}{k}=sprintf('%s_%d',Sinp.particle,k);
           end
%             SingPTab{loopctr}=DeconNexafsSpecSingPart(Sinp,particleId,savepath,sample{j});
% %            SingPTab{loopctr}=zeros(length(TabVals(:,1)),length(TabVals(1,:)+2));
 
            %% add pixels and multiply spectra by the sum
%             TotPix=TotPix+npix;
%             CmpSpec{loopctr}(:,2)=CmpSpec{loopctr}(:,2);
            
            OCspec{loopctr}=ExtractOCSpec(Sinp); %% this gives average spectrum per particle
%          %% perform radial scans
%             Sinp=DistCent(Sinp);
%             [AvgRadClass{loopctr},AvgStdClass{loopctr},npart{loopctr},SingRadScans{loopctr}]=...
%                 RadialScanSpline(Sinp,5);

            %% collect size, particle classes and component areas             
            [class,siz]=ChemSiz(Sinp); 
            size{j}=[size{j},siz];
            label{j}=[label{j},class];
            CmpSiz{j}=[CmpSiz{j};Sinp.CompSize];  %% area of the different components
            %% clean house
            clear ind NewCount;
            loopctr=loopctr+1;
            clear siz;
            close all;
        end
    end
    OutSpec{j}=SumSpec(spec,length(label{j}));
    OutOCSpec{j}=SumSpec(OCspec,length(label{j}));
    OutCmp{j}=SumSpec(CmpSpec,length(label{j}));
%     for m=1:length(CmpSpec)
%         figure,plot(CmpSpec{m}(:,1),CmpSpec{m}(:,2))
%     end
    %% Finalize deconvolution data for output
%     DeconTab=SingPTab{1};
%     collabel=ColLab{1};
%     for l=2:length(SingPTab(1,:))
%         DeconTab=[DeconTab,SingPTab{l}];
%         collabel={collabel{1:end},ColLab{l}{1:end}};
%     end
%     tabname=strcat(sample{j},'Decon');
%     ExportMatrixIgor(DeconTab,collabel,tabname,savepath)
      %% Finalize radial scan data for output
OutRad={};RadStd={};SingRad={};
%     [OutRad{j},RadStd{j},SingRad{j}]=SumRad(AvgRadClass,AvgStdClass,npart,SingRadScans);    
%     figure,boxplot(SingRad{j}{4}','plotstyle','compact')
%     figure,errorbar([1:11],OutRad{j}(:,4),RadStd{j}(:,4))
%     OutRad=NaN;

    %% clean house
    clear spec loopctr AvgRadClass AvgStdClass OCspec CmpSpec ColLab collabel %SingPTab;
end

return



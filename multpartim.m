function multpartim(InDir,mapflg)


%%  [LabelCnt,OutSpec,size,label,CmpSiz,OutOCSpec,OutRad,RadStd,OutCmp]...
%%     =DirLabel(InDir,sample,saveflg,savepath,sp2)
%% INPUT: InDir - string containing directory where stacks are saved as
%%                .mat files
%%        sample - cell array of strings indicating sample names
%%        mapflg - set to 1 if doing multpartim using CarbonMaps.m
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
%% OCT 2009, RCM
cd(InDir)
startingdir=dir;
LabelCnt=zeros(4,length(InDir));
figsiz=1;
scrsz=get(0,'ScreenSize');
figure('units','normalized','position',[0,0,figsiz.*scrsz(4)/scrsz(3),figsiz]);
set(gcf, 'color', 'k');
set(gca, 'color', 'k');
%% begin loop over sample directories
directory=dir;
subnum=ceil(sqrt(length(directory)-2));
nstack=length(directory)-2;
msize=ceil(sqrt(nstack));

%% loop over directories and store x and y dimensions in matrices x and y
x=zeros(msize,msize);y=x; % initialize x and y - the X and Y vals for each stack
ctr=1;
for j=1:length(directory) 
    ind=strfind(directory(j).name,'.mat');
    if ~isempty(ind)
        load(directory(j).name)
        x(ctr)=Snew.Xvalue;   
        y(ctr)=Snew.Yvalue;
        ctr=ctr+1;
    end
end
%% Calculate maximum dimensions of the entire figure, initialize variables
maxdim=max([sum(x')+x(:,end)',sum(y)+y(end,:)]); % calculate maximum possible dimensions
x=x./maxdim;y=y./maxdim;
xmax=max(x');
ymax=max(y);
rcnt=1; % initialize row counters
ccnt=1; % initialize column counters
ybot=1-ymax(1);
xpos=0;
xmove=0;
ctr=1;
for j=1:length(directory)  %%
    ind=strfind(directory(j).name,'.mat');
    if ~isempty(ind)
        load(directory(j).name);
        sprintf(directory(j).name)
        %% Run DiffMaps and label particles
        if mapflg==0
            Sinp=DiffmapsNoFig(Snew,.35);
            Sinp=PartLabelCompSizeNoFig(Sinp);
        elseif mapflg==1
            if length(Snew.eVenergy)<5
                Sinp=CarbonMaps(Snew,.35,1);
            else
                Sinp=DiffmapsNoFig(Snew,.35);
                Sinp=PartLabelCompSizeNoFig(Sinp);
            end
        end
        %check for undefined component map...continue if there is
        %none
        if ~isfield(Sinp,'RGBCompMap')
            beep
            disp('Warning: RGBCompMap doesnt exist, image scaling may be screwed');
            continue
        else
            clear varitest
            %set up axes
            MatSiz=size(Sinp.LabelMat);
            XSiz=x(ctr)/MatSiz(1); % relative pixel size
            YSiz=y(ctr)/MatSiz(2); % relative pixel size            xdat=[0:XSiz:x(ctr)];
            ydat=[0:YSiz:y(ctr)];
            sprintf('%s',Sinp.particle);
            %         subplot(subnum,subnum,l-2),
            %         subimage(xdat,ydat,uint8(Sinp.RGBCompMap))
            %         set(gca, 'XTick', [], 'YTick', [])
            if ccnt<=msize
                ccnt=ccnt+1;
                xpos=xpos+xmove;
                ypos=ybot+(ymax(rcnt)-y(ctr))./2;
            else
                ccnt=1;
                xpos=0;
                rcnt=rcnt+1;
                ybot=ybot-ymax(rcnt);
                ypos=ybot+(ymax(rcnt)-y(ctr))./2;
                %             xpos=xpos+x(j)./2;
                ccnt=ccnt+1;
            end
            axes('position',[xpos,ypos,x(ctr),y(ctr)])
            image(xdat,ydat,uint8(Sinp.RGBCompMap))
            set(gca, 'XTick', [], 'YTick', [])
            %         axis('image')
            xmove=x(ctr);
            ctr=ctr+1;
        end
    end
end

return



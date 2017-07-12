function [LabelCnt,OutSpec,size,label,CmpSiz,OutOCSpec]=DirRadial(InDir)

startingdir=dir;
LabelCnt=zeros(4,length(InDir));

for j=1:length(InDir)
    
    cd(InDir{j});
    directory=dir;
    loopctr=1;
    size{j}=[];
    label{j}=[];
    CmpSiz{j}=[];
    for i=1:length(directory)
        ind=strfind(directory(i).name,'.mat');
        if ~isempty(ind)
            load(directory(i).name);
            Sinp=Diffmaps(Snew);
            Sinp=PartLabelCompSize(Sinp);
            NewCount=LabelCount(Sinp)';
            spec{loopctr}=[Sinp.eVenergy,sum(Sinp.PartSpec',1)'];
            OCspec{loopctr}=ExtractOCSpec(Sinp);
            LabelCnt(:,j)=LabelCnt(:,j)+NewCount;
            
            [class,siz]=ChemSiz(Sinp);
            size{j}=[size{j},siz];
            label{j}=[label{j},class];
            CmpSiz{j}=[CmpSiz{j};Sinp.CompSize];
            
            clear ind NewCount;
            loopctr=loopctr+1;
            clear siz;
            close all;
        end
    end
    OutSpec{j}=SumSpec(spec,length(label{j}));
    OutOCSpec{j}=SumSpec(OCspec,length(label{j}));
    clear spec;
end


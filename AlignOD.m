function AlignOD(P1Dir,FinDir)

%% This function loops through the first stage processed data directory
%% "P1Dir" and applies the image alignment and od conversion. The end data
%% structure is stored in the "FinDir"
%% Ryan C. Moffet 090311

cd(P1Dir)
numobj=length(dir);
for i = 3:numobj %% loops through stack matfiles
    foldstruct=dir;
    load(sprintf('%s',foldstruct(i).name));
    Snew=AlignStack(S);
    Snew=OdStack(Snew,'C');
    S
    cd(FinDir)
    save(sprintf('%s%s','F',foldstruct(i).name))
    cd(P1Dir);
end
cd(FinDir)
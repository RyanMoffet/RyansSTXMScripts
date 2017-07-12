function DeglitchDir(Dir,Degl)

cd(Dir);
directory=dir;

idxa=1;
for i=1:length(directory)
    ind=strfind(directory(i).name,'.mat');
    if ~isempty(ind) && idxa<=length(Degl)
        load(directory(i).name);
        if isempty(Degl{idxa})
            idxa=idxa+1
        else
            Snew=DeglitchStack(Snew,Degl{idxa});
            idxa=idxa+1;
            save(sprintf('%s',directory(i).name),'Snew')
        end
        clear ind;
    end
end

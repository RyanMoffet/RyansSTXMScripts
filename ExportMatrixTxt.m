function ExportMatrixTxt(Matrix,ColNames,Name,Path)

FileName = sprintf('%s%s',Path,Name);
FileNameText = [FileName '.xls'];
fid = fopen(FileNameText,'w');

for i=1:length(ColNames)
    fprintf(fid,'%s \t',ColNames{i});
    if i==length(ColNames)
        fprintf(fid,'\n');
    end
end
for j=1:length(Matrix(:,1))
    for k=1:length(Matrix(j,:))
        fprintf(fid,'%g \t',Matrix(j,k));
        if k==length(Matrix(j,:))
            fprintf(fid,'\n');
        end
    end
end

fclose(fid);
           
    
    
    

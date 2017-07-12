function ExportMatrixIgorNamedRows(Matrix,ColNames,RowNames,Name,Path)

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
    for k=1:length(Matrix(j,:))+1
        if k==1
            fprintf(fid,'%s \t',RowNames{j});
        else
            fprintf(fid,'%g \t',Matrix(j,k-1));
            if k==length(Matrix(j,:))+1
                fprintf(fid,'\n');
            end
        end
    end
end

fclose(fid);





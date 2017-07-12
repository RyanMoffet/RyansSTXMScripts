function ExportMatrixXls(Matrix,Name,Path)

FileName = sprintf('%s%s',Path,Name);
FileNameText = [FileName '.xls'];
% save(FileNameText,'Matrix', -ascii)
dlmwrite(FileNameText,Matrix,'delimiter','\t','precision', '%.2g');

           
    
    
    

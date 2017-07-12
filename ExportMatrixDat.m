function ExportMatrixDat(Matrix,Name,Path)

FileName = sprintf('%s%s',Path,Name);
FileNameText = [FileName '.dat'];
% save(FileNameText,'Matrix', -ascii)
dlmwrite(FileNameText,Matrix,'delimiter','\t','precision', '%.2e');

           
    
    
    

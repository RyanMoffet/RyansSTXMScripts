function S = LoadStack(filedir)

cd(filedir) %%'C:\RyanM_LBL\Milagro\Mar22Data\T0\532_080502059'

FileStruct=dir;

for i=1:length(FileStruct)
    stridx=findstr(FileStruct(i).name,'xim');
    if ~isempty(stridx)
        S.spectr(:,:,i)=load(FileStruct(i).name);
    end
end
function DirLabelS=RemoveBadParticles(DirLabelS)

%% this function will remove bad particles identified using the "explore particles" button
% or, really, CropPartRGBPlot.m

SNsToDelete=DirLabelS.ToDelete;
for i=1:length(DirLabelS.PartSize)
    [values,loginda,logindb]=intersect(DirLabelS.PartSN{i},SNsToDelete);
    DirLabelS.PartSize{i}(loginda)=[];
    DirLabelS.label{i}(loginda)=[];
    DirLabelS.CmpSiz{i}(loginda,:)=[];
    DirLabelS.SootCarbox{i}(loginda)=[];
    DirLabelS.TotalCarbon{i}(loginda)=[];
    DirLabelS.Carbox{i}(loginda)=[];
    DirLabelS.Sp2{i}(loginda)=[];
    DirLabelS.ImageProps{i}(loginda,:)=[];
    DirLabelS.PartSN{i}(loginda)=[];
    
    DirLabelS.CroppedParts{i}(loginda)=[];
    
    clear loginda logindb values
end
cd(DirLabelS.saveLoc)
save(sprintf('%sQC.mat',DirLabelS.FileName),'DirLabelS')
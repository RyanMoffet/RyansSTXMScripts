
%% first define where the data is -- you will need to changes these..
QcDir{1}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T0_100627\1027_hole2';
QcDir{2}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T0_100627\1227_hole8';
QcDir{3}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T0_100627\1247_hole9';
QcDir{4}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T0_100627\1307_hole10';
QcDir{5}='C:\Dropbox\Ryan_LBL\CARES\STXMData\RachelQCData\Full_RAW\T0_100627\1647_hole21';

%% second define where you want to store your results -- you will need to change these
mappath='C:\Dropbox\UniversityofthePacific\Research\Projects\CaresSoot\Results\'

%% Next create text strings that identify your samples -- you just need to run this
for i=1:length(QcDir)
    pos=strfind(QcDir{i},'\');
    sampleID{i}=sprintf('%s', QcDir{i}(pos(end)+1:end));
end

%% run DirLabelMapsStruct - this runs carbon maps for each file in the directories defined above. you should just need to run this.
[DirLabelS]=DirLabelMapsStruct(QcDir,sampleID,0,mappath,0.35)
cd(mappath)

%% you might want to name the results something else
save('151009QC')

%% This will generate big figure.
CropPartRGBPlot(DirLabelS.CroppedParts,DirLabelS.ImageProps,DirLabelS.PartDirs,DirLabelS.PartSN)


%% store particle SNs in a vector for later use
NSS=[1209300610003,1209300610011,1009130910018,1209300600002,1009130290005,1007250590001,1009130480004,1009130500002,1009130580004,...
    1009130720001,1009130740001,1009130840012,1207020150001,1207200450001,1209300910017,1209300910018,1209300910019,1307030870002,1209300600007,...
    1209300610005,1209300600006,1209300640002,1207220300006:1207220300015,1209300590001:1209300590022]'; 
[C,IA]=setdiff(DirLabelS.PartSN,NSS)
SSACroppedParts=DirLabelS.CroppedParts{IA}
function S = readBeam7dat(f)
q = num2str(f);
if q(1:2)=='90', q = strcat('00',q); end
[dirnm,basenm] = fileparts(q);

% Read data table
A = read_table('C:\Documents and Settings\takahama\My Documents\UCSD\projects\STXM\data\Filelog\beam7hdr.dat','\t',1);
for i = 1:length(A),
    q = num2str(A(i).StackName);
    if q(1:2)=='90', q = strcat('00',q); end
    A(i).StackName = q;
end
i = strmatch(basenm,{A.StackName});

% Number of Energies
Acell = struct2cell(A)';
energies = cell2mat(Acell(i,strmatch('Energy',fields(A))));
nE = length(find(~isnan(energies)));

% Return Structure
C = {A(i).PointsX, A(i).PointsY, A(i).StartX, A(i).StartX + A(i).PixelSizeX .* A(i).PointsX,...
    A(i).StartY, A(i).StartY + A(i).PixelSizeY .* A(i).PointsY, nE}';
S = cell2struct(C,{'nXpixels','nYpixels','minX','maxX','minY','maxY','nEnergies'},1);
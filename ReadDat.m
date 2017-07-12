function [evenergy,xvalue,yvalue]=ReadDat(file)

%% Read STXM .DAT file to extract energies and x and y pixel sizes
%% 081006 RCM

filestream = fopen(file, 'r');    %% Open file
firstline=str2num(fgets(filestream));  %% get first line
Nx=firstline(1);
Ny=firstline(2);
secondline=str2num(fgets(filestream));  %% get second line line
Xrange=secondline(2);
thirdline=str2num(fgets(filestream)); %% get third line
Yrange=thirdline(2);
Nen=str2num(fgets(filestream));  %% Skip fourth line
cnt2=1;
while cnt2<=Nen  %% get spectral data from file line by line
    jnkline=fgets(filestream);
%     if length(str2num(jnkline))>1
%         break
%     else
        evenergy(cnt2)=str2num(jnkline);
        cnt2=cnt2+1;
%     end
end
xvalue=Xrange;
yvalue=Yrange;
evenergy=evenergy';

fclose(filestream);
function [evenergy,xvalue,yvalue]=ReadHdr(file)

%% Read STXM .hdr file to extract energies and x and y pixel sizes
%% 081011 RCM

filestream = fopen(file, 'r');    %% Open file
cnt=1;
while feof(filestream) == 0
    line=fgets(filestream);
    energypos=findstr(line,'StackAxis');
    pos3=findstr(line,'; XRange =');
    
    if ~isempty(energypos)
        line=fgets(filestream);
        pos1=findstr(line,'(');
        pos2=findstr(line,')');
        energyvec=str2num(line(pos1+1:pos2-1));
        evenergy=energyvec(2:end)';
    elseif ~isempty(pos3)
        pos4=findstr(line,'; YRange =');
        pos5=findstr(line,'; XStep =');
        xvalue=str2num(line(pos3+10:pos4-1));
        yvalue=str2num(line(pos4+10:pos5-1));
    end
    
    clear line pos3;
    cnt=cnt+1;
end
fclose(filestream);

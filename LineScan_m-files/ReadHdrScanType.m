function type=ReadHdrScanType(file)

%% Read STXM .hdr file to extract energies and x and y pixel sizes
%% 081011 RCM

filestream = fopen(file, 'r');    %% Open file

while feof(filestream) == 0
    line=fgets(filestream);
    pos1=findstr(line,'Label =');

    if ~isempty(pos1)
        pos2=findstr(line,'; Type =');
        pos3=findstr(line,'; Flags =');
        type=line(pos2+10:pos3-2);
    end
    
    clear line pos1;
    
end
fclose(filestream);
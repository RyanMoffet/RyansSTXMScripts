function S = readAXISdat(filenm)
f = fopen(filenm,'r');
temp = fscanf(f,'%f',8); fclose(f);
temp(3) = [];
S = cell2struct(num2cell(temp),{'nXpixels','nYpixels','minX','maxX','minY','maxY','nEnergies'},1);
return
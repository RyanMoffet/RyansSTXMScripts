function S = read_bypix(directory,fname,badEn,Shift)
% S = read_bypix(directory,fname,badEn)
% Reads Binary file from IDL output
% Output is Data Structure of Maps

origdir = pwd;
try,
    cd(directory);
catch,
    cd(origdir);
    return
end

try,
    S = load(strcat(fname,'_spectra.mat'));
    fd = fields(S);
    S = S.(fd{1});
    try,
        S = rmfield(S,{'thres','aveSpec'});
    end
    if ~isempty(badEn),
        for i=1:length(badEn),
            clear b;
            [b{1:2}] = min(abs(S.eVenergy-badEn(i)));
            S.spectr(:,:,b{2}) = NaN;
        end
    end    
    cd(origdir);    
	return
end
    
% Pixels
pix = readAXISdat(strcat(directory,'\',fname,'.dat'));            

% Interpretation
nXPoints = pix.nXpixels;
nYPoints = pix.nYpixels;
nelem = pix.nXpixels*pix.nYpixels;
XValues = linspace(pix.minX,pix.maxX,pix.nXpixels)';
YValues = linspace(pix.minY,pix.maxY,pix.nYpixels)';
nEnergies = pix.nEnergies;

% Read IDL output
try,
	A = dlmread(strcat(fname,'_spectra.dat'));
	A(:,size(A,2)) = []; %dlmread adds extra column of zeroes in v6.5
	A = A';
	A = A(:);
	B = reshape(A,[],nEnergies);
	eVenergy = B(1,:)';
	B(1,:) = [];
	B(find(1:size(B,1) > nelem),:) = [];
catch,
    fid = fopen(strcat(fname,'_spectra.bin'));
    A = fread(fid,(nelem+1)*nEnergies,'float32');
    B = reshape(A,[],nEnergies);
    eVenergy = B(1,:)';
    B(1,:) = [];
end

%% 
if nargin < 4, Shift = 0;  end
eVenergy = eVenergy - Shift;
spectr = permute(reshape(B,nYPoints,nXPoints,nEnergies),[2,1,3]);

%% remove bad energies
if ~isempty(badEn),
    for i=1:length(badEn),
        clear b;
        [b{1:2}] = min(abs(eVenergy-badEn(i)));
        spectr(:,:,b{2}) = NaN;
    end
end


if min(eVenergy) < 500, % carbon
    %% background
    BG = mean(spectr(:,:,find(eVenergy > 278 & eVenergy < 283)),3);
    %% total map
    TotalMap = mean(spectr(:,:,find(eVenergy > 301 & eVenergy < 305)),3) - BG;
else % iron
    %% background
	arr = reshape(permute(spectr(:,:,find(eVenergy < 704)),[3,1,2]),...
        length(find(eVenergy < 704)),[]);
	if size(arr,1) > 1,
        arr = nanmean(arr);
    else
    	arr = reshape(permute(spectr(:,:,find(eVenergy < 705)),[3,1,2]),...
            length(find(eVenergy < 705)),[]);
        if size(arr,1) > 1, 
            arr = nanmean(arr);
        else
        	arr = reshape(permute(spectr(:,:,find(eVenergy < 706)),[3,1,2]),...
                length(find(eVenergy < 706)),[]);
            arr = nanmean(arr);
        end
    end
	BG = reshape(arr,size(spectr,1),size(spectr,2));
    %% total map
    ind = find(eVenergy >= 706 & eVenergy < 712 |...
        eVenergy >= 720 & eVenergy < 726);
	arr = reshape(permute(spectr(:,:,ind),[3,1,2]),length(ind),[]);
	if size(arr,1) > 1, arr = nanmean(arr); end
    TotalMap = reshape(arr,size(spectr,1),size(spectr,2)) - BG;
end

% Final Structure
S = struct('XValues',XValues,'YValues',YValues,'eVenergy',eVenergy,...
    'Bg',BG,'Total',TotalMap,'spectr',spectr);

% Change to original directory
cd(origdir);

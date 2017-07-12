function s = read_table(fid,sep,header,skip,nrow)
% arguments: fid, sep, header, nrow, skip
% fid can be provided as file name of value of fopen
% sep can be ' \t', '\n', ' ', ',', or regular expression
% header can be 0 (no header), 1 (header row at top), or
%   cell array of header names: e.g., {'col1','col2'}
% skip, number of rows to skip
% nrow, how many rows to read
% acceptable missing value string in a cell is NaN or ''
% version 0.95

%%%%%%%%%%%% Some variables %%%%%%%%%%%%
% r is number of rows of data
% fds is number of columns (fds) in each row
% listStruct is cell array that holds data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% File specification %%%%%%%%%%%%
if ~isnumeric(fid),
    fname = fid;
    fid = fopen(fname,'rt');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% Input argument specification %%%%%%%%%%%%
if nargin < 2
    sep = '\t';
end
if nargin < 4
    skip = -1;
end
if nargin < 5
    nrow = -1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% Delimiter Conversion %%%%%%%%%%%%
if isequal(sep,'\t'),
    delim = 9;
elseif isequal(sep,'\n'),
    delim = 10;
elseif isequal(sep,' '),
    delim = 32;
else,
    delim = sep;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% Read in data %%%%%%%%%%%%
if skip > -1,
    for i=1:skip, dummy = fgetl(fid); end
end
r = 0; x=0; fds = []; listStruct = {}; % initialize
while(x~=(-1));
    x = fgetl(fid);
    if isequal(x,-1), continue; end
    % add missing value if single blank spaces occur between delimiters... (not well tested)
    while(length(regexp(x,[sep sep])) > 0 &...
            (isnumeric(delim) | isequal(delim,',')) ),
        x = regexprep(x,[sep sep],[sep 'NaN' sep]);
    end
    % split by delimiters, regular expressions can be used
    tempString = x; d = delim; y = {};
    while (length(tempString) > 0)
        if ~isnumber(delim),
            [st,fin] = regexp(tempString,delim);
            d = tempString(st:fin);
        end
        [tok,tempString] = strtok(tempString,d);
        y = {y{:}, tok};
    end
    listStruct = {listStruct{:}, y};
    fds = [fds length(y)];
    r=r+1;
    if( nrow > -1 & r > nrow ), x = -1; end
end
fds(length(fds)) = []; % Number of columns (fields)
%r = r-1; % Number of rows
%listStruct(length(listStruct)) = []; % Each row of data stored as a cell array
frewind(fid);
try, isnull(fname); fclose(fid); end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% Determine header %%%%%%%%%%%%
if nargin < 3 | isequal(header,1), % Default is to have header
    hdrnms = listStruct{1};
    listStruct(1) = [];
    r = r-1;
else
    if iscell(header), % User-specified header names
        hdrnms = header;
    else % Generic header names
        hdrnms = strcat(repmat('V',max(fds),1),num2str([1:max(fds)]'));
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% Full cell array %%%%%%%%%%%%
for i = 1:r,
    try, % pad end of rows with NaN
        listStruct{i}( (length(listStruct{i})+1):max(fds) ) = 'NaN';
    catch,
        if length(listStruct{i}) < max(fds),
            listStruct{i} = [listStruct{i},cellstr(repmat('NaN',max(fds)-length(listStruct{i}),1))'];
        end
    end
end
listStruct = reshape([listStruct{:}],max(fds),r)';
for j = 1:max(fds),
    missing = strmatch('NaN',listStruct(:,j),'exact');
    listStruct(missing,j) = regexprep(listStruct(missing,j),'^NaN$','');   
    elems = 1:r; elems(missing) = [];
    if isempty(elems),
        listStruct(:,j) = num2cell(str2double(listStruct(:,j)));
        continue;
    end
    if all(~isnan(str2double(listStruct(elems,j)))),
        listStruct(:,j) = num2cell(str2double(listStruct(:,j)));
    end
end

%%%%%%%%%%%% Create structure %%%%%%%%%%%%
try
    hdrnms = regexprep(hdrnms,'\W+',''); % removes whitespace
    s = cell2struct(listStruct,hdrnms,2);
catch
    hdrnms = strcat(repmat('V',max(fds),1),strjust(num2str([1:max(fds)]'),'left'));    
    s = cell2struct(listStruct,hdrnms,2);
end

try,
    fname;
    fclose(fid);
end
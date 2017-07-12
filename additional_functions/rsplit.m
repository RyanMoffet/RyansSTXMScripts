function slist = rsplit(X,f)
% rsplit(X,f)
% X is cell, struct, or vector
% f is cell or numeric vector

nms = unique(f);
if isequal(class(nms),'double'),
    nms = mapfun(@num2str,num2cell(nms));
    f = mapfun(@num2str,num2cell(f));
end
slist = {};
for i=1:length(nms);
    if strmatch('struct',class(X)) | strmatch('cell',class(X)),
        slist{i} = X(strmatch(nms{i},f,'exact'));
    elseif strmatch('double',class(X)),
        if all(size(X) > 1),
            slist{i} = X(strmatch(nms{i},f,'exact'),:);
        else 
            slist{i} = X(strmatch(nms{i},f,'exact'));
        end
    end
end

slist = struct('group',nms','data',slist');
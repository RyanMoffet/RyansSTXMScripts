function retval = getElem(obj,fun,i)
% function retval = getElem(obj,fun,i)

if ~isequal('cell',class(obj)),
    obj = {obj};
end
[c{1:i}] = feval(fun,obj{:});
retval = c{i};

return

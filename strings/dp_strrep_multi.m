function strout = dp_strrep_multi(str, old, new)

if ischar(old)
    old = {old};
end

if ischar(new)
    new = {new};
end

if ischar(str)
    str = {str};
end

for si = 1:length(str)
    for i = 1:numel(old)
        strout{si} = strrep(str{si}, old{i}, new{i});
    end
end

if length(str) == 1
    strout = strout{1};
end
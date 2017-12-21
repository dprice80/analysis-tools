function pc = calcpc(nulldist, lzr)

N = length(nulldist);
loc = find(lzr >= sort(nulldist), 1, 'last');
if isempty(loc)
    pc = 1/N;
elseif loc ~= N
    pc = loc/N;
else
    pc = 1-(1/N); % can't have 100th percentiles in here (which cannot be converted to a z score)
end
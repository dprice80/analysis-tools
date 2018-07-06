function [pc, p, z] = dp_calc_percentile(nulldist, x, tail, reduce)
% nulldist = null distribution from randomisation stage (phase
% randomsiation, permutations, monte-carlo)
% x = real values on which statistics should be performed 
% tail: 'twotailed', or 'onetailed'. default = 'onetailed'. 
% This affects the p value only.
% Use reduce to reduce to speed up the algorithm at the expense of accuracy
% Setting reduce to less than numel(x) causes round off of x. Calculations
% are then performed on unique values of x and indexed back into output
% variables before returning.

nulldist = nulldist(:);

if nargin < 4
    reduce = false;
end

if nargin < 3
    tail = 'onetailed';
end

N  = length(nulldist);

if reduce ~= false
    szx = size(x);
    xmin = min(x(:));
    xmax = max(x(:));
    x = round(x/reduce)*reduce; % round off
    [x, ~, iB] = unique(x);
end

pc = zeros(size(x));
p  = pc;
nulldist = sort(nulldist);

Nel = numel(x);

for ii = 1:Nel
    printProgress(ii, Nel, false, 'Percentiles')
    
    loc = find(x(ii) >= nulldist, 1, 'last');
    
    if isempty(loc)
        pc(ii) = 1/N;
    elseif loc ~= N
        pc(ii) = loc/N;
    else
        pc(ii) = 1-(1/N); % can't have 100th percentiles in here (which cannot be converted to a z score)
    end
    
    switch tail
        case 'twotailed'
            % Calculate p value of result
            p(ii) = 1-abs(pc(ii)-0.5)*2;
        case 'onetailed'
            p(ii) = 1-pc(ii);
        otherwise
            error('tail should be either ''onetailed'' or ''twotailed''')
    end
end

% Calculate Z scores based on percentiles.
if nargout == 3
    if exist('norminv', 'file')
        z = norminv(pc, 0, 1);
    end
end

if reduce ~= false
    pco = zeros(szx);
    po = zeros(szx);
    zo = zeros(szx);
    pco(:) = pc(iB);
    po(:) = p(iB);
    zo(:) = z(iB);
    pc = pco;
    p = po;
    z = zo;
end
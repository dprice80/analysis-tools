function [pc, p, z] = dp_calc_percentile(nulldist, x, tail)

if nargin == 2
    tail = 'onetailed';
end

N = length(nulldist);

pc = zeros(size(x));
p = pc;

% q = quantile(nulldist, 0.5);

for ii = 1:length(x)
    
%     switch tail
%         case 'onetailed'
            loc = find(x(ii) >= sort(nulldist), 1, 'last');
%         case 'twotailed'
%             if x(ii) < q % need to treat lower and upper half of null dist differently
%                 loc = find(x(ii) <= sort(nulldist), 1, 'first');
%             else
%                 loc = find(x(ii) >= sort(nulldist), 1, 'last');
%             end
%     end
    
    if isempty(loc)
        pc(ii) = 1/N;
    elseif loc ~= N
        pc(ii) = loc/N;
    else
        pc(ii) = 1-(1/N); % can't have 100th percentiles in here (which cannot be converted to a z score)
    end
    
    switch tail
        case 'twotailed'
            pc2t = abs(pc(ii)-0.5)*2;
            % Calculate p value of result
            p(ii) = 1-(pc2t);
        case 'onetailed'
            p(ii) = 1-pc(ii);
        otherwise
            error('tail should be either ''onetailed'' or ''twotailed''')
    end
end

if exist('norminv', 'file')
    z = norminv(pc, 0, 1);
end
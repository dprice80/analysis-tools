function [] = printRepLine(l, len, del)
% Print line, replacing the previously printed line
% l = text string
% len = maximum length (this number of characters is removed each time)
% del = delete previous line. When del is either numeric 1 or false, the
% previous is not deleted.
% Darren Price 2017

if nargin == 2
    del = true;
end

if (islogical(del) && del == true) || del > 1
    fprintf(1, repmat('\b',1,len+1));
end

% Pad l
ll = length(l);
if ll < len
    l(len) = ' ';
else
    l = l(1:len);
end

fprintf(1,'%s\n', l);
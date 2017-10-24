function [varargout] = dp_removeoutliers(varargin)
% [x] = dp_removeoutliers(x)
% For 2D matrices will remove all columns if one outlier exists in column
x = [];
for vi = 1:length(varargin)
    x = [x varargin{vi}];
end

x = shiftdim(x);

for oli = 1:size(x,2)
    [OLlo(oli), OLhi(oli), x(:,oli)] = dp_findoutliers(x(:,oli));
end

[xc, ind] = complete(x);
ind = ind == 0;
x(ind,:) = NaN;

for vi = 1:length(varargin)
    varargout{vi} = x(:,vi);
end
varargout{end+1} = ind;

varargout{end+1} = OLlo;

varargout{end+1} = OLhi;


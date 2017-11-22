function [varargout] = dp_complete_nan(varargin)

c = [];
for ii = 1:length(varargin)
    c = [c varargin{ii}];
end

a = all(~isnan(c),2);
for ii = 1:length(varargin)
    varargout{1,ii} = varargin{1,ii};
    varargout{1,ii}(~a,:) = NaN;
end

varargout{1,ii+1} = a;
function [varargout] = complete_detrend(varargin)

c = [];
for ii = 1:length(varargin)
    c = [c varargin{ii}];
end

a = all(~isnan(c),2);
for ii = 1:length(varargin)
    varargout{1,ii} = varargin{1,ii}(a);
    varargout{1,ii} = detrend(varargout{1,ii},0);
end

varargout{1,ii+1} = a;

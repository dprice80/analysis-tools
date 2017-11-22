function [lzdiffreal, lzdiffnull_sorted, pval, pc_diff, pc_data1, pc_data2, lz1, lz2] = dp_lz_stats(data1, data2, N)
% [lzdiffreal, lzdiffnull, p, pc] = dp_lz_stats(data1, data2, N)
% 
% INPUT
% data1/2 should be 1D numeric array e.g. 1 x N samples
% N = number of surrogate datasets
%
% EXAMPLE USAGE
% data1 = rand(1,10000);
% data2 = rand(1,10000);
% Generate datasets with different frequency densities
% data1 = ft_preproc_bandpassfilter(data1, 1000, [10 20]); 
% data2 = ft_preproc_bandpassfilter(data2, 1000, [15 30]);
% 
% [lzdiffreal, lzdiffnull_sorted, pval, pc_diff, pc_data1, pc_data2, lz1, lz2] = dp_lz_stats(data1, data2, 1000);
% 
% figure
% histogram(lzdiffnull_sorted)
% line([lzdiffreal lzdiffreal], [0 300])
% 
% figure
% l=lzwnormalised(sprintf('%d',heaviside(zscore(abs(hilbert(data1))))),0)
% histogram(lz1)
% line([l l], [0 300],'Color','r')
% 
% figure
% l=lzwnormalised(sprintf('%d',heaviside(zscore(abs(hilbert(data2))))),0)
% histogram(lz2)
% line([l l], [0 300],'Color','r')


% Get data lengths
N1 = length(data1);
N2 = length(data2);

% Make lengths even (for phase rand script)
data1 = data1(1:floor(N1/2)*2);
data2 = data2(1:floor(N2/2)*2);

% Null distribution
lzdiffnull = zeros(1,N);

lz1r = lzwnormalised(sprintf('%d', heaviside(zscore(abs(hilbert(data1))))),0);
lz2r = lzwnormalised(sprintf('%d', heaviside(zscore(abs(hilbert(data2))))),0);

lzdiffreal = lz2r - lz1r;

lz1 = zeros(1,N);
lz2 = zeros(1,N);

for ii = 1:N
    
    data1p = sprintf('%d', heaviside(zscore(abs(hilbert(dp_phaserand_surrogate(data1,0))))));
    data2p = sprintf('%d', heaviside(zscore(abs(hilbert(dp_phaserand_surrogate(data2,0))))));
    
    lz1(ii) = lzwnormalised(data1p,0);
    lz2(ii) = lzwnormalised(data2p,0);
    lzdiffnull(ii) = lz2(ii) - lz1(ii);
end

% sort null distribution
lzdiffnull_sorted = sort(lzdiffnull);

% Calculate P value
loc = find(abs(lzdiffreal) > abs(lzdiffnull_sorted), 1, 'last');

if isempty(loc)
    pval = 1;
else
    pval = 1-(loc/N);
end

% Calculate percentiles

pc_diff = calcpc(lzdiffnull_sorted, lzdiffreal);
pc_data1 = calcpc(lz1, lz1r);
pc_data2 = calcpc(lz2, lz2r);

    function pc = calcpc(nulldist, lzr)
        N = length(nulldist);
        loc = find(lzr >= sort(nulldist), 1, 'last');
        if isempty(loc)
            pc = 0;
        else
            pc = loc/N;
        end
    end
end
function [lzdiffreal, lzdiffnull_sorted, pval, pc, lz1, lz2] = dp_lz_stats(data1, data2, N)
% [lzdiffreal, lzdiffnull, p, pc] = dp_lz_stats(data1, data2, N)

% Get data lengths
N1 = length(data1);
N2 = length(data2);

% Make lengths even (for phase rand script)
data1 = data1(1:floor(N1/2)*2);
data2 = data2(1:floor(N2/2)*2);

% Null distribution
lzdiffnull = zeros(1,N);

lz1 = lzwnormalised(sprintf('%d', heaviside(zscore(abs(hilbert(data1))))),0);
lz2 = lzwnormalised(sprintf('%d', heaviside(zscore(abs(hilbert(data2))))),0);

lzdiffreal = lz2 - lz1;

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

% Calculate percentile
loc = find(lzdiffreal > lzdiffnull_sorted, 1, 'last');
if isempty(loc)
    pc = 0;
else
    pc = loc/N;
end


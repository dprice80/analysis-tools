clear all
close all
clc

% Run a simulation from Complexity meeting talk (November 2017)

% Create two random datasets with varying frequency profiles
% Filter, then run through a first pass of phase randomisation

data1 = ft_preproc_bandpassfilter(rand(1,10000), 1000, [10 20]);
data2 = ft_preproc_bandpassfilter(rand(1,10000), 1000, [15 30]);

% Run dp_lz_stats.m
[lzdiffreal, lzdiffnull_sorted, pval, pc_diff, pc_data1, pc_data2, lz1, lz2] = dp_lz_stats(data1, data2, 1000);

% Plot results
figure
histogram(lzdiffnull_sorted)
line([lzdiffreal lzdiffreal], [0 300])

figure
l=lzwnormalised(sprintf('%d',heaviside(zscore(abs(hilbert(data1))))),0);
histogram(lz1)
line([l l], [0 300],'Color','r')

figure
l=lzwnormalised(sprintf('%d',heaviside(zscore(abs(hilbert(data2))))),0);
histogram(lz2)
line([l l], [0 300],'Color','r')



%% Test whether percentiles are biased (same freq bands) (they should be normally distributed over multiple simulated subjects).

clear pc_diff
parfor subi = 1:1000
    disp(subi)
    data1 = ft_preproc_bandpassfilter(rand(1,10000), 1000, [10 20]);
    data2 = ft_preproc_bandpassfilter(rand(1,10000), 1000, [10 20]);
    
    % Run dp_lz_stats.m
    [lzdiffreal, lzdiffnull_sorted, pval, pc_diff(subi), pc_data1, pc_data2, lz1, lz2] = dp_lz_stats(data1, data2, 100);
end

histogram(pc_diff)

data1r = dp_phaserand_surrogate(data1);

figure
plot(abs(fft(data1r)),'b')
hold on
plot(abs(fft(data1)),'r--')
hold off

%% Same as above, with different frequency bands

clear pc_diff
parfor subi = 1:1000
    disp(subi)
    data1 = ft_preproc_bandpassfilter(rand(1,1000), 100, [10 20]);
    data2 = ft_preproc_bandpassfilter(rand(1,1000), 100, [20 40]);
    
    % Run dp_lz_stats.m
    [lzdiffreal, lzdiffnull_sorted, pval, pc_diff(subi), pc_data1, pc_data2, lz1, lz2] = dp_lz_stats(data1, data2, 100);
end

histogram(pc_diff)


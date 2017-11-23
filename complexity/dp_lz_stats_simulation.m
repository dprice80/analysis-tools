clear all
close all
clc

% Run a simulation from Complexity meeting talk (November 2017)

data1 = rand(1,10000);
data2 = rand(1,10000);

data1 = ft_preproc_bandpassfilter(data1, 1000, [10 20]);
data2 = ft_preproc_bandpassfilter(data2, 1000, [15 30]);

[lzdiffreal, lzdiffnull_sorted, pval, pc_diff, pc_data1, pc_data2, lz1, lz2] = dp_lz_stats(data1, data2, 1000);

figure
histogram(lzdiffnull_sorted)
line([lzdiffreal lzdiffreal], [0 300])

figure
l=lzwnormalised(sprintf('%d',heaviside(zscore(abs(hilbert(data1))))),0)
histogram(lz1)
line([l l], [0 300],'Color','r')

figure
l=lzwnormalised(sprintf('%d',heaviside(zscore(abs(hilbert(data2))))),0)
histogram(lz2)
line([l l], [0 300],'Color','r')
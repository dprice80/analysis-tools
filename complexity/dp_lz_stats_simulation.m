clear all
close all
clc

addpath(genpath('/imaging/dp01/toolboxes/analysis-tools-git/'))


%% Test phase randomisation script
data1 = ft_preproc_bandpassfilter(rand(1,1000001), 1000, [10 20])';
data1r = dp_phaserand_surrogate(data1);

% Amplitudes of both signals should be identical (before/after phase rand)
figure
plot(smooth(abs(fft(data1r)),100),'b')
hold on
plot(smooth(abs(fft(data1)),100),'r--')
hold off

% Correlation should be close to 1. Some numerical imprecision is to be
% expected here.
if (1-corr(abs(fft(data1r)), abs(fft(data1)))) > 1e-8
    disp('dp_phaserand_surrogate: FAILED')
else
    disp('dp_phaserand_surrogate: PASSED')
end


%% Run a simulation from Complexity meeting talk (November 2017)

% Create two random datasets with varying frequency profiles
% Filter, then run through a first pass of phase randomisation

data1 = ft_preproc_bandpassfilter(rand(1,10000), 1000, [10 20]);
data2 = ft_preproc_bandpassfilter(rand(1,10000), 1000, [15 30]);

% Run dp_lz_stats.m
[lzdiffreal, lzdiffnull_sorted, pval, z_diff, pc_data1, pc_data2, lz1, lz2] = dp_lz_stats(data1, data2, 1000);

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


%% Check distributions of outputs (same freq bands).

dp_matlabpool_start(50)

clear pc_* z_*
parfor subi = 1:250
    disp(subi)
    data1 = dp_phaserand_surrogate(ft_preproc_bandpassfilter(randn(1,1001), 250, [10 20]));
    data2 = dp_phaserand_surrogate(ft_preproc_bandpassfilter(randn(1,1001), 250, [10 20]));
    
    % Run dp_lz_stats.m
    [lzdiffreal, lzdiffnull_sorted, pval, pc_diff(subi), pc_data1(subi), pc_data2(subi), lz1, lz2] = dp_lz_stats(data1, data2, 1000);
end

close all
figure
histogram(norminv(pc_data1))
figure
histogram(norminv(pc_data2))
figure
histogram(norminv(pc_diff))


%% Check distributions of outputs (different freq bands)

clear pc_* z_*
parfor subi = 1:250
    disp(subi)
    data1 = (ft_preproc_bandpassfilter(randn(1,1001), 250, [10 20]));
    data2 = (ft_preproc_bandpassfilter(randn(1,2001), 250, [15 25]));
    % Run dp_lz_stats.m
    [lzdiffreal, lzdiffnull_sorted, pval, pc_diff(subi), pc_data1(subi), pc_data2(subi), lz1, lz2] = dp_lz_stats(data1, data2, 1000);
end

close all
figure
histogram(norminv(pc_data1))
figure
histogram(norminv(pc_data2))
figure
histogram(norminv(pc_diff))

figure
dp_plot_cdf(norminv(pc_diff)')

figure
dp_plot_cdf(norminv(pc_data1)')

figure
dp_plot_cdf(norminv(pc_data2)')

addpath(genpath('/imaging/dp01/toolboxes/analysis-tools-git/'))

% Set up simulation constants
Lt = 120;
fs = 1000;
L = Lt*fs;
t = linspace(0,Lt,Lt*fs);
scaling2 = 1.4; % how much to scale segment 2

x1 = randn(1,fs*Lt);
x2 = randn(1,fs*Lt);
% Sum together 
% Need fieldtrip on path
x12(1,:) = ft_preproc_bandpassfilter([x1 x2], fs, [1 4], 4, 'but', 'onepass', 'reduce'); % filter data using fieldtrip (recommended)
x12(2,:) = ft_preproc_bandpassfilter([x1 x2], fs, [4 8], 4, 'but', 'onepass', 'reduce'); % filter data using fieldtrip (recommended)
x12(3,:) = ft_preproc_bandpassfilter([x1 x2], fs, [8 13], 4, 'but', 'onepass', 'reduce'); % filter data using fieldtrip (recommended)
x12(4,:) = ft_preproc_bandpassfilter([x1 x2], fs, [13 30], 4, 'but', 'onepass', 'reduce'); % filter data using fieldtrip (recommended)

x12(3, L/2+1:end) = x12(3, L/2+1:end)*scaling2; % scale seg 2 alpha
x12 = sum(x12);
x12 = ft_preproc_bandpassfilter(x12, fs, [8 13], 4, 'but', 'onepass', 'reduce');

hold on
plot(x12)

x12h = abs(hilbert(x12));
a1 = mean(x12h(1:L/2)); % first half 
a2 = mean(x12h(L/2+1:L)); % second half

Nrand = 10000;

a1r = zeros(1,Nrand);
a2r = zeros(1,Nrand);

for ii = 1:Nrand
    printProgress(ii, Nrand)
    x12r = dp_phaserand_surrogate(x12', false, true);
    x12h = abs(x12r);
    a1r(ii) = mean(x12h(1:L/2)); % first half
    a2r(ii) = mean(x12h(L/2+1:L)); % second half
end

adr = a2r./a1r;

%
close all
histogram(adr)

ad = a2/a1;

adrs = sort(adr);

% Calculate percentile and p value
[pc, p] = dp_calc_percentile(adrs, ad, 'twotailed');

% Calculate p value thresholds
% Upper threshold is easy (but we need to make 2 tailed by dividing by two)
pthresh_upper = quantile(adr, [1-0.05/2 1-0.01/2 1-0.001/2])

% Lower threshold is the inverse of the upper threshold
pthresh_lower = quantile(adr, [0.05/2 0.01/2 0.001/2])

hold on 
ylim = get(gca, 'YLim');
th = [pthresh_upper pthresh_lower];
line([th; th], repmat(ylim,6,1)')

% We can verify that these tally with the calculation of p values 
% pv should be [0.05 0.01 0.001] in both cases
% pcv should be [0.9750 0.9950 0.9995] or [0.0250 0.0050 0.0005]
% z should be +/-[1.9600 2.5758 3.2905]
[pcv, pv, z] = dp_calc_percentile(adrs, pthresh_upper, 'twotailed')

[pcv, pv, z] = dp_calc_percentile(adrs, pthresh_lower, 'twotailed')





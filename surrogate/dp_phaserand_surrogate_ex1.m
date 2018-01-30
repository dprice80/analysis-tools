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

Nrand = 1000;

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
%%
close all
histogram(adr)

ad = a2/a1;

adrs = sort(adr);

% Calculate percentile of real result
pc = find(adrs >= ad, 1, 'first')/Nrand;

% Need to take care of cases where real value is beyond the simulation.
if isempty(pc)
    pc = (Nrand-1)./Nrand;
end

pc2t = abs(pc-0.5)*2

% Calculate p value of result
pval2t = 1-(pc2t)

% Calculate p value thresholds
% Upper threshold is easy (but we need to make 2 tailed by dividing by two)
pthresh_upper = quantile(adr, [1-0.05/2 1-0.01/2 1-0.001/2])

% Lower threshold is the inverse of the upper threshold
pthresh_lower = 1./pthresh_upper








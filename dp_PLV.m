function [PLV] = dp_PLV(trials1,trials2)
% trials1 trials2 are time x trials matrices with same number of time
% points and trials.

Ntrials = size(trials1,2);

trials1 = hilbert(trials1);
trials2 = hilbert(trials2);

angles1 = angle(trials1);
angles2 = angle(trials2);

trdiff = angles1-angles2;
trdiff = unwrap(trdiff,[],2);

PLV = abs(mean(exp(1i*(trdiff)), 2));




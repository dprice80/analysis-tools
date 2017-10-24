function [OLlo, OLhi, x] = dp_findoutliers(x)

Q1 = quantile(x,0.25);
Q3 = quantile(x,0.75);

IQR = Q3-Q1;
IQROL = IQR*1.5;

OLlo = Q1-IQROL;
OLhi = Q3+IQROL;

x(x < OLlo | x > OLhi) = NaN;
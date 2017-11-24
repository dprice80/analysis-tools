function [] = dp_plot_cdf(x)

x = zscore(x);
[f,x_values] = ecdf(x);
F = plot(x_values,f);
set(F,'LineWidth',2);
hold on;
G = plot(x_values,normcdf(x_values,0,1),'r-');
set(G,'LineWidth',2);
legend([F G],...
       'Empirical CDF','Standard Normal CDF',...
       'Location','SE');
hold off

[h, p, ks] = kstest(x_values);

if p < 1e-3
    title(sprintf('KS Test ks=%f, h=%d, p=%e',ks, h, p))
else
    title(sprintf('KS Test ks=%f, h=%d, p=%2.3f',ks, h, p))
end
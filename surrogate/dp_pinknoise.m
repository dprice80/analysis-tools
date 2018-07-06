function pn = dp_pinknoise (Nt,Nc,fe) 

if nargin < 3
    fe = 1;
end

if nargin < 2
    Nc = 1;
end

if rem(Nt, 2)
    Nt = Nt-1;
end

e = exp(-1i*rand(Nc,Nt)*2*pi);
f = repmat([1./(1:Nt/2).^fe zeros(1, Nt/2)], Nc, 1);
pn = real(ifft(e'.*f'));
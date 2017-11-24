function data = dp_phaserand_surrogate(data, equalphase)
% data = array: [time, channels]
% equalphase boolean: [true | false] Do you want the same phase shift in
% each channel? (to maintain the covariance matrix) default = true). This
% has no effect on single channel randomisation
% Dont forget to set your random seed if you want repeatable results

if nargin == 1
    equalphase = true;
end

data = shiftdim(data);

L = size(data, 1);

if mod(L,2) == 0
   error('size(data,1) should be odd')
end

data = fft(data);

if equalphase == true
    randphase = generate_shifts(L);
end

for ii = 1:size(data,2)
    if equalphase == false
        randphase = generate_shifts(L);
    end
    data(:,ii) = real(ifft(data(:,ii).*randphase));
end

    function rp = generate_shifts(L)
        r = exp(1i*randn(1,(L-1)/2)*2*pi);
        rp = [0 r conj(r(end:-1:1))]';
    end
end
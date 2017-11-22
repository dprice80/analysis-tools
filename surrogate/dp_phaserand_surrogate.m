function data = dp_phaserand_surrogate(data, equalphase)
% data = array: [time, channels]
% equalphase boolean: [true | false] (do you want the same phase shift in
% each channel? default = true)
% Dont forget to set your random seed

if nargin == 1
    equalphase = true;
end

data = shiftdim(data);

L = size(data, 1);

data = fft(data)*2;
data(L/2+1:end, :) = 0;
randphase = exp(1i*randn(1,L)*2*pi)'; % uses the same phase for each channel

for ii = 1:size(data,2)
    if equalphase == false
        randphase = exp(1i*rand(L,1)*2*pi);
    end
    data(:,ii) = real(ifft(data(:,ii).*randphase));
end




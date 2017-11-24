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

if mod(size(data,1),2) == 0
    % Add the first point to the end. If the data is periodic, this should
    % be the correct extrapolation
    clipdata = true;
    data(end+1,:) = data(1,:);
else
    clipdata = false;
end

L = size(data, 1);

data = fft(data);
% data(L/2+1:end, :) = 0;

if equalphase == true
    randphase = generate_shifts(L);
end

for ii = 1:size(data,2)
    if equalphase == false
        randphase = generate_shifts(L);
    end
    data(:,ii) = real(ifft(data(:,ii).*randphase));
end

if clipdata
    data = data(1:end-1,:);
end

    function rp = generate_shifts(L)
        r = exp(1i*randn(1,(L-1)/2)*2*pi); % uses the same phase for each channel
        rp = [0 r conj(r((L-1)/2:-1:1))]';
    end
end
function data = dp_phaserand_surrogate(data, equalphase)
% data = array: [time, channels]
% equalphase boolean: [true | false] Do you want the same phase shift in
% each channel? (to maintain the covariance matrix) default = true). This
% has no effect on single channel randomisation
% Dont forget to set your random seed if you want repeatable results
% Based on Prichard and Theiler (1994) https://doi.org/10.1103/PhysRevLett.73.951
% Darren Price, CBU, University of Cambridge (2017)

if nargin == 1
    equalphase = true;
end

data = shiftdim(data);

L = size(data, 1);

data = fft(data);

if equalphase == true
    randphase = generate_shifts(L);
end

for ii = 1:size(data,2)
    if equalphase == false
        randphase = generate_shifts(L);
    end
    data(:,ii) = (ifft(data(:,ii).*randphase));
end

    function rp = generate_shifts(L)
        if mod(L,2) == 1
            r = exp(1i*rand(1,(L-1)/2)*2*pi);
            % First value should be 1 to allow a baseline. Second half is
            % reversed complex conjugate of the first half.
            rp = [1+0i r conj(r(end:-1:1))]';
        else
            r = exp(-1i.*rand(1,L/2)*2*pi);
            % Last half has 1 extra value, so last half needs to be added
            % to the first, then set the first value to 1
            rp = [conj(r(L/2:-1:1)) r]';
            rp(1) = 1 + 0i;
        end
    end
end

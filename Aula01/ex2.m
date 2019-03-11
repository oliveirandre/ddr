% 2.a)
bits = 100*8;
p = 10^-2;
a = (1 - p)^bits * 100

% 2.b)
bits = 1000*8;
p = 10^-3;
frac = bits; % fatorial(bits)/fatorial(1)*(fatorial(bits-1)) = fatorial(bits)/1*fatorial(bits-1) = bits
b = frac * p * (1 - p)^(bits-1) * 100

% 2.c)
bits = 200*8;
p = 10^-4;
c = (1 - ((1 - p)^bits)) * 100

% 2.d)
figure
x

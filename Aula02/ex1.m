% GRUPO 4 P 1

% 1.a)
data = 64 * 8;
p = [0.99, 0.999, 0.9999, 0.99999];
bern = 10^-7;
beri = 10^-3;

% p(e|n) - probabilidade de haver um erro quando está em estado normal
pen = 1 - ((1 - bern)^data);

% p(e|i) - probabilidade de haver um erro em estado interferência
pei = 1 - ((1 - beri)^data);

% p(n|e) = p(e|n)*p(n) / ((p(e|n)*p(n)) + (p(e|i)*p(i)))
pne = pen * p./((pen * p) + (pei * (1 - p)))

% p(n|i) = p(i|n)*p(n) / ((p(i|n)*p(n)) + (p(e|n)*p(n)))
pie = pei * (1 - p)./((pei * (1 - p) + (pen * p)))

%             | normal | interferencia |
% p = 99%     | 0.0125 |     0.9875    |
% p = 99.9%   | 0.1132 |     0.8868    |
% p = 99.99%  | 0.5608 |     0.4392    |
% p = 99.999% | 0.9274 |     0.0726    |

% -> conclusão : p(n|e) + p(i|e) = 1
% -> quanto maior for a probabilidade de estarmos no estado normal, menor é
% a probabilidade de estarmos em interferência quando ocorre um erro. Por
% haver menos probabilidade de estarmos em estado de interferência?

%--------------------------------------------------------------------------

% 1.b)
% fp = pen^n*p / ((pen^n*p) + (pei^n*(1-p)))
n = [2, 3, 4, 5];
for k = 1:numel(p) 
    for i = 1:numel(n)
        "p = " + p(k) + "; n = " + n(i) + "; res = " + pen ^ n(i) * p(k) / ((pen ^ n(i) * p(k)) + (pei ^ n(i) * (1 - p(k))))
    end
end

%             |     2      |      3     |      4     |      5     |
% p = 99%     | 1.6150e-06 | 2.0627e-10 | 2.6346e-14 | 3.3659e-18 |
% p = 99.9%   | 1.6297e-05 | 2.0815e-09 | 2.6585e-13 | 3.3955e-17 |
% p = 99.99%  | 1.6309e-04 | 2.0834e-08 | 2.6609e-12 | 3.3986e-16 |
% p = 99.999% | 1.6286e-03 | 2.0835e-07 | 2.6612e-11 | 3.3989e-15 |

%--------------------------------------------------------------------------

% 1.c)
% fn = (1-pei)^n*(1-p) / (((1-pei)^n*(1-p)) + ((1-pen)^n*p
for k = 1:numel(p)
    for i = 1:numel(n)
        "p = " + p(k) + "; n = " + n(i) + "; res = " + (1 - pei^n(i)) * (1-p(k))./(((1-pei^n(i)) * (1-p(k))) + ((1-pen^n(i)) * p(k)))
    end
end

%             |     2      |      3     |      4     |      5     |
% p = 99%     | 8.4066e-03 | 9.3619e-03 | 9.7443e-03 | 9.8975e-03 |
% p = 99.9%   | 8.3945e-04 | 9.3565e-04 | 9.7420e-04 | 9.8966e-04 |
% p = 99.99%  | 8.3933e-05 | 9.3559e-05 | 9.7418e-05 | 9.8965e-05 |
% p = 99.999% | 8.3931e-06 | 9.3559e-06 | 9.7418e-06 | 9.8965e-06 |


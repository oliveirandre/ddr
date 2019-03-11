%% 2.a)
pi0 = 1/(1 + (1*5*10*10)/(5*20*40*195))
pi1 = (1/195)*pi0
pi2 = ((1*5)/(40*195))*pi0
pi3 = ((1*5*10)/(20*40*195))*pi0
pi4 = ((1*5*10*10)/(5*20*40*195))*pi0

% pi0 = 0.9994
% pi1 = 5.1000e-03
% pi2 = 6.4061e-04
% pi3 = 3.2031e-04
% pi4 = 6.4061e-04 

%% 2.b)
% T = 1/qi && qi = soma qij até j

t0 = 1/1 * 60
t1 = 1/(5+195) * 60
t2 = 1/(10+40) * 60
t3 = 1/(10+20) * 60
t4 = 1/5 * 60

% t0 - 60 minutos
% t1 - 0.3 minutos
% t2 - 1.2 minutos
% t3 - 2 minutos
% t4 - 12 minutos

%% 2.c)
% a link is in interference state in states 3 and 4

pint = pi3 + pi4

% pint = 9.6092e-04

%% 2.d)

avgber = (1e-3 * pi3 + 1e-2 * pi4) / pint

% average bit error rate = 7e-3

%% 2.e)

p32 = 20/(20 + 10);
p34 = 10/(20+10);

avgt = 0;

for i=0:15
    avgt = p34^i * p32 * (i*(t3 + t4) + t3) + avgt;
end

% i corresponde ao número de loops
% avgt = 9 minutos




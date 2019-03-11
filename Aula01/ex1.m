% 1.a)
%p(acertar) = p(acertar/estudou)*p(estudou) + p(acertar/naoEstudou)*p(naoEstudou)

p = 0.6 + 0.25/4

% 1.b)
%slides ! 
p = 0.7*5/(1+4*0.7)


% 1.c)
x = linspace(0,1.0,100)
f1 = x + ((1-x)/3)
f2 = x + ((1-x)/4)
f3 = x + ((1-x)/5)
figure(1)
plot(x,f1*100,'',x,f2*100,':',x,f3*100,'--')
legend('m = 3','m=4','m=5','Location','Northwest')

% 1.d)
% . é usado para fazer operaçoes elemento a elemento 
x = linspace(0,1.0,100)
f4 = (x*3)./(1+2*x)
f5 = (x*4)./(1+3*x)
f6 = (x*5)./(1+4*x)
figure(2)
plot(x,f4*100,'',x,f5*100,':',x,f6*100,'--')
legend('m = 3','m=4','m=5','Location','Northwest')
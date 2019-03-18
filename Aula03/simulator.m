close all;
clear all;

%Parameters initialization:
par.N= 90;       % Number of mobile nodes
par.W= 40;       % Radio range (in meters)
par.delta= 1;    % Time slot (in seconds)
%par.AP = [200 150];   % Coordinates of each AP
%par.AP = [100 150;300 150];   % Coordinates of each AP
%par.AP = [100 150;200 150;300 150];   % Coordinates of each AP
par.AP = [100 100;300 100;100 200;300 200];   % Coordinates of each AP
par.nAP = size(par.AP,1);  %Number of APs

T= 3600;     % No. of time slots of the simulation

N = 20;
sim = zeros(N,2);

for i=1:N
    [sim(i,1), sim(i,2)] = func(par,T);
end

alfa = 0.1;
Average = mean(sim(:,1))
Conf90Average = norminv(1-alfa/2)*sqrt(var(sim(:,1))/N)
Minimum = mean(sim(:,2))
Conf90Min = norminv(1-alfa/2)*sqrt(var(sim(:,2))/N)

function [AverageAvailability, MinimumAvailability] = func(par, T)

    plotar = 0; % if plotar = 0, there is no visualization
                % if plotar = 1, node movement is visualized
                % if plotar = 2, node movement and connectivity are visualized

    % Initialization of mobile node positions and auxiliary matrices:
    map= InitializeState(par);
    % Initialization of statistical counters
    counter= InitializeCounter(par);
    L= [];
    C= [];
    h= waitbar(0,'Running simulation...');
    % Simulation cycles:
    for iter= 1:T
        waitbar(iter/T,h);
        % Update of  mobile node positions and auxiliary matrices:
        map= UpdateState(par,map);
        % Compute L with the node pairs with direct wireless links:
        L= ConnectedList(par,map);
        % Compute C with the nodes with Internet access:
        C= ConnectedNodes(par,L);
        % Update of statistical counters:
        counter= UpdateCounter(counter,C);
        % Visualization of the simulation:
        if plotar>0        
            visualize(par,map,L,C,plotar)
        end
    end
    delete(h)
    % Compute the final result: 
    [AverageAvailability, MinimumAvailability]= results(T,counter);


    function map= InitializeState(par)
        N= par.N;
        X= 400;
        Y= 300;
        pos= [50*randi([0 floor(Y/50)],N/2,1) Y*rand(N/2,1)];
        pos= [pos; X*rand(N/2,1) 50*randi([0 floor(X/50)],N/2,1)];
        vel_abs= 2*rand(N,1);
        vel_cont= randi(100,N,1);
        vel_angle= pi*randi([0 1],N/2,1) - pi/2;
        vel_angle= [vel_angle; pi*randi([0 1],N/2,1)];
        vel= [vel_abs.*cos(vel_angle) vel_abs.*sin(vel_angle)];
        map.pos= pos;
        map.vel= vel;
        map.vel_cont= vel_cont;
    end

    function counter= InitializeCounter(par)
    % counter - an array with par.N values (one for each mobile node) to count
    %           the number of time slots each node has Internet access
    % This function creates the array 'counter' and initializes it with zeros
    % in all positions. 

        counter = zeros(par.N,1);

    end

    function map= UpdateState(par,map)
        X= 400;
        Y= 300;
        N= par.N;
        pos= map.pos;
        vel= map.vel;
        vel_cont= map.vel_cont;
        delta= par.delta;    
        max_pos= [X*ones(N,1) Y*ones(N,1)];
        continuar= [vel_cont>0 vel_cont>0];
        pos= pos + delta*continuar.*vel;
        vel(pos<=0)= -vel(pos<=0);
        pos(pos<0)= 0;
        vel(pos>=max_pos)= -vel(pos>=max_pos);
        pos(pos>max_pos)= max_pos(pos>max_pos);
        map.pos= pos;
        map.vel= vel;
        aux= zeros(N,1);
        for j=find(vel_cont==1)
            aux(j)= -randi(40);
        end
        for j=find(vel_cont==-1)
            aux(j)= randi(100);
        end
        aux(vel_cont>1)= vel_cont(vel_cont>1)-1;
        aux(vel_cont<-1)= vel_cont(vel_cont<-1)+1;
        map.vel_cont= aux;
    end

    function counter= UpdateCounter(counter,C)
    % This function increments the values of array 'counter' for mobile nodes
    % that have Internet access.

        counter = counter+C;

    end

    function L= ConnectedList(par,map)
    % map.pos - a matrix with par.N rows and 2 columns; each row identifies the (x,y)
    %           coordinates of each mobile node
    % L -       a matrix with 2 columns; each row identifies a pair of nodes (mobile
    %           nodes and AP nodes) with direct wireless links between them
    % This function computes matrix 'L' based on matrix map.pos.
    %

    % d = raiz quadrada ((x2-x1)ao quadrado + (y2-y1) ao quadrado)

        L = [];

        for i=1:par.N-1
            xi = map.pos(i,1);
            yi = map.pos(i,2);
            for j=i+1:par.N
                xj = map.pos(j,1);
                yj = map.pos(j,2);
                dist = sqrt((xj-xi)^2 + (yj-yi)^2);
                if(dist <= par.W)
                    L = [L; i, j];
                end
            end

            for k=1:par.nAP
                xk = par.AP(k,1);
                yk = par.AP(k,2);
                d = sqrt((xk-xi)^2 + (yk-yi)^2);
                if(d <= par.W)
                    L = [L; i, par.N+k];
                end
            end
        end    
    end

    function C= ConnectedNodes(par,L)
    % C - an array with N values (one for each mobile node) that is 1 in 
    %     position i if mobile node i has Internet access
    % This function computes array 'C' based on matrix 'L' with the node pairs
    % that have direct wireless links.
    %
    % NOTE: To develop this function, check MATLAB function 'distances' that
    %       computes shortest path distances of a graph.
    %

        C = zeros(par.N, 1);
        L =[L;par.N+par.nAP,par.N+ par.nAP];
        G = graph(L(:,1),L(:,2));
        d = distances(G);

        for i=1:par.N
            for j=1:par.nAP
                C(i) = C(i)+(d(par.N+j,i)< Inf);
            end
        end

        C = C>0;

    end

    function [AverageAvailability, MinimumAvailability]= results(T,counter)
    % This function computes the average and the minimum availability (values
    % between 0 and 1) based on array 'counter' and on the total number of
    % time slots T.
        counter = counter/T;
        AverageAvailability = mean(counter);
        MinimumAvailability = min(counter);
    end

    function visualize(par,map,L,C,plotar)
        N= par.N;
        X= 400;
        Y= 300;
        pos= map.pos;
        AP= par.AP;
        nAP= par.nAP;
        plot(AP(1:nAP,1),AP(1:nAP,2),'s','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',12)
        hold on
        plot(pos(1:N,1),pos(1:N,2),'o','MarkerEdgeColor','r','MarkerFaceColor','r')
        if plotar==2
            pos=[pos;AP];
            for i=1:size(L,1)
                plot([pos(L(i,1),1) pos(L(i,2),1)],[pos(L(i,1),2) pos(L(i,2),2)],'b')
            end
            plot(pos(C,1),pos(C,2),'o','MarkerEdgeColor','b','MarkerFaceColor','b')
        end
        axis([-20 X+20 -20 Y+20])
        grid on
        set(gca,'xtick',0:50:X)
        set(gca,'ytick',0:50:Y)
        drawnow
        hold off
    end
end

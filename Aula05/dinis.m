Matrices;
%First Exercise
% k = [5 10 15 20 25 30];
% for i = 1:size(k,2)
%     tic
%        result = worstLink(R,C,L,T,k(i));
%     toc
%     fprintf("K = %f | Result = %f", k(i), result);
% end
% %Second Exercise
% %Tentei p�r sequencial a recolher os resultados todos de uma vez mas estava
% %a ter problemas.
% w = [0.7 0.75 0.8 0.85];
% k = 25;
% final = zeros(8,4);
% for i = 1:size(w,2)
%     values = bestEnergy(R, C, L, T, k, w(i));
%     final(i,:) = [1 w(i) values(1) values(2)];
%     fprintf("\n[A1]Energy Consumption for %f: %f\nWorst Link Load: %f\n", w(i),values(1), values(2));
% end
% fprintf("---------\n");
% for i = 1:size(w,2)
%     values = bestEnergy2(R, C, L, T, k, w(i));
%     final(4 + i,:) = [2 w(i) values(1) values(2)];
%     fprintf("\n[A2]Energy Consumption for %f: %f\nWorst Link Load: %f\n", w(i),values(1), values(2));
% end
% final
% save('result.mat','final');

%bestEnergy(R, C, L, T, 25, 0.8);
fprintf("\n---------\n");
bestEnergy2(R, C, L, T, 25, 0.8);


function best_value= worstLink(R, C, L, T, k)

    nNodes= size(L,1);
    nPaths= k;
    f= 0;
    for i=1:nNodes
        for j= 1:nNodes
            if T(i,j)>0
                f= f+1;
                flowDemand(f) = T(i,j);
                [shortestPaths{f}, tc] = kShortestPath(L, i, j, nPaths);
                if isempty(tc)
                    %fprintf('Error: no connectivity\n');
                    best_value = inf;
                    return
                end
            end
        end
    end
    nFlows= length(flowDemand);
    %solution that considers the first candidate path for all flows:
    solution= ones(1,nFlows);
    worstlinkload= maxLoad(solution,shortestPaths,flowDemand,R);

    % MIA PARTE
    best_solution = solution;
    best_value = worstlinkload;
    count = 0;
    improved = 1;
    while improved == 1
        %count = count + 1
        % Testar os vizinhos todos e descobrir o melhor
        improved = 0;
        for g = 1:nFlows
            for i = 1:length(shortestPaths{g})
                attempt = best_solution;
                if(i ~= attempt(g))
                    attempt(g) = i;
                    attempt_value = maxLoad(attempt,shortestPaths,flowDemand,R);
                    if(attempt_value < best_value)
                        %fprintf("Increased from %f to %f\n", best_value, attempt_value);
                        best_value = attempt_value;
                        best_solution = attempt;
                        improved = 1;
                    end
                end
            end
        end
    end
    %TRY: INICIAR V�RIOS PIPELINES EM VALORES ALEAT�RIOS COM PARFOR E ESCOLHER
    %O MELHOR NO FIM (minimizar os m�nimos locais)

    %TODO: Correr com os parametros desejados
end



%% Part 2 Minimizing Energy Consumption for a given Worst Link Load

function energy = energySpent(C)
    energy = sum(sum(C))/2;
end

% Enquanto houver melhoria
%   Cortar um link de cada vez
%       Ver o 'best_value'
%       Se em baixo do threshold (o que aumentar menos)
%   Repor o link cortado e repetir com o pr�ximo
% Cortar o link definitivamente, repetir

function response = bestEnergy(R, C, L, T, k, w)
    nLinks = size(R,1);
    attempt_C = C;
    attempt_R = R;
    attempt_L = L;
    attempt_energy = energySpent(C);
    current_worst = worstLink(R, C, L, T, k);
    current_C = attempt_C; % Energy
    current_R = attempt_R; % Bandiwth
    current_L = attempt_L; % Distance
    temp_R = current_R;
    temp_C = current_C;
    temp_L = current_L;

    improved = 1;
    while improved == 1
        % Reset � flag
        improved = 0;
        attempt_worst = inf;
        % Percorrer todos os links
        for i = 2:nLinks
            for j = 1:i-1
                % Se existir o link
                if(current_L(i,j) ~= inf)
                    % Cort�-lo
                    temp_R(i,j) = 0;
                    temp_R(j,i) = 0;
                    temp_C(i,j) = 0;
                    temp_C(j,i) = 0;
                    temp_L(i,j) = inf;
                    temp_L(j,i) = inf;

                    % Testar worst link load
                    temp_worst = worstLink(temp_R, temp_C, temp_L, T, k);
                    temp_energy = energySpent(temp_C);

                    % Se energia melhor que o atual armazenar numa tempor�ria
                    if(temp_worst <= w && temp_worst <= attempt_worst)
                        %fprintf("Found from %f to %f\n", attempt_energy, temp_energy);
                        cutted = [i j];
                        attempt_energy = temp_energy;
                        attempt_worst = temp_worst;
                        attempt_C = temp_C;
                        attempt_R = temp_R;
                        attempt_L = temp_L;
                        improved = 1;
                    end

                    % Repor o link
                    temp_R = current_R;
                    temp_C = current_C;
                    temp_L = current_L;
                end
            end
        end
        % Guardar as melhores como atuais
        if(improved == 1)
            %fprintf("END OF RUN-> Energy: %f | Attempt: %f\n", attempt_energy, attempt_worst);
            fprintf('Cutted the connection = (%f,%f)\n', cutted(1), cutted(2));
            current_energy = attempt_energy;
            current_worst = attempt_worst;
            current_C = attempt_C; % Energy
            current_R = attempt_R; % Bandiwth
            current_L = attempt_L; % Distance
            temp_R = current_R;
            temp_C = current_C;
            temp_L = current_L;
        end
    end
    current_C
    response = [current_energy  current_worst];

end

function response = bestEnergy2(R, C, L, T, k, w)
    nLinks = size(R,1);
    attempt_C = C;
    attempt_R = R;
    attempt_L = L;
    attempt_energy = energySpent(C);
    current_worst = worstLink(R, C, L, T, k);
    current_ratio = current_worst / attempt_energy;
    current_C = attempt_C; % Energy
    current_R = attempt_R; % Bandiwth
    current_L = attempt_L; % Distance
    temp_R = current_R;
    temp_C = current_C;
    temp_L = current_L;

    improved = 1;
    while improved == 1
        % Reset � flag
        improved = 0;
        attempt_ratio = inf;
        % Percorrer todos os links
        for i = 2:nLinks
            for j = 1:i-1
                % Se existir o link
                if(current_L(i,j) ~= inf)
                    % Cort�-lo
                    temp_R(i,j) = 0;
                    temp_R(j,i) = 0;
                    temp_energy = temp_C(i,j);
                    temp_C(i,j) = 0;
                    temp_C(j,i) = 0;
                    temp_L(i,j) = inf;
                    temp_L(j,i) = inf;

                    % Testar worst link load
                    temp_worst = worstLink(temp_R, temp_C, temp_L, T, k);
                    %temp_energy = energySpent(temp_C);
                    temp_ratio = temp_worst / temp_energy;

                    % Se energia melhor que o atual armazenar numa tempor�ria
                    if(temp_worst <= w && temp_ratio <= attempt_ratio) % temp_energy <= attempt_energy &&
                        %fprintf("Found from %f to %f\n", attempt_energy, temp_energy);
                        cutted = [i j];
                        attempt_energy = energySpent(temp_C);
                        attempt_worst = temp_worst;
                        attempt_ratio = temp_ratio;
                        attempt_C = temp_C;
                        attempt_R = temp_R;
                        attempt_L = temp_L;
                        improved = 1;
                    end

                    % Repor o link
                    temp_R = current_R;
                    temp_C = current_C;
                    temp_L = current_L;
                end
            end
        end
        % Guardar as melhores como atuais
        if(improved == 1)
            %fprintf("END OF RUN-> Energy: %f | Attempt: %f\n", attempt_energy, attempt_worst);
            fprintf('Cutted the connection = (%f,%f)\n', cutted(1), cutted(2));
            current_energy = attempt_energy;
            current_worst = attempt_worst;
            current_ratio = attempt_ratio;
            current_C = attempt_C; % Energy
            current_R = attempt_R; % Bandiwth
            current_L = attempt_L; % Distance
            temp_R = current_R;
            temp_C = current_C;
            temp_L = current_L;
        end
    end

    response = [current_energy  current_worst];

end

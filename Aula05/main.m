clear all;
Matrices;
nNodes= size(L,1);
nPaths= 20;
f= 0;
for i=1:nNodes
    for j= 1:nNodes
        if T(i,j)>0
            f= f+1;
            flowDemand(f) = T(i,j);
            [shortestPaths{f}, tc] = kShortestPath(L, i, j, nPaths);
            if isempty(tc)
                fprintf('Error: no connectivity\n');
            end
        end
    end
end
nFlows= length(flowDemand);
%solution that considers the first candidate path for all flows:
solution= ones(1,nFlows);
worstlinkload= maxLoad(solution,shortestPaths,flowDemand,R);

improved = true;
contador= 0;
while improved
    contador= contador + 1;
    [contador worstlinkload]
    bestneighbor = [];
    valuedofbest = worstlinkload;
    for f = 1:nFlows
        for k = 1:length(shortestPaths{f})
            if k ~= solution(f)
                solution_tmp = solution;
                solution_tmp(f) = k;
                worstlinkload_tmp = maxLoad(solution_tmp,shortestPaths,flowDemand,R);
                if(worstlinkload_tmp < valuedofbest)
                    valuedofbest = worstlinkload_tmp;
                    bestneighbor = solution_tmp;
                end
            end
        end
    end

    if(valuedofbest < worstlinkload)
        worstlinkload = valuedofbest;
        solution = bestneighbor;
    else
        improved = false;
    end
end
fprintf("worst link load: %d  \n",worstlinkload)

% Com o K a aumentar até 5 tem peso significativo, porem a partir deste o valor do worst link load não muda signativamente 


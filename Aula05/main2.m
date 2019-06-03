clear all;
Matrices;
nNodes= size(L,1);
nPaths= 5;
worstLinkQueue = zeros(length(R),4);
worstLinkLoadtemp = inf;
bestpx = 0;
bestpy = 0;
Finish = true;

while Finish 
    for i=1:length(R)
        for j=1:length(R)
            if R(i,j) > 0
                Raux =R;
                Raux(i,j) = 0;
                Raux(j,i) = 0;
                Laux = L;
                Laux(i,j) = inf;
                Laux(j,i) = inf;
                worstLinkLoad = localSearch(Raux,Laux,T,nNodes);
                if(worstLinkLoad < worstLinkLoadtemp)
                    worstLinkLoadtemp = worstLinkLoad;
                    bestpx = i;
                    bestpy = j;
                end
            end
        end
    end
    
    worstLinkQueue = [worstLinkQueue; bestpx,bestpy, worstLinkLoadtemp];
    R(bestpx,bestpy) = 0;
    L(bestpx,bestpy) = 0;
    
    Finish=false;
end
    worstLinkQueue
    
    
    
function worstlinkload = localSearch(R,L,T,nNodes)
    nPaths = 5;
    f= 0;
    for i=1:nNodes
        for j= 1:nNodes
            if T(i,j)>0
                f= f+1;
                flowDemand(f) = T(i,j);
                [shortestPaths{f}, tc] = kShortestPath(L, i, j, nPaths);
                if isempty(tc)
                    worstlinkload = inf;
                    return;
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
        [contador worstlinkload];
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
end
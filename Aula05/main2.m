clear all;
Matrices;
nNodes= size(L,1);
nPaths= 5;

Rold = R;
Cold = C;
Lold = L;
Rnew = R;
Cnew = C;
Lnew = L;
bestpx = 0;
bestpy = 0;
removedlinks = 0;
finish = false;

while(~finish) 
    fprintf("Removed links so far: %d\n", removedlinks);
    [a, b] = size(R);
    worstLinkLoad = 100;
    ratio = inf;
    bestpx = 0;
    bestpy = 0;
    for i=1:a-1
        for j=i+1:a
            R = Rold;            
            if(R(i,j) == 0)
                continue
            end
            R(i,j) = 0;
            R(j,i) = 0;
            C = Cold;
            C(i,j) = 0;
            C(j,i) = 0;                
            L = Lold;
            L(i,j) = inf;
            L(j,i) = inf;
                
            worstLinkLoadtemp = localSearch(R,L,T,nNodes);
            energy = sum(sum(C)) / 2;
            ratiotemp = worstLinkLoadtemp/energy;
            if(ratiotemp < ratio)
                Rnew = R;
                Cnew = C;
                Lnew = L;
                worstLinkLoad = worstLinkLoadtemp;
                bestpx = i;
                bestpy = j;
                ratio = ratiotemp;
                fprintf("Link: (%d,%d) / WorstLinkLoad: %f, Energy: %f Ratio: %f\n",bestpx, bestpy, worstLinkLoad, energy, ratio )
            end
        end
    end
    
    fprintf("Removed link: (%d,%d)", bestpx, bestpy,)
    if(worstLinkLoad > 0.85)
        finish = true;
        fprintf("End\n")
    end
    
    Rold = Rnew;
    Lold = Lnew;
    Cold = Cnew;
    removedlinks = removedlinks + 1;
end
    
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
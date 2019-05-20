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
worstlinkload= maxLoad(solution,shortestPaths,flowDemand,R)
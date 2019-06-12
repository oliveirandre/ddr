clc;
clear all;
Matrices;
nNodes= size(L,1);

nPaths= 5; 
R_original = R;
R_proposed = R;
C_original = C;
C_proposed = C;
L_original = L;
L_proposed = L;
max_link_load = 0.7;
links_removed = 0;

terminate = false;
while(~terminate)
    
    fprintf("New search with %d links removed\n", links_removed);
    % reset var
    [ii_size, jj_size] = size(R);
    worstlinkload = 100;    ratio = 9999999;     
    ii_val = 0;             jj_val = 0;
    
    for ii = 1:ii_size-1
        for jj = ii+1:ii_size
            %Repor matrizes
            R = R_original;
            L = L_original;
            C = C_original;

            %sair se o link nao existir
            if (R(ii,jj)==0) 
                continue  
            end

            %desligar o link
            R(ii,jj) = 0;   R(jj,ii) = 0;
            C(ii,jj) = 0;   C(jj,ii) = 0;
            L(ii,jj) = inf; L(jj,ii) = inf;

            worstlinkload_tmp = localsearch(L, R, T);
            energy_cost = sum(sum(C)) / 2;
            ratio_tmp = worstlinkload_tmp/energy_cost;
            
            if(ratio_tmp < ratio )
            %if(worstlinkload_tmp < worstlinkload )
                R_proposed=R;
                L_proposed=L;
                C_proposed=C;
                ii_val = ii;
                jj_val = jj;
                worstlinkload = worstlinkload_tmp;
                ratio = ratio_tmp;
                fprintf("Found: (%d,%d) worst link load: %f, Energy: %f Ratio: %f\n",ii_val, jj_val, worstlinkload, energy_cost, ratio )
            end  
        end
    end
    
    fprintf("Removed: (%d,%d) worst link load: %f, Energy: %f Ratio: %f\n",ii_val, jj_val, worstlinkload, energy_cost, ratio )
    
    if (worstlinkload > 0.85)
        terminate = true;
        fprintf("Simulation end\n")
    end
    
    R_original = R_proposed;
    L_original = L_proposed;
    C_original = C_proposed;
    links_removed = links_removed+1;
end
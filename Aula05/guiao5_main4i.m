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
energy_cost = 9999999999999999;
terminate=false;
while(~terminate)
    
    worstlinkload = 100;
    %% ii-> jj
    [ii_size, jj_size] = size(R);
    ii_val=0;
    jj_val=0;

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
            R(ii,jj) = 0;
            R(jj,ii) = 0;
            C(ii,jj) = 0;
            C(jj,ii) = 0;
            L(ii,jj) = inf;
            L(jj,ii) = inf;

            worstlinkload_tmp = localsearch(L, R, T);
            energy_cost = sum(sum(C)) / 2;
            if(worstlinkload_tmp < worstlinkload) 
                R_proposed=R;
                L_proposed=L;
                C_proposed=C;
                worstlinkload = worstlinkload_tmp;
                ii_val = ii;
                jj_val = jj;
                %fprintf("link removed: i%d j%dworst link load: %f, Energy: %f \n",ii_val,jj_val, worstlinkload, energy_cost)

            end

        end
    end
    fprintf("link removed: i:%d j:%dworst link load: %f, Energy: %f \n",ii_val,jj_val, worstlinkload, energy_cost)
    R_original = R_proposed;
    L_original = L_proposed;
    C_original = C_proposed;
    if(worstlinkload > 0.85)
        terminate=true;
    end
end

%fprintf("worst link load: %d  \n", worstlinkload)
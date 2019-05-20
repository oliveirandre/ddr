
B = 64*0.19 + 1518*0.48 + (1517+65)/2*(1-0.19-0.49);
averagePacketSize = B;
queuePackets = floor([150000 15000]/averagePacketSize); %number of packets that can be stored in queue
lambda = ([6 8 9 9.5 9.75 10.0]*(1e6/8))./averagePacketSize; %pkts/s
link_capacity = 10e6./8; %bytes/s
u = link_capacity/averagePacketSize; %pkts/s
lambda_u = lambda./u;
for j = 1:length(lambda)
    for i = 0:(queuePackets(1)+1)
        res_a(j,i+1) = lambda_u(j).^i;
    end
end

for j = 1:length(lambda)
    for i = 0:(queuePackets(1)+1)
       pa(j,i+1) = res_a(j,i+1)/ sum(res_a(j,:));
    end
end

for j = 1:length(lambda)
      AvgPktLossA(j) = (res_a(j,queuePackets(1)+1) ./ sum(res_a(j,:)))*100; 
end

for j = 1:length(lambda)
    AvgPktOnA(j)=0;
    AvgPktDelayA(j) = 0;
    for i = 1:(queuePackets(1))
        AvgPktOnA(j) = AvgPktOnA(j) + (i*pa(j,i+1));
    end
    AvgPktOnA(j) = AvgPktOnA(j) + (queuePackets(1)*pa(j,queuePackets(1)+1));
    AvgPktDelayA(j) = (AvgPktOnA(j) ./ lambda(j)).*1000;
end

for j = 1:length(lambda)
    for i = 0:(queuePackets(2)+1)
        res_b(j,i+1) = lambda_u(j).^i;
    end
end

for j = 1:length(lambda)
    for i = 0:(queuePackets(2)+1)
       pb(j,i+1) = res_b(j,i+1)/ sum(res_b(j,:));
    end
end

for j = 1:length(lambda)
      AvgPktLossB(j) = (res_b(j,queuePackets(2)+1) ./ sum(res_b(j,:)))*100; 
end

for j = 1:length(lambda)
    AvgPktOnB(j)=0;
    AvgPktDelayB(j) = 0;
    for i = 1:(queuePackets(2))
        AvgPktOnB(j) = AvgPktOnB(j) + (i*pb(j,i+1));
    end
    AvgPktOnB(j) = AvgPktOnB(j) + (queuePackets(2)*pb(j,queuePackets(2)+1));
    AvgPktDelayB(j) = (AvgPktOnB(j) ./ lambda(j)).*1000;
end
AvgPktLoss = [AvgPktLossA AvgPktLossB];
AvgPktDelay = [AvgPktDelayA AvgPktDelayB];

    for i = 0:(queuePackets(1)+1)
       pa(j,i+1) = res_a(j,i+1)/ sum(res_a(j,:));
    end

for j = 1:length(lambda)
      AvgPktLossA(j) = (res_a(j,queuePackets(1)+1) ./ sum(res_a(j,:)))*100; 
end

for j = 1:length(lambda)
    AvgPktOnA(j)=0;
    AvgPktDelayA(j) = 0;
    for i = 1:(queuePackets(1))
        AvgPktOnA(j) = AvgPktOnA(j) + (i*pa(j,i+1));
    end
    AvgPktOnA(j) = AvgPktOnA(j) + (queuePackets(1)*pa(j,queuePackets(1)+1));
    AvgPktDelayA(j) = (AvgPktOnA(j) ./ lambda(j)).*1000;
end

for j = 1:length(lambda)
    for i = 0:(queuePackets(2)+1)
        res_b(j,i+1) = lambda_u(j).^i;
    end
end

for j = 1:length(lambda)
    for i = 0:(queuePackets(2)+1)
       pb(j,i+1) = res_b(j,i+1)/ sum(res_b(j,:));
    end
end

for j = 1:length(lambda)
      AvgPktLossB(j) = (res_b(j,queuePackets(2)+1) ./ sum(res_b(j,:)))*100; 
end

for j = 1:length(lambda)
    AvgPktOnB(j)=0;
    AvgPktDelayB(j) = 0;
    for i = 1:(queuePackets(2))
        AvgPktOnB(j) = AvgPktOnB(j) + (i*pb(j,i+1));
    end
    AvgPktOnB(j) = AvgPktOnB(j) + (queuePackets(2)*pb(j,queuePackets(2)+1));
    AvgPktDelayB(j) = (AvgPktOnB(j) ./ lambda(j)).*1000;
end
AvgPktLoss = [AvgPktLossA AvgPktLossB]
AvgPktDelay = [AvgPktDelayA AvgPktDelayB]



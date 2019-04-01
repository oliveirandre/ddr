par.r = 6000000; %bps
par.f = 150000; %Bytes
par.S = 1000; %seconds

%out = simulator1(par);

%fprintf("Average Packet Loss (%%)= %f\n", out.AvgPacketLoss);
%fprintf("Average Packet Delay (ms)= %f\n", out.AvgPacketDelay);
%fprintf("Transmitted Throughput (Mbps)= %f\n", out.TransThroughput);

N = 10;
sim = zeros(N, 3);

for i = 1:N
    [sim(i,1), sim(i,2), sim(i,3)] = simulator1(par);
end

apl = mean(sim(:,1))
apd = mean(sim(:,2))
att = mean(sim(:,3))

function res = simulator1(par)
%function [AvgPacketLoss, AvgPacketDelay, TransThroughput] = simulator1(par)
    
    EventList = zeros(f,2);

    %B = 64*0.19 + 1518*0.48 + (1517+65)/2*(1-0.19-0.49);
    %Throughput = B * 8 / 10Mbps;
    
    %% EVENTS
    
    % Arrival - the arrival of the packet (indicated by a 1)
    % Departure - the termination of a packet transmission (indicated by 2)
    % Terminate - the termination of the simulation (indicated by a 0)
    
    ARRIVAL = 1;
    DEPARTURE = 2;
    TERMINATE = 0;
    
    EventList =[;par]
    
    %% STATE VARIABLES
    
    % State - indicates if link is FREE or BUSY
    % QueueOcupation - total number of bytes of the QUEUED packets
    % Queue - structure with ARRIVAL_TIME and SIZE of each packet
    
    
    
    %% STATISCAL COUNTERS
    
    % TotalPackets - NUMBER of packets ARRIVED to the system
    % LostPackets - NUMBER of packets DISCARDED due to buffer overflow
    % TransmittedBytes - NUMBER of TRANSMITTED bytes
    
    
    
    %% AUXILIARY VARIABLES
    
    % Instant - arrival TIME_INSTANT of the packet that is being
    % transmitted
    % Syze - SIZE, in bytes, of the packet that is being transmitted
    % Clock?
    
    
    %% FINAL CALCULATIONS
    
    %AvgPacketLoss = 100% * LostPackets/TotalPackets;
    %AvgPacketDelay = 1000 * Delays/TransmittedPackets;
    %TransThroughput = 8 * TransmittedBytes * 10e-6 / S;
    
    
    
end
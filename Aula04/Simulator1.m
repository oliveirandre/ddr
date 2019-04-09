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

    B = 64*0.19 + 1518*0.48 + (1517+65)/2*(1-0.19-0.49);
    TempoMedioCheagadas = B * 8 / par.r;
    
    %% EVENTS
    
    % Arrival - the arrival of the packet (indicated by a 1)
    % Departure - the termination of a packet transmission (indicated by 2)
    % Terminate - the termination of the simulation (indicated by a 0)
    
    ARRIVAL =  1;
    DEPARTURE = 2;
    TERMINATE = 0;
    
    EventList = [exprnd(TempoMedioCheagadas) ARRIVAL; par.S TERMINATE];
    
    %% STATE VARIABLES
    
    % State - indicates if link is FREE or BUSY
    % QueueOcupation - total number of bytes of the QUEUED packets
    % Queue - structure with ARRIVAL_TIME and SIZE of each packet
    
    State = 0;
    Queue = [];
    QueueOcupation = 0;
    ARRIVAL_TIME = par.S;
    SIZE = par.f;
    
    %% STATISCAL COUNTERS
    
    % TotalPackets - NUMBER of packets ARRIVED to the system
    % LostPackets - NUMBER of packets DISCARDED due to buffer overflow
    % TransmittedBytes - NUMBER of TRANSMITTED bytes
    %TransmittedPackets - Number of TRANSMITTED packets
    TotalPackets = 0;
    LostPackets = 0;
    TransmittedBytes = 0;
    TransmittedPackets =0;
    
    
    %% AUXILIARY VARIABLES
    
    % Instant - arrival TIME_INSTANT of the packet that is being
    % transmitted
    % Syze - SIZE, in bytes, of the packet that is being transmitted
    % Clock?
    Instant = 0;
    Syze = 0;
    Clock = 0;
    Delays = 0; 
    %% Code
    while EventList(1,2) != TERMINATE
        switch EventList(1,2)
            case ARRIVAL
                EventList = EventList(2:SIZE(EventList),:);
                TMP_Syze = packetsize();
                TotalPackets = TotalPackets +1;
                Clock = EventList(1,2) ;
                EventList = [EventList; Clock+exprnd(TempoMedioCheagadas) ARRIVAL ];
                if State == 0
                    State = 1;
                    Instant = Clock;
                    Syze = TMP_Syze;
                    Dep_time = Instant + (TMP_Syze*8)/1e4;
                    EventList = [EventList; Dep_time DEPARTURE ];
                
                else
                    if ( QueueOcupation + TMP_Syze < par.f)
                        Queue = [Queue; Clock TMP_Syze];
                        QueueOcupation = QueueOcupation + TMP_Syze;
                    else    
                        LostPackets = LostPackets +1;
                    end
                end
                EventList = sortrows(EventList);
            case DEPARTURE
                Clock = EventList(1,2) ;
                EventList = EventList(2:SIZE(EventList),:);
                Delays = Delays + Clock-Instant;
                
        end
    end






    %% FINAL CALCULATIONS
    
    %AvgPacketLoss = 100% * LostPackets/TotalPackets;
    %AvgPacketDelay = 1000 * Delays/TransmittedPackets;
    %TransThroughput = 8 * TransmittedBytes * 10e-6 / S;
    
    
    
end


function PacketSize = packetsize()
    r = rand();
    if(r < 0.19)
        PacketSize = 64;
        return 
    end
    if(r > 0.52)
        PacketSize = 1518;
        return
    end
    PacketSize = randi([65 1517]);
end

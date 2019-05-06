R = [6e6,8e6,9e6,9.5e6,9.75e6,10.0e6,...
        6e6,8e6,9e6,9.5e6,9.75e6,10.0e6]; %bps
F = [15e4,15e4,15e4,15e4,15e4,15e4,...
        15e3,15e3,15e3,15e3,15e3,15e3]; %Bytes
par.S = 1000; %seconds

Cases = ['A','B','C','D','E','F','G','H','I','J','K','L'];


for i = 1:12
    par.r = R(i);
    par.f = F(i);
    parfor j = 1:10 
        tic
        out = simulator1(par);
        toc
        AVGPACKETLOSS(j) = out.AvgPacketLoss;
        AVGPACKETDELAY(j) = out.AvgPacketDelay;
        AVGTRANSTHPUT(j) = out.TransThroughput;
    end
    fprintf("%d %c %d %d \n",i,Cases(i),par.r,par.f)
    fprintf("Average Packet Loss (%%)= %f\n",mean(AVGPACKETLOSS));
    fprintf("Average Packet Delay (ms)= %f\n",mean(AVGPACKETDELAY));
    fprintf("Transmitted Throughput (Mbps)= %f\n",mean(AVGTRANSTHPUT));
end

function res = simulator1(par)
%function [AvgPacketLoss, AvgPacketDelay, TransThroughput] = simulator1(par)
    
    
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
    while EventList(1,2) ~= TERMINATE
        switch EventList(1,2)
            case ARRIVAL
                TMP_Syze = packetsize();
                TotalPackets = TotalPackets +1;
                Clock = EventList(1,1);
                EventList = EventList(2:size(EventList,1),:);
                EventList = [EventList; Clock+exprnd(TempoMedioCheagadas) ARRIVAL ];
                if State == 0
                    State = 1;
                    Instant = Clock;
                    Syze = TMP_Syze;
                    Dep_time = Instant + (TMP_Syze*8)/1e7;
                    EventList = [EventList; Dep_time DEPARTURE ];
                
                else
                    if ( QueueOcupation + TMP_Syze <= par.f)
                        Queue = [Queue; Clock TMP_Syze];
                        QueueOcupation = QueueOcupation + TMP_Syze;
                    else    
                        LostPackets = LostPackets +1;
                    end
                end
            case DEPARTURE
                Clock = EventList(1,1);
                EventList = EventList(2:size(EventList,1),:);
                Delays = Delays + Clock-Instant;
                TransmittedBytes = TransmittedBytes +Syze;
                TransmittedPackets = TransmittedPackets + 1;
                if(QueueOcupation > 0 )
                   Instant = Queue(1,1);
                   Syze = Queue(1,2);
                   Dep_time = Clock + (Syze*8)/1e7;
                   EventList = [EventList; Dep_time DEPARTURE ];
                   Queue = Queue(2:size(Queue,1),:);
                   QueueOcupation = QueueOcupation - Syze;
                else
                    State = 0;
                end
                
        end
        EventList = sortrows(EventList);

    end
    %% FINAL CALCULATIONS
    
    
    res.AvgPacketLoss = 1 * LostPackets/TotalPackets;
    res.AvgPacketDelay = 1000 * Delays/TransmittedPackets;
    res.TransThroughput = 8 * TransmittedBytes * 1e-6 / par.S;
    
    
    
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

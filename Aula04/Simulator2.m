par.r= [1e6 3e6 6e6]; %bps
par.J{1}= [1]; %routing path of flow 1
par.J{2}= [1 2]; %routing path of flow 2
par.J{3}= [2]; %routing path of flow 3
par.C= [5e6 10e6]; %bps
par.f= [150e3 150e3]; %Bytes
par.S= 1000; %seconds
out = simulator2(par);
for a= 1:length(par.r)
 fprintf("Average Packet Loss (%%)= %f\n",out.AvgPacketLoss(a));
 fprintf("Average Packet Delay (ms)= %f\n",out.AvgPacketDelay(a));
end


function res = simulator2(par)
    
    
    %% EVENTS
    
    % Arrival - the arrival of the packet (indicated by a 1)
    % RETRANSMIT - the arrival of a packet to all links of its routing path except the first indicated by 2)
    % Departure - the termination of a packet transmission (indicated by 3)
    % Terminate - the termination of the simulation (indicated by a 0)
    
    ARRIVAL =  1;
    RETRANSMIT = 2;
    DEPARTURE = 3;
    TERMINATE = 0;

    EventList =[];
    for i = 1:length(par.r):
        EventList = [ EventList; exprnd(packetTime(par.r(i))) Arrival i par.J{i}(1)];
    end
    EventList = sortrows([EventList; par.S Terminate 0 0 ]);
    
    
    %% STATE VARIABLES
    
    % State - indicates if link is FREE or BUSY
    % QueueOcupation - total number of bytes of the QUEUED packets
    % Queue - structure with ARRIVAL_TIME and SIZE of each packet, [link1][link2][link3]
    
    State = repmat(0,1,length(par.C));
    Queue = cell(1,length(par.C));
    QueueOcupation = repmat(0,1,length(par.C));
    
    %% STATISCAL COUNTERS
    
    % TotalPackets - NUMBER of packets ARRIVED to the system
    % LostPackets - NUMBER of packets DISCARDED due to buffer overflow
    % TransmittedBytes - NUMBER of TRANSMITTED bytes
    %TransmittedPackets - Number of TRANSMITTED packets
    TotalPackets = repmat(0,1,length(par.r));
    LostPackets = repmat(0,1,length(par.r));
    TransmittedBytes = repmat(0,1,length(par.r));
    TransmittedPackets = repmat(0,1,length(par.r));
    
    
    %% AUXILIARY VARIABLES
    
    % Instant - arrival TIME_INSTANT of the packet that is being
    % transmitted
    % Syze - SIZE, in bytes, of the packet that is being transmitted
    % Clock?
    Instant = repmat(0,1,length(par.C));
    Syze = repmat(0,1,length(par.C));
    Clock = 0;
    Delays = repmat(0,1,length(par.r)); 

    %Return variables
    res.AvgPacketLoss = repmat(0,1,length(par.r)); % per flow packet loss
    res.AvgPacketDelay = repmat(0,1,length(par.r));

    %% Code
    while EventList(1,2) ~= TERMINATE
        switch EventList(1,2)
            case ARRIVAL
                TMP_Syze = packetsize();
                TotalPackets = TotalPackets +1;
                Clock = EventList(1,1);
                Flow = Events(1,3);
                Link = Events(1,4);
                Next_Packet = exprnd(packetTime(par.r(Flow)))+ Clock;
                
                EventList = EventList(2:size(EventList,1),:);
                EventList = [EventList; Next_Packet ARRIVAL ];
                if State == 0
                    State = 1;
                    Instant(Link) = Clock;
                    Syze(Link) = TMP_Syze;
                    Dep_time = Instant(Link) + (TMP_Syze*8)/1e7;
                    CurrentPath = par.J{Flow};
                    if(CurrentPath(length(CurrentPath)) == Link)
                        EventList = [EventList; Dep_time Departure Flow Link];
                    else
                        nextLink = CurrentPath(find(CurrentPath == Link)+1);
                        EventList = [ EventList; Dep_time Retransmit Flow nextLink ];
                    end
                
                elseif (QueueOccupation(Link) + TMP_Syze < par.f(Link))
                    Queue{Link} = [Queue{Link}; Clock TMP_Syze Flow];
                    QueueOccupation(Link) = QueueOccupation(Link) + TMP_Syze;
                else
                    LostPackets(Flow) = LostPackets(Flow) + 1;
                end

            case DEPARTURE
                TMP_Syze = packetsize();
                TotalPackets = TotalPackets +1;
                Clock = EventList(1,1);
                Flow = Events(1,3);
                Link = Events(1,4);
                Next_Packet = exprnd(packetTime(par.r(Flow)))+ Clock;

                EventList = EventList(2:size(EventList,1),:);
                Delays(Flow) = Delays(Flow) + Clock-Instant(Link);
                TransmittedBytes = TransmittedBytes +Syze(Link);
                TransmittedPackets = TransmittedPackets + 1;
                if(QueueOcupation > 0 )
                   Instant = Queue{1}(1);
                   Syze(Link) = Queue{1}(2);
                   Dep_time = Clock + (Syze(Link)*8)/1e7;
                   EventList = [EventList; Dep_time DEPARTURE ];
                   Queue = Queue(2:size(Queue,1),:);
                   QueueOcupation = QueueOcupation - Syze(Link);
                else
                    State = 0;
                end
            case RETRANSMIT
                
                
        end
        EventList = sortrows(EventList);

    end
    %% FINAL CALCULATIONS
    
    
    res.AvgPacketLoss = 1 * LostPackets/TotalPackets;
    res.AvgPacketDelay = 1000 * Delays/TransmittedPackets;
    
    
    
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

function TempoMedioCheagadas = packetTime(rate)
    B = 64*0.19 + 1518*0.48 + (1517+65)/2*(1-0.19-0.49);
    TempoMedioCheagadas = B * 8 / par.r;
end

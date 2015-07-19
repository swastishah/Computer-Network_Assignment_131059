#Swasti Shah - 131059
#Computer Network Assignment - 1
#Lan simulation
set ns [new Simulator]
#define color for data flows
#Assign 1 to 10 udp connection data flow as Red color
$ns color 1 Blue  
#  Assign 2 to 7 fpt connection data flow as Red color
$ns color 2 Red	
# Assign 8 to 0 udp connection data flow as green color
$ns color 8 green 
#open trace files
set tracefile1 [open out.tr w]
set winfile [open winfile w]
$ns trace-all $tracefile1
#open nam file
set namfile [open out.nam w]
$ns namtrace-all $namfile
#define the finish procedure
proc finish {} {
	global ns tracefile1 namfile
	$ns flush-trace
	close $tracefile1
	close $namfile
	exec nam out.nam &
	exit 0
} 
#create eleven nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]
set n10 [$ns node]
# Assign first node as blue color
$n1 color blue 
# Assign eight node as green color
$n8 color green 
# Assign second node as red color
$n2 color red	

#create links between the nodes
$ns duplex-link $n0 $n1 2Mb 15ms DropTail
$ns duplex-link $n0 $n3 2Mb 15ms DropTail
$ns duplex-link $n2 $n3 2Mb 15ms DropTail
$ns duplex-link $n1 $n2 2Mb 15ms DropTail
$ns duplex-link $n4 $n5 2Mb 50ms DropTail
$ns duplex-link $n4 $n6 2Mb 30ms DropTail
$ns duplex-link $n6 $n7 2Mb 10ms DropTail
$ns duplex-link $n6 $n8 2Mb 10ms DropTail
$ns duplex-link $n9 $n10 2Mb 10ms DropTail
$ns duplex-link $n5 $n6 2Mb 10ms DropTail

set lan [$ns newLan " $n2 $n9 $n4 " 0.3Mb 40ms LL Queue/DropTail MAC/Csma/Cd Channel ]
#Give node position
$ns duplex-link-op $n0 $n3 orient right
$ns duplex-link-op $n0 $n1 orient down
$ns duplex-link-op $n2 $n3 orient up
$ns duplex-link-op $n2 $n1 orient left
$ns duplex-link-op $n5 $n6 orient right-down
$ns duplex-link-op $n4 $n5 orient right-up
$ns duplex-link-op $n4 $n6 orient right
$ns duplex-link-op $n6 $n8 orient right-down
$ns duplex-link-op $n6 $n7 orient left-down
$ns duplex-link-op $n9 $n10 orient right-down

#setup TCP connection 2 to 7 node
set tcp [new Agent/TCP/Newreno]
$ns attach-agent $n2 $tcp
set sink [new Agent/TCPSink/DelAck]
$ns attach-agent $n7 $sink
$ns connect $tcp $sink
$tcp set fid_ 2
$tcp set packet_size_ 552
#set ftp over tcp connection 2 to 7 node
set ftp [new Application/FTP]
$ftp attach-agent $tcp
#setup a UDP connection 1 to 10 node
set udp1 [new Agent/UDP]
$ns attach-agent $n1 $udp1
set null [new Agent/Null]
$ns attach-agent $n10 $null
$ns connect $udp1 $null
$udp1 set fid_ 1
#setup a UDP connection 8 to 0 node
set udp2 [new Agent/UDP]
$ns attach-agent $n8 $udp2
set null [new Agent/Null]
$ns attach-agent $n0 $null
$ns connect $udp2 $null
$udp2 set fid_ 8
#set up a CBR over UDP1 connection
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set type_ CBR
$cbr1 set packet_size_ 1000 
$cbr1 set rate_ 0.01Mb
$cbr1 set random_ false
#set up a CBR over UDP2 connection
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
$cbr2 set type_ CBR
$cbr2 set packet_size_ 1000 
$cbr2 set rate_ 0.01Mb
$cbr2 set random_ false
#scheduling the events
$ns at 0.1 "$cbr1 start"
$ns at 0.2 "$cbr2 start"
$ns at 0.3. "$ftp start"
$ns at 2.0 "$ftp stop"
$ns at 2.5 "$cbr1 stop"
$ns at 2.5 "$cbr2 stop"
proc plotWindow {tcpSource file} {
global ns
set time 0.1
set now [ $ns now]
set cwnd [ $tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [ expr $now+$time ] "plotWindow $tcpSource $file"
}
$ns at 0.1 "plotWindow $tcp $winfile"
$ns at 3.0 "finish"
$ns run



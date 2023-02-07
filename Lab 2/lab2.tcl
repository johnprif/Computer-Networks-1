#Create an instance of the Simulator class

set ns [new Simulator]

#Define different colors for data flows

$ns color 1 Blue
$ns color 2 Red

#Add four nodes n0, n1, n2 and n3

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

#Export packet traces

set f [open lab2.tr w]
$ns trace-all $f

#Export nam traces

set nf [open lab2.nam w]
$ns namtrace-all $nf

#Create 3 (duplex) links (n0-n2, n1-n2, n3-n2)
#with 1.5Mb bandwidth and 10ms delay per link,
#including a DropTail queue for each link

$ns duplex-link $n0 $n2 1.5Mb 10ms DropTail
$ns duplex-link $n1 $n2 1.5Mb 10ms DropTail
$ns duplex-link $n3 $n2 1.5Mb 10ms DropTail

#Define a link orientation

$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right

#Monitor the queue for the link between node 2 and node 3

$ns duplex-link-op $n2 $n3 queuePos 0.5 
$ns duplex-link-op $n0 $n2 queuePos 0.8
$ns duplex-link-op $n1 $n2 queuePos 0.40 

#Set Queue size of link (n2-n3) to 10

$ns queue-limit $n2 $n3 10

#Create a UDP connection (udp0) and attach it to node n0

set udp0 [new Agent/UDP]
$udp0 set class_ 1
$ns attach-agent $n0 $udp0

#Create a CBR traffic source (cbr0) and attach it to udp0
#Set packetSize = 100 bytes
#Set interval time = 0.001 secs (stored in int variable)

set cbr0 [new Application/Traffic/CBR]
set int 0.0010659566
$cbr0 set packetSize_ 100
$cbr0 set interval_ $int
$cbr0 attach-agent $udp0

#Create a Null agent (null0) and attach it to node n3

set null0 [new Agent/Null]
$ns attach-agent $n3 $null0

#Connect udp0 and null0 agents

$ns connect $udp0 $null0

#Create a UDP connection (udp1) and attach it to node n1
set udp1 [new Agent/UDP]
$udp1 set class_ 2
$ns attach-agent $n1 $udp1

#Create a CBR traffic source (cbr1) and attach it to udp1
#Set packetSize = 100 bytes
#Set interval time = 0.001 secs (stored in int variable)

set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 100
$cbr1 set interval_ $int
$cbr1 attach-agent $udp1

#Connect udp1 and null0 agents
  
$ns connect $udp1 $null0

#Schedule event cbr0 to start at 0.5 secs and to stop at 4.5 secs

$ns at 0.5 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"

#Schedule event cbr1 to start at 1.0 secs and to stop at 4.0 secs

$ns at 1.0 "$cbr1 start"
$ns at 4.0 "$cbr1 stop"

#Call the procedure "finish" at 5.0 secs

$ns at 5.0 "finish"

#Add a procedure, called "finish"

proc finish {} {
	puts "running nam..."        
	global ns f nf
	$ns flush-trace
	close $nf
	close $f
	exec nam lab2.nam &
	exit 0
}

#Start the simulation

$ns run

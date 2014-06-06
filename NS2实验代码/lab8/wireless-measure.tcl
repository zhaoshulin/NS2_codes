# Define options �w�q�@���ܼ�
#===========================================================
set val(chan)	    Channel/WirelessChannel       ;# channel type
set val(prop)		Propagation/TwoRayGround  	;#radio-propagation model
set val(netif)		Phy/WirelessPhy          		;# network interface type
set val(mac)		Mac/802_11               	;# MAC type
set val(ifq) 		Queue/DropTail/PriQueue   	;# interface queue type
set val(ll)          LL                        ;# link layer type
set val(ant)        Antenna/OmniAntenna       	;# antenna model (�ѽu�ҫ�)
set val(x) 	    1000			            ;#�ݾ�d��:X
set val(y) 	    1000			            ;#�ݾ�d��:Y
set val(ifqlen)     50                    		;# max packet in ifq
set val(nn)        3                           ;# number of mobile nodes 
set val(seed)	    0.0
set val(stop)	    1000.0			             ;# simulation time
set val(tr)	        exp.tr			             ;# trace file name
set val(rp)        DSDV                 		 ;# routing protocol 

# Initialize Global Variables
set ns_		[new Simulator]

# Open trace file �}��trace file
$ns_ use-newtrace                          
set namfd 	[open nam-exp.tr w]
$ns_ namtrace-all-wireless $namfd $val(x) $val(y)
set tracefd     [open $val(tr) w]
$ns_ trace-all $tracefd

# set up topography object 
#�إߤ@�өݾ몫��,�H����mobilenodes�b�ݾ뤺���ʪ����p
set topo       [new Topography]

# �ݾ몺�d�� 1000m x 1000m
$topo load_flatgrid $val(x) $val(y)

# create channel 
set chan [new $val(chan)]

# Create God
set god_ [create-god $val(nn)]

#  Create the specified number of mobile nodes [$val(nn)] and "attach" them
#  to the channel. Three nodes are created : node(0), node(1) and node(2)
#  �]�mMobile node���Ѽ�
	$ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channel $chan \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace OFF \
			 -movementTrace OFF			
			 
	for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]	
		$node_($i) random-motion 0		;# disable random motion
	}

# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#
# �]�w�`�I0�b�@�}�l�ɡA��m�b(350.0, 500.0)
$node_(0) set X_ 350.0
$node_(0) set Y_ 500.0
$node_(0) set Z_ 0.0

# �]�w�`�I1�b�@�}�l�ɡA��m�b(500.0, 500.0)
$node_(1) set X_ 500.0
$node_(1) set Y_ 500.0
$node_(1) set Z_ 0.0

# �]�w�`�I2�b�@�}�l�ɡA��m�b(650.0, 500.0)
$node_(2) set X_ 650.0
$node_(2) set Y_ 500.0
$node_(2) set Z_ 0.0

# Load the god object with shortest hop information
# �b�`�I1�M�`�I2�����̵u��hop�Ƭ�1
$god_ set-dist 1 2 1

# �b�`�I0�M�`�I2�����̵u��hop�Ƭ�2
$god_ set-dist 0 2 2

# �b�`�I0�M�`�I1�����̵u��hop�Ƭ�1
$god_ set-dist 0 1 1

# Now produce some simple node movements
# Node_(1) starts to move upward and then downward
set god_ [God instance]

# �b�����ɶ�200���ɭԡA�`�I1�}�l�q��m(500, 500)���ʨ�(500, 900)�A
# �t�׬�2.0 m/sec
$ns_ at 200.0 "$node_(1) setdest 500.0 900.0 2.0"

# �M��b500���ɭԡA�A�q��m(500, 900)���ʨ�(500, 100)�A�t�׬�2.0 m/sec
$ns_ at 500.0 "$node_(1) setdest 500.0 100.0 2.0"

# Setup traffic flow between nodes   0 connecting to 2 at time 100.0
# �b�`�I0�M�`�I2�إߤ@��CBR/UDP���s�u�A�B�b�ɶ���100��}�l�ǰe
set udp_(0) [new Agent/mUDP]
#�]�w�ǰe�O�����ɦW��sd_udp
$udp_(0) set_filename sd_udp
$udp_(0) set fid_ 1
$ns_ attach-agent $node_(0) $udp_(0)
set null_(0) [new Agent/mUdpSink]
#�]�w�����ɰO�����ɦW��rd_udp
$null_(0) set_filename rd_udp
$ns_ attach-agent $node_(2) $null_(0)

set cbr_(0) [new Application/Traffic/CBR]
$cbr_(0) set packetSize_ 200
$cbr_(0) set interval_ 2.0
$cbr_(0) set random_ 1
$cbr_(0) set maxpkts_ 10000
$cbr_(0) attach-agent $udp_(0)
$ns_ connect $udp_(0) $null_(0)
$ns_ at 100.0 "$cbr_(0) start"

#Define node initial position in nam, only for nam
# �bnam���w�q�`�I��l�Ҧb��m
for {set i 0} {$i < $val(nn)} {incr i} {
	# The function must be called after mobility model is defined.
	$ns_ initial_node_pos $node_($i) 60
}

# Tell nodes when the simulation ends
# �]�w�`�I���������ɶ�
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop)  "$node_($i) reset";
}
$ns_ at $val(stop)  "stop"
$ns_ at $val(stop)  "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd namfd
    $ns_ flush-trace
    close $tracefd
    close $namfd
}
puts "Starting Simulation..."
$ns_ run

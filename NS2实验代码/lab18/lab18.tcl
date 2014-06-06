#�������ݾ�
#���u�����`�I--->(��a�x)---->�L�u�����`�I

#�]�w���������ɶ�
set opt(stop) 250

#�]�wbase station���ƥ�
set opt(num_FA) 1

#Ū���ϥΪ̳]�w���Ѽ�
proc getopt {argc argv} {
	global opt
        lappend optlist nn
        for {set i 0} {$i < $argc} {incr i} {
		set opt($i) [lindex $argv $i]
	}
}

getopt $argc $argv

set pGG $opt(0)
set pBB $opt(1)
set pG $opt(2)
set pB $opt(3)
set loss_model  $opt(4)
#comm_type�O�Ψӳ]�w��ʥ]�i�J�L�u������,�n��unicast�٬Omulticast�ǰe
#0:multicast, 1:unicast
set comm_type  $opt(5)
#���ͤ@�Ӽ���������
set ns_ [new Simulator]

#�]�w�̦h���Ǧ���
Mac/802_11 set LongRetryLimit_    4

#�Y����������,�O��ª����u����,�εL�u����,�w�}����O�ϥ�flat�Y�i(default�]�w)
#���O�Y�]�t�F���u�����M�L�u����,�h�N�ݭn�ϥ�hierarchial addressing���覡�w�}
$ns_ node-config -addressType hierarchical

#�]�w�����domain(�Ĥ@��domain�O���u����,�ĤG�ӬO�L�u����)
AddrParams set domain_num_ 2

#�C��domain�U���@��cluster(�C�@��domain�u�]�t�@�Ӥl����)
lappend cluster_num 1 1
AddrParams set cluster_num_ $cluster_num

#�Ӧb�Ĥ@��domain,��Ĥ@��cluster��,�u���@�Ӧ��u�����`�I
#�Ӧb�a�G��domain,��Ĥ@��cluster��,�|����ӵL�u�����`�I,��a�x��L�u�`�I
lappend eilastlevel 1 2
AddrParams set nodes_num_ $eilastlevel

#�]�w�O����,������L�{���O���U��
set tracefd [open test.tr w]
$ns_ trace-all $tracefd

#�]�wmobile host���Ӽ�
set opt(nnn) 1

# �ݾ몺�d�� 100m x 100m
set topo [new Topography]
$topo load_flatgrid 100 100

#create god
#create-god�n�]�w��a�x�Ӽ�+mobile host�Ӽ�
set god_ [create-god [expr $opt(nnn)+$opt(num_FA)]]

#���u�`�I����}
#�]�����`�I�O�ݩ�Ĥ@��domain,�Ĥ@��cluster�����Ĥ@�Ӹ`�I,
#�ҥH��}��0.0.0 (�q0�}�l��_)
set W(0) [$ns_ node 0.0.0]

# create channel 
set chan_ [new Channel/WirelessChannel]

#�]�w�`�I�Ѽ�
$ns_ node-config -mobileIP ON \
	         -adhocRouting NOAH \
             	 -llType LL \
               	 -macType Mac/802_11 \
                 -ifqType Queue/DropTail/PriQueue \
                 -ifqLen  2000 \
                 -antType Antenna/OmniAntenna \
	         -propType Propagation/TwoRayGround \
	         -phyType Phy/WirelessPhy \
                 -channel $chan_ \
	         -topoInstance $topo \
                 -wiredRouting ON\
	         -agentTrace ON \
                 -routerTrace ON \
                 -macTrace ON

#�]�w��a�x�`�I
#��a�x�O�ݩ�ĤG��domain,�Ĥ@��cluster�����Ĥ@�Ӹ`�I
#�ҥH���}��1.0.0 (�q0�}�l)
set HA [$ns_ node 1.0.0]
#set HAnetif_ [$HA set netif_(0)]
#$HAnetif_ set-error-level $pGG $pBB $pG $pB $loss_model

#�]�wmobile host���Ѽ�
#���ݭnwired routing,�ҥH�⦹�\��off
$ns_ node-config -wiredRouting OFF

#Mobile host�O�ݩ�ĤG��domain,�Ĥ@��cluster�����ĤG�Ӹ`�I
#�ҥH���}��1.0.1 (�q0�}�l)
set MH(0) [$ns_ node 1.0.1]

#�]�wMH(0)��physical layer�s���I
set MHnetif_(0) [$MH(0) set netif_(0)]

#�b�����ݪ�Physical layer�]�wpacket error rate�Mpacket error model
$MHnetif_(0) set-error-level $pGG $pBB $pG $pB $loss_model

#�⦹mobile host��e������a�x���s��
[$MH(0)  set regagent_] set home_agent_ [AddrParams addr2id [$HA node-addr]]

#�]�w��a�x����m�b(100.0, 100.0)
$HA set X_ 100.0
$HA set Y_ 100.0
$HA set Z_ 0.0

#�]�wmobile host����m�b(80.0, 80.0)
$MH(0) set X_ 80.0
$MH(0) set Y_ 80.0
$MH(0) set Z_ 0.0

#�b���u�`�I�M��a�x�����إߤ@���s�u
$ns_ duplex-link $W(0) $HA 10Mb 10ms DropTail

$ns_ at $opt(stop).1 "$MH(0) reset";
$ns_ at $opt(stop).0001 "$W(0) reset"

#�إߤ@��CBR�����ε{�� (wired node ---> base station)
set udp0 [new Agent/mUDP]
$udp0 set_filename sd
$udp0 set packetSize_ 1000
$ns_ attach-agent $W(0) $udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set rate_ 500kb
$cbr0 set packetSize_ 1000
set null0 [new Agent/mUdpSink]
$null0 set_filename rd
$MH(0) attach $null0 3

#���a�x����cbr�ʥ]��,�i�H�ھڨϥΪ̳]�w�Hunicast��multicast��e�ʥ]��mobile host
set forwarder_ [$HA  set forwarder_]
puts [$forwarder_ port]
$ns_ connect $udp0 $forwarder_
$forwarder_ dst-addr [AddrParams addr2id [$MH(0) node-addr]]
$forwarder_ comm-type $comm_type

#�b2.4���,�}�l�e�Xcbr�ʥ]
$ns_ at 2.4 "$cbr0 start"

#�b200.0���,����ǰe
$ns_ at 200.0 "$cbr0 stop"

$ns_ at $opt(stop).0002 "stop "
$ns_ at $opt(stop).0003  "$ns_  halt"

#�]�w�@��stop���{�� 
proc stop {} {
    global ns_ tracefd
    
    #�����O���� 
    close $tracefd
}

#�������
$ns_ run

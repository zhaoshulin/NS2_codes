# ���ͤ@�Ӽ���������
set ns [new Simulator]

#�}�Ҥ@��trace file�A�ΨӰO���ʥ]�ǰe���L�{
set nd [open out.tr w]
$ns trace-all $nd

#�}�ҤT���ɮץΨӰO���T��TCP Connection��cwnd�ܤƱ��p
set f0 [open cwnd0.tr w]
set f1 [open cwnd1.tr w]
set f2 [open cwnd2.tr w]

#�w�q�@�ӵ������{��
proc finish {} {
        global ns nd f0 f1 f2
        $ns flush-trace
        
	#�����ɮ�
        close $nd
        close $f0
        close $f1
        close $f2
        exit 0
}

#�w�q�@�ӰO�����{��
#�C��0.01��N�h�O����ɪ�cwnd
proc record {tcp_} {
	global ns f0 f1 f2
	upvar $tcp_ tcp
	
	set now [$ns now]
	puts $f0 "$now [$tcp(0) set cwnd_]"
	puts $f1 "$now [$tcp(1) set cwnd_]"
	puts $f2 "$now [$tcp(2) set cwnd_]"
	
	$ns at [expr $now+0.01] "record tcp"
}

set r0 [$ns node]
set r1 [$ns node]
$ns duplex-link $r0 $r1 1.5Mb 10ms DropTail
$ns queue-limit $r0 $r1 64

#�إߤT��FTP�s�u
for {set i 0} {$i < 3} {incr i} {
	set s($i) [$ns node]
	set d($i) [$ns node]
	$ns duplex-link $s($i) $r0 10Mb 1ms DropTail
	$ns duplex-link $r1 $d($i) 10Mb 1ms DropTail

	set tcp($i) [new Agent/TCP/Reno]
	set tcpsink($i) [new Agent/TCPSink]
	$ns attach-agent $s($i) $tcp($i)
	$ns attach-agent $d($i) $tcpsink($i)
	$ns connect $tcp($i) $tcpsink($i)
	$tcp($i) set fid_ $i
	$tcpsink($i) set fid_ $i

	$tcp($i) set window_ 128
	$tcp($i) set packetSize_ 536	
	
	set ftp($i) [new Application/FTP]
	$ftp($i) attach-agent $tcp($i)

	#Schedule events for the FTP agents
	$ns at 0 "$ftp($i) start"
	$ns at 40.0 "$ftp($i) stop"
}

$ns at 00.0 "record tcp"
$ns at 40.0 "finish"

#�������
$ns run

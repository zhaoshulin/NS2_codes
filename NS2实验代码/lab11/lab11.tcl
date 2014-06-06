if {$argc !=1} {
	puts "Usage: ns lab11.tcl TCPversion "
	puts "Example:ns lab11.tcl Tahoe or ns lab11.tcl Reno"
	exit
}

set par1 [lindex $argv 0]

# ���ͤ@�Ӽ���������
set ns [new Simulator]

#�}�Ҥ@��trace file�A�ΨӰO���ʥ]�ǰe���L�{
set nd [open out-$par1.tr w]
$ns trace-all $nd

#�}�Ҥ@���ɮץΨӰO��cwnd�ܤƱ��p
set f0 [open cwnd-$par1.tr w]

#�w�q�@�ӵ������{��
proc finish {} {
        global ns nd f0 tcp
        
        #��̫᪺ܳ�����]�R�q
        puts [format "average throughput:%.1f Kbps" \
             [expr [$tcp set ack_]*([$tcp set packetSize_])*8/1000.0/10]]
        $ns flush-trace
	
	#�����ɮ�
        close $nd
        close $f0
        exit 0
}

#�w�q�@�ӰO�����{��
#�C��0.01��N�h�O����ɪ�cwnd
proc record {} {
	global ns tcp f0
	
	set now [$ns now]
	puts $f0 "$now [$tcp set cwnd_]"
	$ns at [expr $now+0.01] "record"
}


#���Ͷǰe�`�I,���Ѿ�r1,r2�M�����`�I
set n0 [$ns node]
set r0 [$ns node]
set r1 [$ns node]
set n1 [$ns node]

#�إ����
$ns duplex-link $n0 $r0 10Mb 1ms DropTail
$ns duplex-link $r0 $r1 1Mb  4ms DropTail
$ns duplex-link $r1 $n1 10Mb 1ms DropTail

#�]�w��C���׬�18�ӫʥ]�j�p
set queue 18
$ns queue-limit $r0 $r1 $queue

#�ھڨϥΪ̪��]�w,���wTCP����
if {$par1=="Tahoe"} {
	set tcp [new Agent/TCP]
} else {
	set tcp [new Agent/TCP/Reno]
}
$ns attach-agent $n0 $tcp

set tcpsink [new Agent/TCPSink]
$ns attach-agent $n1 $tcpsink

$ns connect $tcp $tcpsink

#�إ�FTP���ε{��
set ftp [new Application/FTP]
$ftp attach-agent $tcp

#�b0.0���,�}�l�ǰe
$ns at  0.0 "$ftp start"

#�b10.0���,�����ǰe
$ns at 10.0 "$ftp stop"

#�b0.0��ɥh�I�srecord�ӰO��TCP��cwnd�ܤƱ��p
$ns at 0.0 "record"

#�b��10.0��ɥh�I�sfinish�ӵ�������
$ns at 10.0 "finish"

#�������
$ns run

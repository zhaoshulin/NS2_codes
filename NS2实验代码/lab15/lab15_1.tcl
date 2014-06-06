if {$argc!=1} {
	puts "Usage: ns lab15_1.tcl TCPversion"
	exit
}

set par1 [lindex $argv 0]

# ���ͤ@�Ӽ���������
set ns [new Simulator]

#�}�ҰO���ɡA�ΨӰO���ʥ]�ǰe���L�{
set nd [open out.tr w]
$ns trace-all $nd

#�}�Ҩ���ɮץΨӰO��FTP0�MFTP1��cwnd�ܤƱ��p
set f0 [open cwnd0-rtt-$par1.tr w]
set f1 [open cwnd1-rtt-$par1.tr w]

#�w�q�@�ӵ������{��
proc finish {} {
        global ns nd f0 f1 tcp0 tcp1
        
        #��̫᪺ܳ�����]�R�q
        puts [format "tcp0:\t%.1f Kbps" \
         [expr [$tcp0 set ack_]*([$tcp0 set packetSize_])*8/1000.0/40]]
        puts [format "tcp1:\t%.1f Kbps" \
         [expr [$tcp1 set ack_]*([$tcp1 set packetSize_])*8/1000.0/40]]

        $ns flush-trace
        
	#�����ɮ�
        close $nd
        close $f0
        close $f1

        exit 0
}

#�w�q�@�ӰO�����{��
#�C��0.01��N�h�O����ɪ�tcp0�Mtcp1��cwnd
proc record {} {
	global ns tcp0 f0 tcp1 f1
	
	set now [$ns now]
	puts $f0 "$now [$tcp0 set cwnd_]"
	puts $f1 "$now [$tcp1 set cwnd_]"
	$ns at [expr $now+0.01] "record"
}

#�إ߸`�I
set s0 [$ns node]
set s1 [$ns node]
set d0 [$ns node]
set d1 [$ns node]
set r0 [$ns node]
set r1 [$ns node]
set r2 [$ns node]

#�إ����
$ns duplex-link $s0 $r0 10Mb 1ms DropTail
$ns duplex-link $s1 $r0 10Mb 1ms DropTail
$ns duplex-link $r0 $r1 1.5Mb 40ms DropTail
$ns duplex-link $r1 $r2 1.5Mb 40ms DropTail
$ns duplex-link $r2 $d1 10Mb 1ms DropTail
$ns duplex-link $r1 $d0 10Mb 1ms DropTail

#�]�w��C���׬�32�ӫʥ]�j�p
set buffer_size 32
$ns queue-limit $r0 $r1 $buffer_size

#�إ�FTP0���ε{��(RTT���u)

if {$par1=="Tahoe"} {
	puts "Tahoe"
	set tcp0 [new Agent/TCP]
	set tcpsink0 [new Agent/TCPSink]
} elseif {$par1=="Reno"} {
	puts "Reno"
	set tcp0 [new Agent/TCP/Reno]
	set tcpsink0 [new Agent/TCPSink]
} elseif {$par1=="Newreno"} {
	puts "Newreno"
	set tcp0 [new Agent/TCP/Newreno]
	set tcpsink0 [new Agent/TCPSink]
} elseif {$par1=="Sack"} {
	puts "Sack"
	set tcp0 [new Agent/TCP/Sack1]
	set tcpsink0 [new Agent/TCPSink/Sack1]
} else {
	set tcp0 [new Agent/TCP/Vegas]
	puts "Vegas"
	$tcp0 set v_alpha_ 1
	$tcp0 set v_beta_ 3
	set tcpsink0 [new Agent/TCPSink]
}

$tcp0 set packetSize_ 1024
$tcp0 set window_ 128
$tcp0 set tcpTick_ 0.5
$tcp0 set fid_ 0
$ns attach-agent $s0 $tcp0

$tcpsink0 set fid_ 0
$ns attach-agent $d0 $tcpsink0

$ns connect $tcp0 $tcpsink0

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

#�إ�FTP1���ε{��(RTT����)

if {$par1=="Tahoe"} {
	set tcp1 [new Agent/TCP]
	set tcpsink1 [new Agent/TCPSink]
} elseif {$par1=="Reno"} {
	set tcp1 [new Agent/TCP/Reno]
	set tcpsink1 [new Agent/TCPSink]
} elseif {$par1=="Newreno"} {
	set tcp1 [new Agent/TCP/Newreno]
	set tcpsink1 [new Agent/TCPSink]
} elseif {$par1=="Sack"} {
	set tcp1 [new Agent/TCP/Sack1]
	set tcpsink1 [new Agent/TCPSink/Sack1]
} else {
	set tcp1 [new Agent/TCP/Vegas]
	$tcp1 set v_alpha_ 1
	$tcp1 set v_beta_ 3
	set tcpsink1 [new Agent/TCPSink]
}
$tcp1 set packetSize_ 1024
$tcp1 set window_ 128
$tcp1 set tcpTick_ 0.5
$tcp1 set fid_ 1
$ns attach-agent $s1 $tcp1

$tcpsink1 set fid_ 1
$ns attach-agent $d1 $tcpsink1

$ns connect $tcp1 $tcpsink1

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

#�b0.0���,FTP0�MFTP1�}�l�ǰe
$ns at 0.0 "$ftp0 start"
$ns at 0.0 "$ftp1 start"

#�b40.0���,FTP0�MFTP1�����ǰe
$ns at 40.0 "$ftp0 stop"
$ns at 40.0 "$ftp1 stop"

#�b0.0��ɥh�I�srecord�ӰO��FTP0�MFTP1��cwnd�ܤƱ��p
$ns at  0.0 "record"

#�b��40.0��ɥh�I�sfinish�ӵ�������
$ns at 40.0 "finish"

#�������
$ns run

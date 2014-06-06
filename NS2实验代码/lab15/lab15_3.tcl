if {$argc !=1} {
	puts "Usage: ns lab15_3.tcl Bandwidth(Mbps) "
	exit
}

#���ͤ@�Ӽ���������
set ns [new Simulator]

set bandwidth [lindex $argv 0]

#�C��i�H�B�z���ʥ]��(�tTCP/IP Header)
set mu [expr $bandwidth*1000000/(8*552)]

#Round Trip Time
set tau [expr (1+18+1) * 2 * 0.001]

set beta .64

#�]�wbuffer size��bandwidth-delay product��beta��,
#�H�h�[���W�e���ϥβv�Pssthresh���������Y
set B [expr $beta * ($mu * $tau + 1) + 0.5]

puts "Buffer size=$B"

#�p��bandwidth-delay product
puts "Bandwidth-delay product=[expr $mu * $tau + 1]"

#�}�ҰO���ɡA�ΨӰO���ʥ]�ǰe���L�{
set nd [open out-ssthresh.tr w]
$ns trace-all $nd

set f1 [open sq-ssthresh.tr w]
set f2 [open throughput-ssthresh.tr w]
set f3 [open cwnd-ssthresh.tr w]

#�w�q�@�ӵ������{��
proc finish {} {
        global ns nd f1 f2 tcp0 sink0 bandwidth
        $ns flush-trace
        
	#�����ɮ�
        close $nd
        close $f1
        close $f2

	set now [$ns now]
	set ack [$tcp0 set ack_]
	set size [$tcp0 set packetSize_]
	set throughput [expr $ack*($size)*8/$now/1000000.0]
	set ut [expr ($throughput/$bandwidth)*100.0]
	
	#�p�⥭���]�R�q
	puts [format "throughput=\t%.2f Mbps" $throughput]
	puts [format "utilization=\t%.1f " $ut]
       	exit 0
}

#�w�q�@�ӰO�����{��
#�C��0.05��N�h�O����ɪ�tcp��seqno_, cwnd,�Mthroughput
proc record {} {
	global ns tcp0 sink0 f1 f2 f3
	
	set time 0.05
	set now [$ns now]
	
	set seq [$tcp0 set seqno_]
	set cwnd [$tcp0 set cwnd_]
	set bw [$sink0 set bytes_]
	puts $f1 "$now $seq"
	puts $f2 "$now [expr $bw*8/$now/1000]"
	puts $f3 "$now $cwnd"
	
	$ns at [expr $now+$time] "record"
}
	
#�إ߸`�I
set r0 [$ns node]
set r1 [$ns node]
set n0 [$ns node]
set n1 [$ns node]

#�إ����
set bd $bandwidth+Mb
$ns duplex-link $n0 $r0 100Mb 1ms DropTail
$ns duplex-link $r0 $r1 $bd 18ms DropTail
$ns duplex-link $r1 $n1 100Mb 1ms DropTail
$ns queue-limit $r0 $r1 $B

#�إ�FTP�s�u
set tcp0 [new Agent/TCP/Reno]
$ns attach-agent $n0 $tcp0
$tcp0 set window_ 64
$tcp0 set packetSize_ 512
set sink0 [new Agent/TCPSink]
$ns attach-agent $n1 $sink0
$ns connect $tcp0 $sink0
set ftp [new Application/FTP]
$ftp attach-agent $tcp0

$ns at 0.0 "$ftp start"
$ns at 30.0 "$ftp stop"
$ns at 0.05 "record"
$ns at 30.0 "finish"

#�������
$ns run

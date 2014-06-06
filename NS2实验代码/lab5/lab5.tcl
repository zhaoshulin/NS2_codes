#�ϥΤ�k: ns lab5.tcl on-off��Ƭy�Ѽ� �ĴX������
#�Ҧp: ns lab5.tcl 100 1 (rate_�]�w��100k, �Ĥ@������)

if {$argc !=2} {
	puts "Usage: ns lab5.tcl rate_ no_"
	exit
}

set par1 [lindex $argv 0]
set par2 [lindex $argv 1]

# ���ͤ@�Ӽ���������
set ns [new Simulator]

#�}�Ҥ@��trace file�A�ΨӰO���ʥ]�ǰe���L�{
set nd [open out$par1-$par2.tr w]
$ns trace-all $nd

#�w�q�@�ӵ������{��
proc finish {} {
        global ns nd
        $ns flush-trace
        close $nd 
        exit 0
}

#���ͤ��Ӻ����`�I
set s1 [$ns node]
set s2 [$ns node]
set s3 [$ns node]
set d1 [$ns node]
set d2 [$ns node]
set d3 [$ns node]

#���ͨ�Ӹ��Ѿ�
set r1 [$ns node]
set r2 [$ns node]

#��`�I�M���Ѿ��s���_��
$ns duplex-link $s1 $r1 10Mb 1ms DropTail
$ns duplex-link $s2 $r1 10Mb 1ms DropTail
$ns duplex-link $s3 $r1 10Mb 1ms DropTail
$ns duplex-link $r1 $r2 1Mb 10ms DropTail
$ns duplex-link $r2 $d1 10Mb 1ms DropTail
$ns duplex-link $r2 $d2 10Mb 1ms DropTail
$ns duplex-link $r2 $d3 10Mb 1ms DropTail

#�]�wr1��r2������Queue Size��10�ӫʥ]�j�p
#$ns queue-limit $r1 $r2 10

#�إߤ@��s1-d1��TCP�s�u(FTP���ε{��)
set tcp1 [new Agent/TCP]
$ns attach-agent $s1 $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $d1 $sink1
$ns connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP
 
#�إߤ@��s2-d2��TCP�s�u(FTP���ε{��):�z�Z��Ƭy
set tcp2 [new Agent/TCP]
$ns attach-agent $s2 $tcp2
set sink2 [new Agent/TCPSink]
$ns attach-agent $d2 $sink2
$ns connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ftp2 set type_ FTP

#�إߤ@��on-off���z�Z��Ƭy,�㦳exponential distribution,�������ʥ]�j�p��1000bytes
#burst time:0.5��, idle time:0��,rate:���ϥΪ̳]�w���ǰe�t��
set udp [new Agent/UDP]
$ns attach-agent $s3 $udp
set null [new Agent/Null] 
$ns attach-agent $d3 $null
$ns connect $udp $null
set traffic [new Application/Traffic/Exponential]
$traffic set	packetSize_	1000
$traffic set	burst_time_	0.5
$traffic set	idle_time_	0
$traffic set 	rate_	[expr $par1*1000]
$traffic attach-agent $udp

#���C���Ҳ��ͪ��üƳ����ۦP
set rng [new RNG]
$rng seed 0

set RVstart [new RandomVariable/Uniform]
$RVstart set min_ 3
$RVstart set max_ 4
$RVstart use-rng $rng

#�ѶüƲ��;��h�M�w�Ĥ@��flow���_�l�ɶ�(�b3~4����)
set startT [expr [$RVstart value]]
puts "startT $startT sec"

#�����z�Z����Ƭy���Ӻ������귽
$ns at 0.0 "$ftp2 start"
$ns at 0.0 "$traffic start"
$ns at $startT "$ftp1 start"

$ns at 11.0 "$ftp1 stop"
$ns at 11.5 "$ftp2 stop"
$ns at 11.5 "$traffic stop"

#�b��12��ɥh�I�sfinish�ӵ�������
$ns at 12.0 "finish"

#�������
$ns run





set ns [new Simulator]

#�}�Ҥ@��trace file�A�ΨӰO���ʥ]�ǰe���L�{
set nd [open out.tr w]
$ns trace-all $nd

#�]�wTCP flow���ƥ�
set nflow	3

#�]�w���Ѿ�
set r1 [$ns node]
set r2 [$ns node]
$ns duplex-link $r1 $r2 1Mb 10ms DropTail

#�]�wTCP�ӷ��`�I
#�]�wTCP�ت��`�I
#�إߨӷ��M�ت��`�I�P���Ѿ������
for {set i 1} { $i <= $nflow } { incr i } {

	set s($i) [$ns node]
	set d($i) [$ns node]
	
	$ns duplex-link $s($i) $r1 10Mb 1ms DropTail 
	$ns duplex-link $r2 $d($i) 10Mb 1ms DropTail
}

#�إ�TCP���s�u,�æbTCP�s�u�W�إ�FTP���ε{��
for {set i 1} {$i <= $nflow} {incr i} {
	
        set tcp($i) [new Agent/TCP]
        set sink($i) [new Agent/TCPSink]
        $ns attach-agent $s($i) $tcp($i)
        $ns attach-agent $d($i) $sink($i)
        $ns connect $tcp($i) $sink($i)
	
        set ftp($i) [new Application/FTP]
        $ftp($i) attach-agent $tcp($i)
        $ftp($i) set type_ FTP
}



set rng [new RNG]
$rng seed 1

set RVstart [new RandomVariable/Uniform]
$RVstart set min_ 0
$RVstart set max_ 1
$RVstart use-rng $rng

#�ѶüƲ��;��h�M�w�C�@��flow���_�l�ɶ�(�b0��1����)
#�C��flow�ǿ�5��
#�æb���w���ɶ�,��ftp�}�l�ǿ�M����
for {set i 1} { $i <= $nflow } { incr i } {
	
	set startT($i) [expr [$RVstart value]]
	puts "startT($i) $startT($i) sec"

	set endT($i) [expr ($startT($i)+5)]
	puts "endT($i) $endT($i) sec"

	$ns at $startT($i) "$ftp($i) start"
	$ns at $endT($i) "$ftp($i) stop"
}

proc finish {} {
    global ns nd
    
    close $nd
    $ns flush-trace

    exit 0
}

#�b��7��ɥh�I�sfinish�ӵ�������
$ns at 7.0 "finish"

#�������
$ns run

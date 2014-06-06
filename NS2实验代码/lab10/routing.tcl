set ns [new Simulator]

#�Y�O�ϥΪ̦����w�ϥζZ���۶q(distance vector)�t��k���ʺA���Ѥ覡
#�h�]�w���Ѫ��覡��DV
if {$argc==1} {
	set par [lindex $argv 0]
	if {$par=="DV"} {
		$ns rtproto DV
	}
}

#�]�w��ƶǰe��,�H�Ŧ��ܩҶǰe���ʥ]
$ns color 1 Blue

#Open the NAM trace file
set file1 [open out.nam w]
$ns namtrace-all $file1

#�w�q�����{��
proc finish {} {
        global ns file1
        $ns flush-trace
        close $file1
        exec nam out.nam &
        exit 0
}

#���ͤ��Ӹ`�I
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

#��`�I�M���Ѿ��s���_��
$ns duplex-link $n0 $n1 0.5Mb 10ms DropTail
$ns duplex-link $n1 $n2 0.5Mb 10ms DropTail
$ns duplex-link $n1 $n3 0.5Mb 10ms DropTail
$ns duplex-link $n3 $n4 0.5Mb 10ms DropTail
$ns duplex-link $n3 $n2 0.5Mb 10ms DropTail

#�]�w�`�I�bnam���Ҧb����m���Y
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n1 $n3 orient down
$ns duplex-link-op $n3 $n4 orient right
$ns duplex-link-op $n3 $n2 orient right-up
 
#�إ�TCP�s�u
set tcp [new Agent/TCP]
$tcp set fid_ 1
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n4 $sink
$ns connect $tcp $sink

#�إ�FTP���ε{����Ƭy
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

#�]�w�b1.0���,n1��n3��������o�Ͱ��D
$ns rtmodel-at 1.0 down $n1 $n3

#�]�w�b2.0���,n1��n3��������S��_���`
$ns rtmodel-at 2.0 up $n1 $n3

#�b0.1���,FTP�}�l�ǰe���
$ns at 0.1 "$ftp start"

#�b3.0���,�����ǰe���
$ns at 3.0 "finish"

#�����}�l
$ns run

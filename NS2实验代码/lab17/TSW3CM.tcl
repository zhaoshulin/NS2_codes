# ��@��: Jeremy Ethridge,
# ��Ч@���: June 15-July 5, 1999.
# ����: A DS-RED script that uses CBR traffic agents and the TSW3CM Policer.

# ���ͤ@�Ӽ���������
set ns [new Simulator]

#�}�Ҥ@��trace file�A�ΨӰO���ʥ]�ǰe���L�{
set nd [open tsw3cm.tr w]
$ns trace-all $nd

#�]�wTSWTCM���Ѽ�,�bNS2��TSWTCM�W�٬OTSW3CM
#�]�w�Ĥ@�Ӥ��ժ�CIR��1500000 bps, PIR ��3000000 bps
#�]�w�ĤG�Ӥ��ժ�CIR��1000000 bps, PIR ��2000000 bps
#�]�w�Ĥ@�Ӥ��ժ�CBR���ǰe�t�v��4000000 bps, �ĤG�ժ���4000000 bps
set cir0  1500000
set pir0  3000000
set rate0 4000000
set cir1  1000000
set pir1  2000000
set rate1 4000000

#�����ɶ���85��,�C�Ӷǰe��CBR���ʥ]�j�p��1000 byte
set testTime 85.0
set packetSize 1000

# �]�w���������[�c
set s1 [$ns node]
set s2 [$ns node]
set e1 [$ns node]
set core [$ns node]
set e2 [$ns node]
set dest [$ns node]

$ns duplex-link $s1 $e1 10Mb 5ms DropTail
$ns duplex-link $s2 $e1 10Mb 5ms DropTail

#���we1����Ҹ��Ѿ�,core���֤߸��Ѿ�
$ns simplex-link $e1 $core 10Mb 5ms dsRED/edge
$ns simplex-link $core $e1 10Mb 5ms dsRED/core

#���we2����Ҹ��Ѿ�
$ns simplex-link $core $e2 5Mb 5ms dsRED/core
$ns simplex-link $e2 $core 5Mb 5ms dsRED/edge

$ns duplex-link $e2 $dest 10Mb 5ms DropTail

#�]�w�bnam���`�I����m���Y��
$ns duplex-link-op $s1 $e1 orient down-right
$ns duplex-link-op $s2 $e1 orient up-right
$ns duplex-link-op $e1 $core orient right
$ns duplex-link-op $core $e2 orient right
$ns duplex-link-op $e2 $dest orient right

#�]�w��C�W��
set qE1C [[$ns link $e1 $core] queue]
set qE2C [[$ns link $e2 $core] queue]
set qCE1 [[$ns link $core $e1] queue]
set qCE2 [[$ns link $core $e2] queue]

#�]�we1��core���Ѽ�
$qE1C meanPktSize $packetSize

#�]�w�@��physical queue
$qE1C set numQueues_ 1

#�]�w�T��virtual queue
$qE1C setNumPrec 3

#�]�w�qs1��dest���Ĥ@�Ӥ���,�ĥ�TSW3CM
#�ç�ŦX�зǪ��ʥ]�Ц����(10)
$qE1C addPolicyEntry [$s1 id] [$dest id] TSW3CM 10 $cir0 $pir0

#�]�w�qs2��dest���ĤG�Ӥ���,�ĥ�TSW3CM
#�ç�ŦX�зǪ��ʥ]�Ц����(10)
$qE1C addPolicyEntry [$s2 id] [$dest id] TSW3CM 10 $cir1 $pir1

#�⤣�ŦX�зǪ��ʥ]�е�������(11)�M����(12)
$qE1C addPolicerEntry TSW3CM 10 11 12

#����(10)���ʥ]���Ĥ@�ӹ�ڦ�C��(0)���Ĥ@�ӵ�����C(0)
$qE1C addPHBEntry 10 0 0

#�����(11)���ʥ]���Ĥ@�ӹ�ڦ�C��(0)���ĤG�ӵ�����C(1)
$qE1C addPHBEntry 11 0 1

#�����(12)���ʥ]���Ĥ@�ӹ�ڦ�C��(0)���ĤT�ӵ�����C(2)
$qE1C addPHBEntry 12 0 2

#�]�w�Ĥ@�ӹ�ڦ�C��(0)���Ĥ@�ӵ�����C(0)��RED�Ѽ�
#{min, max, max drop probability} = {20 packets, 40 packets, 0.02}
$qE1C configQ 0 0 20 40 0.02

#�]�w�Ĥ@�ӹ�ڦ�C��(0)���ĤG�ӵ�����C(1)��RED�ѼƬ�{10, 20, 0.1}
$qE1C configQ 0 1 10 20 0.10

#�]�w�Ĥ@�ӹ�ڦ�C��(0)���ĤG�ӵ�����C(2)��RED�ѼƬ�{5, 10, 0.20}
$qE1C configQ 0 2  5 10 0.20

#�]�we2��core���Ѽ�
$qE2C meanPktSize $packetSize
$qE2C set numQueues_ 1
$qE2C setNumPrec 3
$qE2C addPolicyEntry [$dest id] [$s1 id] TSW3CM 10 $cir0 $pir0
$qE2C addPolicyEntry [$dest id] [$s2 id] TSW3CM 10 $cir1 $pir1
$qE2C addPolicerEntry TSW3CM 10 11 12
$qE2C addPHBEntry 10 0 0
$qE2C addPHBEntry 11 0 1
$qE2C addPHBEntry 12 0 2
$qE2C configQ 0 0 20 40 0.02
$qE2C configQ 0 1 10 20 0.10
$qE2C configQ 0 2  5 10 0.20

#�]�wcore��e1���Ѽ�
$qCE1 meanPktSize $packetSize
$qCE1 set numQueues_ 1
$qCE1 setNumPrec 3
$qCE1 addPHBEntry 10 0 0
$qCE1 addPHBEntry 11 0 1
$qCE1 addPHBEntry 12 0 2
$qCE1 configQ 0 0 20 40 0.02
$qCE1 configQ 0 1 10 20 0.10
$qCE1 configQ 0 2  5 10 0.20

#�]�wcore��e2���Ѽ�
$qCE2 meanPktSize $packetSize
$qCE2 set numQueues_ 1
$qCE2 setNumPrec 3
$qCE2 addPHBEntry 10 0 0
$qCE2 addPHBEntry 11 0 1
$qCE2 addPHBEntry 12 0 2
$qCE2 configQ 0 0 20 40 0.02
$qCE2 configQ 0 1 10 20 0.10
$qCE2 configQ 0 2  5 10 0.20

#�]�ws1��dest��CBR�Ѽ�
set udp0 [new Agent/UDP]
$ns attach-agent $s1 $udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$udp0 set class_ 1
$cbr0 set packet_size_ $packetSize
$udp0 set packetSize_ $packetSize
$cbr0 set rate_ $rate0
set null0 [new Agent/Null]
$ns attach-agent $dest $null0
$ns connect $udp0 $null0

#�]�ws2��dest��CBR�Ѽ�
set udp1 [new Agent/UDP]
$ns attach-agent $s2 $udp1
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$udp1 set class_ 2
$cbr1 set packet_size_ $packetSize
$udp1 set packetSize_ $packetSize
$cbr1 set rate_ $rate1
set null1 [new Agent/Null]
$ns attach-agent $dest $null1
$ns connect $udp1 $null1

#�w�q�@�ӵ������{��
proc finish {} {
        global ns nd
        $ns flush-trace
        close $nd 
        exit 0
}

#��ܦbe1��SLA
$qE1C printPolicyTable
$qE1C printPolicerTable

$ns at 0.0 "$cbr0 start"
$ns at 0.0 "$cbr1 start"
$ns at $testTime "$cbr0 stop"
$ns at $testTime "$cbr1 stop"
$ns at [expr $testTime + 1.0] "finish"

$ns run

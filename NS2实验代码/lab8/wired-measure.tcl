# ���ͤ@�Ӽ���������
set ns [new Simulator]

#�w�藍�P����Ƭy�w�q���P���C��A�o�O�n��NAM�Ϊ�
$ns color 1 Blue
$ns color 2 Red

#�}�Ҥ@��NAM �O����
set nf [open out.nam w]
$ns namtrace-all $nf

#�}�Ҥ@�Ӽ����L�{�O���ɡA�ΨӰO���ʥ]�ǰe���L�{
set nd [open out.tr w]
$ns trace-all $nd

#�w�q�@�ӵ������{��
proc finish {} {
        global ns nf nd
        $ns flush-trace
        close $nf
        close $nd 
        #�H�I�����檺�覡�h����NAM
        #exec nam out.nam &
        exit 0
}

#���Ͷǿ�`�I, s1��id��0, s2��id��1
set s1 [$ns node]
set s2 [$ns node]

#���͸��Ѿ��`�I, r��id��2
set r [$ns node]

#���͸�Ʊ����`�I, d��id��3
set d [$ns node]

#s1-r������㦳2Mbps���W�e,10ms���ǻ�����ɶ�,DropTail����C�޲z�覡
#s2-r������㦳2Mbps���W�e,10ms���ǻ�����ɶ�,DropTail����C�޲z�覡
#r-d������㦳1.7Mbps���W�e,20ms���ǻ�����ɶ�,DropTail����C�޲z�覡

$ns duplex-link $s1 $r 2Mb 10ms DropTail
$ns duplex-link $s2 $r 2Mb 10ms DropTail
$ns duplex-link $r $d 1.7Mb 20ms DropTail

#�]�wr��d������Queue Limit��10�ӫʥ]�j�p
$ns queue-limit $r $d 10

#�]�w�`�I����m�A�o�O�n��NAM�Ϊ�
$ns duplex-link-op $s1 $r orient right-down
$ns duplex-link-op $s2 $r orient right-up
$ns duplex-link-op $r $d orient right

#�[��r��d����queue���ܤơA�o�O�n��NAM�Ϊ�
$ns duplex-link-op $r $d queuePos 0.5

#�إߤ@��TCP���s�u
set tcp [new Agent/TCP]
$ns attach-agent $s1 $tcp
# mTcpSink�OTCPsink�����ӡA���F�㦳TCPSink���\��~�A�]��O���Ұe�X�ʥ]��T
set sink [new Agent/TCPSink/mTcpSink]
#�]�wtcp�����O���ɪ��ɦW��tcp_sink
$sink set_filename tcp_sink
$ns attach-agent $d $sink
$ns connect $tcp $sink
#�bNAM���ATCP���s�u�|�H�Ŧ���
$tcp set fid_ 1

#�bTCP�s�u���W�إ�FTP���ε{��
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

#�إߤ@��mUDP���s�u
#mUDP�OUDP�����ӡA���F�㦳UDP���\��~�A�]��O���Ұe�X�ʥ]��T
set udp [new Agent/mUDP]
#�]�w�ǰe�O�����ɦW��sd_udp
$udp set_filename sd_udp
$ns attach-agent $s2 $udp
#�s�W������Agent�A�i�H�Ⱶ���ʥ]��T�O�����ɮפ�
set null [new Agent/mUdpSink]
#�]�w�����ɰO�����ɦW��rd_udp
$null set_filename rd_udp
$ns attach-agent $d $null
$ns connect $udp $null
#�bNAM���AUDP���s�u�|�H������
$udp set fid_ 2

#�bUDP�s�u���W�إ�CBR���ε{��
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
#�]�w�ǰe�ʥ]���j�p��1000 byte
$cbr set packet_size_ 1000
#�]�w�ǰe���t�v��1Mbps
$cbr set rate_ 1mb
$cbr set random_ false

#�]�wFTP�MCBR��ƶǰe�}�l�M�����ɶ�
$ns at 0.1 "$cbr start"
$ns at 1.0 "$ftp start"
$ns at 4.0 "$ftp stop"
$ns at 4.5 "$cbr stop"

#����TCP���s�u(���@�w�ݭn�g�U�����{���X�ӹ�ڵ����s�u)
$ns at 4.5 "$ns detach-agent $s1 $tcp ; $ns detach-agent $d $sink"

#�b�������Ҥ��A5���h�I�sfinish�ӵ�������(�o�˭n�`�N�������Ҥ�
#��5��ä��@�w�����ڼ������ɶ�
$ns at 5.0 "finish"

#�������
$ns run

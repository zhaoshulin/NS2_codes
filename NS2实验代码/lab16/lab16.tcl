#
# Copyright (c) Xerox Corporation 1997. All rights reserved.
#
# License is granted to copy, to use, and to make and to use derivative
# works for research and evaluation purposes, provided that Xerox is
# acknowledged in all documentation pertaining to any such copy or
# derivative work. Xerox grants no other licenses expressed or
# implied. The Xerox trade name should not be used in any advertising
# without its written permission. 
#
# XEROX CORPORATION MAKES NO REPRESENTATIONS CONCERNING EITHER THE
# MERCHANTABILITY OF THIS SOFTWARE OR THE SUITABILITY OF THIS SOFTWARE
# FOR ANY PARTICULAR PURPOSE.  The software is provided "as is" without
# express or implied warranty of any kind.
#
# These notices must be retained in any copies of any part of this
# software. 
#


# This example script demonstrates using the token bucket filter as a
# traffic-shaper. 
# There are 2 identical source models(exponential on/off) connected to a common
# receiver. One of the sources is connected via a tbf whereas the other one is 
# connected directly.The tbf parameters are such that they shape the exponential
# on/off source to look like a cbr-like source.

#�o�ӽd�ҥD�n�O�b�i�ܦp��ϥΥO�P���Ƭy��ξ����ϥ�
#����ӬۦP�ǰe�ҫ�(exponential on/off)��ƶǰe�ݳ��|���ưe��P�@�ӱ�����
#�ӳo�Ӷǰe�ݤ����@�Ӧb�e�X��ƫe�|���g�L��Τ~�|�e�X���,�t�@�ӫh�����e�X
#�O�P���Ƭy��ξ����ѼƥD�n�N�O�Ʊ��Mexponential on/off����ƶǰe�ݦb
#�e�X��ƪ��欰�๳CBR����,�㦳�T�w�t�v���S��

#���ͤ@�Ӽ���������
set ns [new Simulator]

#���͸`�I
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

#�}�Ҥ@�Ӽ����L�{�O���ɡA�ΨӰO���ʥ]�ǰe���L�{
set f [open out.tr w]
$ns trace-all $f

#�}�Ҥ@��NAM �O����
set nf [open out.nam w]
$ns namtrace-all $nf

#set trace_flow 1

#�w�藍�P����Ƭy�w�q���P���C��A�o�O�n��NAM�Ϊ�
$ns color 0 red
$ns color 1 blue

#�������
$ns duplex-link $n2 $n1 0.2Mbps 100ms DropTail
$ns duplex-link $n0 $n1 0.2Mbps 100ms DropTail

#�]�w�`�I����m�A�o�O�n��NAM�Ϊ�
$ns duplex-link-op $n2 $n1 orient right-down
$ns duplex-link-op $n0 $n1 orient right-up

#�إߤ@��Exponential on/off�����ε{��
set exp1 [new Application/Traffic/Exponential]

#�]�w�ʥ]�j�p
$exp1 set packetSize_ 128

#�]�won���ɶ�
$exp1 set burst_time_ [expr 20.0/64]

#�]�woff���ɶ�
$exp1 set idle_time_ 325ms

#�]�w�t�v
$exp1 set rate_ 65.536k

#�]�wUDP
set a [new Agent/UDP]

#�]�wflow id��1
$a set fid_ 0

$exp1 attach-agent $a

#�]�w�@�ӥO�P���Ƭy��ξ�
set tbf [new TBF]

#�]�w��l�`��
$tbf set bucket_ 1024

#�]�w�O�P�ɥR�t�v
$tbf set rate_ 32.768k

#�]�w�w�İϤj�p (100��packet)
$tbf set qlen_  100

$ns attach-tbf-agent $n0 $a $tbf

#�]�w������
set rcvr [new Agent/SAack]
$ns attach-agent $n1 $rcvr

#�s���ǰe�ݩM������
$ns connect $a $rcvr

#�إߥt�@��Exponential on/off�����ε{��
set exp2 [new Application/Traffic/Exponential]

#�]�w�ʥ]�j�p
$exp2 set packetSize_ 128

#�]�won���ɶ�
$exp2 set burst_time_ [expr 20.0/64]

#�]�woff���ɶ�
$exp2 set idle_time_ 325ms

#�]�w�t�v
$exp2 set rate_ 65.536k

#�]�wUDP
set a2 [new Agent/UDP]

#�]�wflow id��1
$a2 set fid_ 1

$exp2 attach-agent $a2
$ns attach-agent $n2 $a2

#�s���ǰe�ݩM������
$ns connect $a2 $rcvr

#�b0.0���, exp1�Mexp2�}�϶ǰe�ʥ]
$ns at 0.0 "$exp1 start;$exp2 start"

#�b20.0���,exp1�Mexp2����ǰe,�åB�����O����,�̫�A����NAM
$ns at 20.0 "$exp1 stop;$exp2 stop;close $f;close $nf;exec nam out.nam &;exit 0"
$ns run




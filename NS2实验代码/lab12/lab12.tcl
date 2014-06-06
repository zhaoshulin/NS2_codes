if {$argc !=1} {
	puts "Usage: ns lab12.tcl TCPversion "
	puts "Example:ns lab12.tcl Reno or ns lab12.tcl Newreno or ns lab12.tcl Sack"
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
        global ns nd f0 tcp par1
        
        #��̫᪺ܳ�����]�R�q
        puts [format "average throughput: %.1f Kbps" \
        	[expr [$tcp set ack_]*([$tcp set packetSize_])*8/1000.0/10]]
        $ns flush-trace
        
	    #�����ɮ�
        close $nd
        close $f0
      
	    #�ϥ�awk���R�O���ɥH�[���C���ܤ�
    	exec awk {
		BEGIN {
			highest_packet_id = -1;
			packet_count = 0;
			q_eln = 0;
		}
	 
		{
		  action = $1; 
		  time = $2;
		  src_node = $3;	
                  dst_node = $4; 
                  type = $5; 
                  flow_id = $8;  
                  seq_no = $11;
                  packet_id = $12;

		  if (src_node == "0" && dst_node == "1") {
				if (packet_id > highest_packet_id) {
					highest_packet_id = packet_id;
				}
				
                                if (action == "+") {
					q_len++;
					print time, q_len;
				}

				if (action == "-" || action == "d") {
					q_eln = q_len--;
					print time, q_len;
				}
			}
		}
	} out-$par1.tr > queue_length-$par1.tr

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
set r0 [$ns node]
set r1 [$ns node]
set n0 [$ns node]
set n1 [$ns node]

#�إ����
$ns duplex-link $n0 $r0 10Mb 1ms DropTail
$ns duplex-link $r0 $r1 1Mb  4ms DropTail
$ns duplex-link $r1 $n1 10Mb 1ms DropTail

#�]�w��C���׬�15�ӫʥ]�j�p
set buffer_size 15
$ns queue-limit $r0 $r1 $buffer_size

#�ھڨϥΪ̪��]�w,���wTCP����
if {$par1=="Reno"} {
	set tcp [new Agent/TCP/Reno]
	set tcpsink [new Agent/TCPSink]
	$tcp set debug_ 0
} elseif {$par1=="Newreno"} {
	set tcp [new Agent/TCP/Newreno]
	set tcpsink [new Agent/TCPSink]
	$tcp set debug_ 0
} else {
	set tcp [new Agent/TCP/Sack1]
	set tcpsink [new Agent/TCPSink/Sack1]
	$tcp set debug_ 1
}

$ns attach-agent $n0 $tcp	

#�Nawnd���ȳ]��24,�o�Oadvertised window���W��
# advertised window�O�����ݪ��w�İϥi�H�e�Ǫ��ʥ]�ӼơA
#�]����congestion window���ȶW�Ladvertised window�ɡA
#TCP���ǰe�ݷ|����y�q����H�קK�e���ӧ֦ӾɭP�����ݪ��w�İϷ����C
$tcp set window_ 24	

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
$ns at  0.0 "record"

#�b��10.0��ɥh�I�sfinish�ӵ�������
$ns at 10.0 "finish"

#�p��b�ǿ���|�W�j���i�H�e�Ǧh�֪��ʥ]
#�p��覡:�bbottleneck link�W�C��i�H�ǰe���ʥ]��*RTT+��C�w�İϤj�p
puts [format "on path: %.2f packets" \
  [expr (1000000/(8*([$tcp set packetSize_]+40)) * ((1+4+1) * 2 * 0.001)) + $buffer_size]]

#�������
$ns run

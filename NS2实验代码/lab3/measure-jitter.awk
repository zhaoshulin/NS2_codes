#�o�O���qCBR�ʥ]jitter��awk�{��
# jitter ��((recvtime(j)-sendtime(j))-(recvtime(i)-sendtime(i)))/(j-i),�䤤 j>i

BEGIN {
#�{����l�ơA�]�w�@�ܼƥH�O���ثe�̰��B�z�ʥ]��ID�C
     highest_packet_id = 0;
}
{
   action = $1;
   time = $2;
   from = $3;
   to = $4;
   type = $5;
   pktsize = $6;
   flow_id = $8;
   src = $9;
   dst = $10;
   seq_no = $11;
   packet_id = $12;

#�O���ثe�̰���packet ID
   if ( packet_id > highest_packet_id ) {
	   highest_packet_id = packet_id;
	}

#�O���ʥ]���ǰe�ɶ�
   if ( start_time[packet_id] == 0 )  {
	   # �O���U�]��seq_no
	   pkt_seqno[packet_id] = seq_no;
	   start_time[packet_id] = time;
   }

#�O��CBR (flow_id=2) �������ɶ�
   if ( flow_id == 2 && action != "d" ) {
      if ( action == "r" ) {
	     end_time[packet_id] = time;
      }
    } else {
#�⤣�Oflow_id=2���ʥ]�Ϊ̬Oflow_id=2�����ʥ]�Q��󪺮ɶ��]��-1
      end_time[packet_id] = -1;
   }
}							  
END {
	# ��l��jitter�p��һ��ܶq
	last_seqno = 0;
	last_delay = 0;
	seqno_diff = 0;
#���ƦC����Ū������A�}�l�p�⦳�īʥ]�����I����I����ɶ� 
    for ( packet_id = 0; packet_id <= highest_packet_id; packet_id++ ) {
       start = start_time[packet_id];
       end = end_time[packet_id];
       packet_duration = end - start;

#�u�Ⱶ���ɶ��j��ǰe�ɶ����O���C�X��
       if ( start < end ) {
	       # �o��Fdelay��(packet_duration)��p��jitter
	       seqno_diff = pkt_seqno[packet_id] - last_seqno;
	       delay_diff = packet_duration - last_delay;
	       if (seqno_diff == 0) {
		       jitter =0;
	       } else {
		       jitter = delay_diff/seqno_diff;
	       }
	       printf("%f %f\n", start, jitter);
	       last_seqno = pkt_seqno[packet_id];
	       last_delay = packet_duration;
       }
    }
}

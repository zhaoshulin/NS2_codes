#�o�O���qCBR�ʥ]���I����I������ɶ���awk�{��

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
   if ( packet_id > highest_packet_id )
	 highest_packet_id = packet_id;

#�O���ʥ]���ǰe�ɶ�
   if ( start_time[packet_id] == 0 )  
	start_time[packet_id] = time;

#�O��CBR (flow_id=2) �������ɶ�
   if ( flow_id == 2 && action != "d" ) {
      if ( action == "r" ) {
         end_time[packet_id] = time;
      }
   } else {
#�⤣�Oflow_id=2���ʥ]�Ϊ̬Oflow_id=2�����ʥ]�Qdrop���ɶ��]��-1
      end_time[packet_id] = -1;
   }
}							  
END {
#���ƦC����Ū������A�}�l�p�⦳�īʥ]�����I����I����ɶ� 
    for ( packet_id = 0; packet_id <= highest_packet_id; packet_id++ ) {
       start = start_time[packet_id];
       end = end_time[packet_id];
       packet_duration = end - start;

#�u�Ⱶ���ɶ��j��ǰe�ɶ����O���C�X��
       if ( start < end ) printf("%f %f\n", start, packet_duration);
   }
}

#�o�O���qCBR�ʥ]�򥢲v��awk�{��

BEGIN {
#�{����l��,�]�w�@�ܼưO��packet�Qdrop���ƥ�
	fsDrops = 0;
	numFs = 0;
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

#�έp�qn1�e�X�h��packets
	if (from==1 && to==2 && action == "+") 
		numFs++;
	
#�έpflow_id��2,�B�Qdrop���ʥ]
	if (flow_id==2 && action == "d") 
		fsDrops++;
}
END {
	printf("number of packets sent:%d lost:%d\n", numFs, fsDrops);
}

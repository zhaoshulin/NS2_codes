BEGIN {
	init=0;
        startT=0;
	endT=0;
}

{
         action = $1;
         time = $2;
         from = $3;
         to = $4;
         type = $5;
         pktsize = $6;
         flow_id = $8;
         node_1_address = $9;
         node_2_address = $10;
         seq_no = $11;
         packet_id = $12;

#�p��s1-d1�o��flow�b5~10����,d1�����F�h�֪���ƶq.s1��id��7,d1��id��3
         if(action=="r" && type=="tcp" && time >= 5.0 && time <=10.0 && (from==7 && to==3)) {
         	 if(init==0){
         	 	startT=time;
         	 	init=1;
         	 }
         	 
#�O���b�o�q�ɶ������}��C���ʥ]�j�p�`�M (in bytes)
	         pkt_byte_sum += pktsize;
	         endT=time;
         }
    
         
}

END {
#�p��5~10��Throughput
#	printf("\n");
#	printf("startT:%f endT:%f\n", startT, endT);
#	printf("pkt_byte_sum:%d\n", pkt_byte_sum);
	time=endT-startT;
	throughput=pkt_byte_sum*8/time/1000;
#	printf("throughput:%.3f kbps\n", throughput);
	printf("%f\n", throughput);
}


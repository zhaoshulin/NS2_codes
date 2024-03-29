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
         if(action=="r" && type=="tcp" && time >= 1.0 && time <=5.0 && \
         ((from==1 && to==3)||(from==1 && to==5)||(from==1 && to==7))) {
         	 if(init==0){
         	 	startT=time;
         	 	init=1;
         	 }
         	 
	         pkt_byte_sum += pktsize;
	         endT=time;
         }
    
         
}

END {

	printf("startT:%f endT:%f\n", startT, endT);
	printf("pkt_byte_sum:%d\n", pkt_byte_sum);
	time=endT-startT;
	throughput=pkt_byte_sum*8/time/1000000;
	printf("throughput:%.3f Mbps\n", throughput);
}


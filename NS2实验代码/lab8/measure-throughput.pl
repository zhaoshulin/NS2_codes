#�ϥΤ�k: perl measure-throughput.pl <trace file> <granlarity> 

#�O�����ɦW
$infile=$ARGV[0];

#�h�֮ɶ��p��@��(��쬰��)
$granularity=$ARGV[1];

$sum=0;
$sum_total=0;
$clock=0;
$maxrate=0;
$init=0;

#���}�O����
open (DATA,"<$infile")
    || die "Can't open $infile $!";
        
#Ū���O���ɤ����C����,��ƬO�H�ťդ������h���  
while (<DATA>) {
        @x = split(' ');
        
        if($init==0){
          $start=$x[2];
          $init=1;
	}
 
	#Ū�����Ĺs�����Opkt_id
#Ū�����Ĥ@�����O�ʥ]�ǰe�ɶ�
#Ū�����ĤG�����O�ʥ]�����ɶ�
#Ū�����ĤT�����O�ʥ]end to end delay
#Ū�����ĥ|�����O�ʥ]�j�p
	#�P�_��Ū�쪺�ɶ�,�O�_�w�g�F��n�έp�]�R�q���ɭ�
	if ($x[2]-$clock <= $granularity)
	{
		#�p����ɶ����ֿn���ʥ]�j�p
    		$sum=$sum+$x[4];
    		
   		#�p��ֿn���`�ʥ]�j�p
    		$sum_total=$sum_total+$x[4];
	}
	else
	{
		#�p��]�R�q 
	 	$throughput=$sum*8.0/$granularity;
	 	
	 	if ($throughput > $maxrate){
	 		$maxrate=$throughput;
	 	}
	 	
	 	    #��X���G: �ɶ� �]�R�q(bps)
    		print STDOUT "$x[2]: $throughput bps\n";
    		
    		#�]�w�U���n�p��]�R�q���ɶ�
    		$clock=$clock+$granularity;
    		
    		$sum_total=$sum_total+$x[4];
    		$sum=$x[4];
	}
}

$endtime=$x[2];
 
#�p��̫�@�����]�R�q�j�p   
$throughput=$sum*8.0/$granularity;
print STDOUT "$x[2]: $throughput bps\n";
$clock=$clock+$granularity;
$sum=0;
#print STDOUT "$sum_total $start $endtime\n";
$avgrate=$sum_total*8.0/($endtime-$start);
print STDOUT "Average rate: $avgrate bps\n";
print STDOUT "Peak rate: $maxrate bps\n";

#�����ɮ�
close DATA;
exit(0);

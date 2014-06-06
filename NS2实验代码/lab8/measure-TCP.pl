#�ϥΤ�k: perl measure-TCP.pl <trace file> <granlarity> 

#�O�����ɦW
$infile=$ARGV[0];

#�h�֮ɶ��p��@��(��쬰��)
$granularity=$ARGV[1];

$sum=0;
$sum_total=0;
$clock=0;
$init=0;

#���}�O����
open (DATA,"<$infile")
    || die "Can't open $infile $!";
        
#Ū���O���ɤ����C����,��ƬO�H�ťդ������h���  
while (<DATA>) {
        @x = split(' ');
        
        if($init==0){
          $start=$x[1];
          $init=1;
	}

	#Ū�����Ĺs�����Opkt_id
#Ū�����Ĥ@�����O�ʥ]�����ɶ�
#Ū�����ĤG�����O�ʥ]�j�p
#�P�_��Ū�쪺�ɶ�,�O�_�w�g�F��n�έp�]�R�q���ɭ�
	if ($x[1]-$clock <= $granularity)
	{
		#�p����ɶ����ֿn���ʥ]�j�p
    		$sum=$sum+$x[2];

   		#�p��ֿn���`�ʥ]�j�p
    		$sum_total=$sum_total+$x[2];
	}
	else
	{
		#�p��]�R�q 
	 	$throughput=$sum*8.0/$granularity;
	 	
	 	#��X���G: �ɶ� �]�R�q(bps)
    		print STDOUT "$x[1] $throughput\n";
    		
    	#�]�w�U���n�p��]�R�q���ɶ�
    		$clock=$clock+$granularity;		
    	    
            $sum_total=$sum_total+$x[2];
	$sum=$x[2];
	}   
}

$endtime=$x[1];
 
#�p��̫�@�����]�R�q�j�p   
$throughput=$sum*8.0/$granularity;
print STDOUT "$x[1] $throughput\n";
$clock=$clock+$granularity;
$sum=0;
print STDOUT "$sum_total $start $endtime\n";
$avgrate=$sum_total*8.0/($endtime-$start);
print STDOUT "Average rate: $avgrate bps\n";

#�����ɮ�
close DATA;
exit(0);

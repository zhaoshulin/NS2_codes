#�ϥΤ�k: perl throughput.pl <trace file> <flow id> <granlarity> 

#�O�����ɦW
$infile=$ARGV[0];

#�n�p�⥭���t�v��flow id
$flowid=$ARGV[1];

#�h�֮ɶ��p��@��(��쬰��)
$granularity=$ARGV[2];

$sum=0;
$clock=0;

#���}�O����
open (DATA,"<$infile")
    || die "Can't open $infile $!";
        
#Ū���O���ɤ����C����,��ƬO�H�ťդ������h���  
while (<DATA>) {
             @x = split(' ');

	#Ū�����ĤG�����O�ɶ�
	#�P�_��Ū�쪺�ɶ�,�O�_�w�g�F��n�έp�]�R�q���ɭ�
	if ($x[1]-$clock <= $granularity)
	{
		#Ū�����Ĥ@�����O�ʧ@
		#�P�_�ʧ@�O�_�O�`�I�����ʥ]
		if ($x[0] eq 'r') 
		{ 
			#Ū�����ĤK�����Oflow id
			#�P�_flow id�O�_�����w��id
			if ($x[7] eq $flowid) 
			{ 
    				#�p��ֿn���ʥ]�j�p
    				$sum=$sum+$x[5];
			}
		}
	}
	else
	{
		#�p��]�R�q 
	 	$throughput=$sum*8.0/$granularity;
	 	
	 	#��X���G: �ɶ� �]�R�q(bps)
    		print STDOUT "$x[1]: $throughput bps\n";
    		
    		#�]�w�U���n�p��]�R�q���ɶ�
    		$clock=$clock+$granularity;
    		
    		#��ֿn�q�W�s
    		$sum=0;
	}   
}
 
#�p��̫�@�����]�R�q�j�p   
$throughput=$sum*8.0/$granularity;
print STDOUT "$x[1]: $throughput bps\n";
$clock=$clock+$granularity;
$sum=0;

#�����ɮ�
close DATA;
exit(0);
 

#!/usr/bin/perl

#1.on-off�C���W�[���t�v��100kbps
#2.�T�w���t�v,������禸�Ƭ�30��,�B���檺���G�|�s��presult100, result200,...���ɮפ�
#3.�Y�O�n�A���P�˳t�v�����,�аO�o����resultXXX���ɮקR�p

for ($i = 100; $i <=500 ; $i=$i+100) {
    for ($j = 1; $j <= 30; $j++) {
	system("ns lab5.tcl $i $j");
	$f1="out$i-$j.tr";
	$f2="result$i";
	system("awk -f 5T.awk $f1 >> $f2");
	print "\n";
    }
    print "\n";
}

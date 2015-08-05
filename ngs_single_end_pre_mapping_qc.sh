#!/bin/sh
CODEDIR="/nlmusr/reazur/linux/NELSON/TIDAL/CODE"
########################################################
## Generate qty report file (for generating qc plot) ###
########################################################
head=`head -100 $1 | grep '^@' | cut -d'@' -f2 | cut -c1-3 | head -1`
$CODEDIR/ngs_qc -i $1 -o $1.qc -w 3

################################
## Create .uq .qc .stat file ###
################################
mkdir $1.DIR
cd $1.DIR
grep -A 1 "^@$head" ../$1 | grep -v '^-' | grep -v "^@$head" > $1.z0
for W in A C G N T
do
  grep "^$W" $1.z0 > $1.z0.$W
done

for W in A C G N T
do
  for X in A C G N T
  do
    grep "^$W$X" $1.z0.$W > $1.z0.$W$X
  done
done


touch $1.uq; rm $1.uq
echo '0	0' > $1.z0
for W in A C G N T
do
  for X in A C G N T
  do
    for Y in A C G N T
    do
        grep "^$W$X$Y" $1.z0.$W$X | sort > $1.$W$X$Y
        $CODEDIR/count $1.$W$X$Y > $1.$W$X$Y.count
        paste $1.$W$X$Y.count $1.$W$X$Y.count | cut -f2-4 | sed 's/^/>/' | sed 's/	/:/' | tr '\t' '\n' | grep -v '^>0$' >> $1.uq
        cut -f1 $1.$W$X$Y.count | sort -n | $CODEDIR/count > $1.$W$X$Y.count.stat
        cat $1.$W$X$Y.count.stat | sed 's/	[0-9][0-9][0-9]*$/	10+/' >> $1.z0
    done
  done
done

sort +1 -2n +0 -1n $1.z0 | $CODEDIR/group -g 1 -a 0 -d '+' -c | sed 's/+$//' > $1.z1
cut -f2- $1.z1 | bc -l | paste $1.z1 - | cut -f1,3 | sed 's/^0	.*/Freq	Count/' > $1.stat
mv $1.uq ..
mv $1.stat ..
cd ..

#############################
##  Generate qc pdf file  ###
#############################
R --no-restore --no-save --no-readline $1 < $CODEDIR/plot_qc.R

exit


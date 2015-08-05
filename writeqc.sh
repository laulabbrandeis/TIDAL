#!/bin/sh

#$1
#$2
CODEDIR="/nlmusr/reazur/linux/NELSON/TIDAL/CODE"
GHOME="/nlmusr/gchirn/linux"
in=$1
out=$2
text=$3

echo "$text:" >> summary
echo -ne "  reads:\t$in\t$out\tpercent\n" >> summary
#use $(...) construct

echo -n "uq reads:" >> summary
orig=$(grep "^>" $in | wc -l)
echo -ne "\t$orig" >> summary

reduce=$(grep "^>" $out | wc -l) 
echo -ne "\t$reduce" >> summary

#percent=$(awk -v n=$reduce -v d=$orig 'BEGIN { print (n/d)*100 }')
percent=$(awk -v n=$reduce -v d=$orig 'BEGIN { printf "%.4f", (n/d)*100 }')
echo -ne "\t$percent%\n" >> summary


echo -ne "   reads: " >> summary
before=$(grep "^>" $in | cut -d':' -f2 | $CODEDIR/sum ) 
echo -ne "\t$before" >> summary




after=$(grep "^>" $out | cut -d':' -f2 | $CODEDIR/sum )
echo -ne "\t$after" >> summary

percent=$(awk -v n=$after -v d=$before 'BEGIN { printf "%.4f", (n/d)*100 }')
echo -ne "\t$percent%\n" >> summary

echo "----------------" >> summary;

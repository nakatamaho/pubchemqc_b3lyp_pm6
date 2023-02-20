#!/bin/sh
cd /home/maho/b3lyp_pm6/pubchem
bash rmwork.sh >/dev/null 2>&1
TOTAL=0
NOTYETS=`ls /home/maho/b3lyp_pm6/pubchem/00work/*/*/*tar.xz /home/maho/b3lyp_pm6/pubchem/notyet/*/*notyet*tar.xz`
COUNTS=0
for _notyet in $NOTYETS; do
     a=`tar tvfJ $_notyet 2>/dev/null | wc -l`
     COUNTS=$(( $COUNTS + $a ))
done
echo "num of notyet molecules: $COUNTS"


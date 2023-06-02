max=121500000
#max=1000000
 step=50000

_TOPDIR=/work1/pubchemqc_b3lyp_pm6/b3lyp_pm6_dataplot
SUBSETNAME=all
PM6VER="2.0.0"
B3LYP_PM6VER="1.0.1"

########################
TOPDIR=${_TOPDIR}/${SUBSETNAME}
SUBSETNAME_LOWER=`echo $SUBSETNAME | tr [A-Z] [a-z]`
B3LYPDATANAME=b3lyp_pm6_${SUBSETNAME}
PM6DATANAME=pm6opt_${SUBSETNAME}

B3LYPDATANAME_LOWER=b3lyp_pm6_${SUBSETNAME_LOWER}
PM6DATANAME_LOWER=pm6opt_${SUBSETNAME_LOWER}
MERGEDDATANAME=pm6_b3lyp_pm6_${SUBSETNAME}
########################
cd $TOPDIR
rm -rf ${B3LYPDATANAME} ${PM6DATANAME} ${MERGEDDATANAME}
mkdir -p ${B3LYPDATANAME} ${PM6DATANAME} ${MERGEDDATANAME}
########################
cd $TOPDIR
tar xfJ /work1/pm6/pm6opt_ver2.0.0-postgrest-docker-compose.tar.xz
cd pm6opt-postgrest-docker-compose
docker-compose up -d --build
sleep 10
for ((i=0; i < $max; i=i + $step)); do
    aa=`printf "%010d" $i`
    curl "http://localhost:3000/pm6opt?state=not.eq.cation&state=not.eq.anion&state=not.eq.T0&state=not.eq.Q0&and=(cid.gte.$((i + 1)),cid.lte.$((i + $step)))" | sed -e '1s/\[//' -e 's/\]$/\n/'  > ${TOPDIR}/${PM6DATANAME}/${PM6DATANAME}.${aa}.json
    pwd
    python3 ${TOPDIR}/json2csv_pm6.py ${TOPDIR}/${PM6DATANAME}/${PM6DATANAME}.${aa}.json > ${TOPDIR}/${PM6DATANAME}/${PM6DATANAME}.${aa}.csv
    rm ${TOPDIR}/${PM6DATANAME}/${PM6DATANAME}.${aa}.json
done
docker-compose down
sleep 3
########################
cd $TOPDIR
tar xfJ /work1/b3lyp_pm6/b3lyp_pm6_ver1.0.1-postgrest-docker-compose.tar.xz
cd b3lyp_pm6-postgrest-docker-compose
docker-compose up -d --build
sleep 10
for ((i=0; i < $max; i=i + $step)); do
    aa=`printf "%010d" $i`
    curl "http://localhost:3000/b3lyp_pm6?and=(cid.gte.$((i + 1)),cid.lte.$((i + $step)))" | sed -e '1s/\[//' -e 's/\]$/\n/' > ${TOPDIR}/${B3LYPDATANAME}/${B3LYPDATANAME}.${aa}.json
    python3 ${TOPDIR}/json2csv_b3lyp_pm6.py ${TOPDIR}/${B3LYPDATANAME}/${B3LYPDATANAME}.${aa}.json > ${TOPDIR}/${B3LYPDATANAME}/${B3LYPDATANAME}.${aa}.csv
    rm ${TOPDIR}/${B3LYPDATANAME}/${B3LYPDATANAME}.${aa}.json
done
docker-compose down
sleep 3
########################
cd $TOPDIR
for ((i=0; i < $max; i=i + $step)); do
    aa=`printf "%010d" $i`
    python3 csvmerge.py ${PM6DATANAME}/${PM6DATANAME}.${aa}.csv ${B3LYPDATANAME}/${B3LYPDATANAME}.${aa}.csv > ${MERGEDDATANAME}/${MERGEDDATANAME}.${aa}.csv
done
########################
/usr/bin/time python3 homolumogap.py ${MERGEDDATANAME}
/usr/bin/time python3 dipole.py ${MERGEDDATANAME}
/usr/bin/time python3 homo.py ${MERGEDDATANAME}
/usr/bin/time python3 lumo.py ${MERGEDDATANAME}
########################

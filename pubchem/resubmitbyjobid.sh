IDs=`cat ~/aaa`
topdir="/home/maho/b3lyp_pm6/pubchem"
for _id in $IDs; do
    cd $topdir 
    echo $_id
    a=`ls 00work/*/*$_id`
    _dirname=`dirname $a`
    echo $_dirname
    cd $_dirname
    pwd
    ls
    sed -i -e 's|1200|3600|g' run_gms.sh 
    sed -i -e 's|jobs 10|jobs 40|g' run_gms.sh
    sed -i -e 's|GMSCORES=4|GMSCORES=1|g' run_gms.sh
    pjsub run_gms.sh
    sleep 3
done

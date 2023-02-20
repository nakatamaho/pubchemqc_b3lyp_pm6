topdir="/home/maho/b3lyp_pm6/pubchem"
cd $topdir 
_a=`ls $topdir/00work/20200318`
for a in $_a; do
    cd $topdir/00work/20200318/$a 
    pwd
    ls
    grep touch run_gms.sh.o* | grep DONE
    SUCCESS=$?
    if [ "$SUCCESS" != "0" ]; then
        sed -i -e 's|/usr/bin/time parallel --jobs 10 create_gamess_inp|timeout -s9 3600 /usr/bin/time parallel --jobs 20 create_gamess_inp|g' run_gms.sh run_gms.sh 
        sed -i -e 's|xz \*/\*B3LYP\*\.inp|xz \*/\*PM6\*\.inp|g' run_gms.sh
        #echo "pjsub run_gms.sh"
    fi
    sleep 3
done

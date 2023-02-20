HOKUSAIPRJNUM=G19015
SYSTEM=bwmpc
MAXJOB=120
TIMEOUT_JOB=25
PARALLEL_JOB=40
MWLIMIT=700
TARS2PROCESS=20
NUMOFBULKS=5 
###################################
PUBCHEMQCTMPTOPDIR=$PUBCHEMQCTOPDIR/tmp/
###################################
module load intel_python3/17.4.196

if [ x"$PUBCHEMQCTOPDIR" = x"" ]; then
    echo "Do 'source pubchemqc.sh'"
    exit
fi


function check_jobrun ()
{
    if [ x"$SYSTEM" = x"bwmpc" ]; then
        _JOBRUN=`pjstat | grep maho | wc -l`
        echo "$_JOBRUN"
    fi
}


DIRS=`ls -d $PUBCHEMQCTOPDIR/pubchem/00work/201*`

for _dir in $DIRS; do
    __dir=`basename $_dir`
    if [ "20180625000000" -gt "$__dir" ]; then
       echo "ok"
       else
       continue
    fi
    cd $_dir
    TODAYHMS=`basename ${_dir}`
    cp $PUBCHEMQCTOPDIR/pubchem/template0.sh run_gms.sh
    _SPLITTARS=`ls Compound*tar.xz`
    SPLITTARS=`echo $_SPLITTARS`
    sed -i "s|%%COMPOUNDS%%|$SPLITTARS|g" run_gms.sh
    sed -i "s|%%PUBCHEMQCARCH%%|$PUBCHEMQCARCH|g" run_gms.sh
    sed -i "s|%%PUBCHEMQCTOPDIR%%|$PUBCHEMQCTOPDIR|g" run_gms.sh
    sed -i "s|%%TIMEOUT_JOB%%|$TIMEOUT_JOB|g" run_gms.sh
    sed -i "s|%%PARALLEL_JOB%%|$PARALLEL_JOB|g" run_gms.sh
    sed -i "s|%%MWLIMIT%%|$MWLIMIT|g" run_gms.sh
    sed -i "s|%%TODAYHMS%%|$TODAYHMS|g" run_gms.sh
    sed -i "s|%%LOCALTOPDIR%%|/dev/shm/maho/pubchem/|g" run_gms.sh

    while :
    do
        JOBRUN=`check_jobrun`
        if [ "$JOBRUN" -lt "$MAXJOB" ]; then
            pjsub run_gms.sh
            __DATE=`LANG=LC_ALL date`
            echo "$TODAYHMS : $SPLITTARS submitted at $__DATE"
            touch ".SUBMITTED"
            sleep 1
            break
        else
            __DATE=`LANG=LC_ALL date`
            echo "MAXJOB $MAXJOB reached at $__DATE" 
            sleep 60
        fi
    done
done


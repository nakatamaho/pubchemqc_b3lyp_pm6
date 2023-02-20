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

while :
do
    TODAY=`date "+%Y%m%d"`
    mkdir -p $PUBCHEMQCTOPDIR/pubchem/00work
    mkdir -p $PUBCHEMQCTOPDIR/pubchem/00done/$TODAY
    mkdir -p $PUBCHEMQCTOPDIR/pubchem/Compound_splitted/
    cd $PUBCHEMQCTOPDIR/pubchem/Compound_splitted
    SPLITTARS=`ls Compound*splitted*tar.xz 2> /dev/null`
    cd $PUBCHEMQCTOPDIR/pubchem/00work
    TODAYHMS=`date "+%Y%m%d%H%M%S"`
    declare splittars=($SPLITTARS)
    numofsplittars=${#splittars[@]}
    numofchunks=$(( numofsplittars / $TARS2PROCESS + 1))
    if [ $numofsplittars = 0 ]; then
        TARS=`ls $PUBCHEMQCTOPDIR/pubchem/Compound/ | grep -v md5 | head -n $NUMOFBULKS | xargs`
        cd $PUBCHEMQCTOPDIR/pubchem/Compound_splitted/
        for tar in $TARS; do
            python3 ../split_tar.py ../Compound/$tar
            rm ../Compound/$tar
            touch ../Compound/.done_${tar}
        done
        continue
    fi  
    for (( idx=0; idx< $numofchunks; idx++ )) ; do 
        _start=$(( idx * $TARS2PROCESS ))
        SPLITTARS=${splittars[@]:_start:$TARS2PROCESS}
        mkdir -p $PUBCHEMQCTOPDIR/pubchem/00work/$TODAYHMS
        if [ -e "$PUBCHEMQCTOPDIR/pubchem/00work/$TODAYHMS/.SUBMITTED" ]; then
            continue
        fi
        cd $PUBCHEMQCTOPDIR/pubchem/00work/$TODAYHMS
        for splittar in $SPLITTARS; do
            mv $PUBCHEMQCTOPDIR/pubchem/Compound_splitted/$splittar .
        done
        cp $PUBCHEMQCTOPDIR/pubchem/template0.sh run_gms.sh
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
done

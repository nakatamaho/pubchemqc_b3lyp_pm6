HOKUSAIPRJNUM=G19015
SYSTEM=bwmpc
MAXJOB=160
PARALLEL_JOB=40
MWLIMIT=700
TIMEOUT_JOB=8

TARS2PROCESS=20
NUMOFBULKS=5 
###################################
PUBCHEMQCTMPTOPDIR=$PUBCHEMQCTOPDIR/tmp/
###################################
module load intel_python3/17.4.196

NOTYETDIR=/data/G18012/b3lyp@pm6_merge/20200401_notyet/
############################
#FILES=`cd $NOTYETDIR ; ls *.tar.xz`
#for _file in $FILES; do
#    if [ -e "$PUBCHEMQCTOPDIR/pubchem/notyet_stamp/Compound/.SUBMITTED_${_file}" ]; then
#        continue
#    fi
#    echo "copying $_file ..."
#    rsync -arv $NOTYETDIR/$_file $PUBCHEMQCTOPDIR/pubchem/notyet/20200401/
#done
#exit
############################
if [ x"$PUBCHEMQCTOPDIR" = x"" ]; then
    echo "Do 'source pubchemqc.sh'"
    exit
fi

function check_jobrun ()
{
    if [ x"$SYSTEM" = x"bwmpc" ]; then
        _JOBRUN=`pjstat | grep run_gms | wc -l`
        echo "$_JOBRUN"
    fi
}

while :
do
    TODAY=`date "+%Y%m%d"`
    mkdir -p $PUBCHEMQCTOPDIR/pubchem/00work
    mkdir -p $PUBCHEMQCTOPDIR/pubchem/00done/$TODAY
    cd $PUBCHEMQCTOPDIR/pubchem/notyet
    NOTYETs=`ls -S */C*_notyet.tar.xz 2> /dev/null`
    NOTYETs=`ls -S */*_notyet.tar.xz | tac 2> /dev/null`
    numofnotyets=`ls */*_notyet.tar.xz 2> /dev/null | wc -l`
    echo "notyet tars : $numofnotyets"
    cd $PUBCHEMQCTOPDIR/pubchem/00work
    if [ $numofnotyets = 0 ]; then
        echo "all done"
        sleep 360
        continue
    fi  
    for _notyet in $NOTYETs; do
        notyet=`basename $_notyet`
        TODAYHMS=`date "+%Y%m%d%H%M%S"`
        TODAY=`date "+%Y%m%d"`
        notyet_date=`echo $notyet | cut -c 1-8`
        if [ -e "$PUBCHEMQCTOPDIR/pubchem/notyet_stamp/$notyet_date/.SUBMITTED_$notyet" ]; then
            rm -f $PUBCHEMQCTOPDIR/pubchem/notyet/$_notyet
            rm -rf $PUBCHEMQCTOPDIR/pubchem/00work/$TODAY/$TODAYHMS/
            echo "remove: $_notyet as it has been submitted"
            continue
        fi
   done 
   exit
done

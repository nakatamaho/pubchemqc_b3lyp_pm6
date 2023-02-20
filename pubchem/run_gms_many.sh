#!/bin/sh -x
#PJM -L rscunit=bwmpc
#PJM -L rscgrp=batch
#PJM -L elapse=1:00:00
#PJM -L vnode=1
#PJM -L vnode-core=40
#PJM -j

rm -rf /dev/shm/*
__START_TIME=`date +%s`

### remove unnecessary stuffs for GW hokusai
unset MKLROOT IPPROOT INTEL_LICENSE_FILE GDBSERVER_MIC LIBRARY_PATH FPATH MIC_LD_LIBRARY_PATH
unset MIC_LIBRARY_PATH MANPATH CPATH NLSPATH TBBROOT MODULEPATH GDB_CROSS LOADEDMODULES MPM_LAUNCHER
unset INTEL_PYTHONHOME INFOPATH INCLUDE I_MPI_ROOT _LMFILES_ I_MPI_HYDRA_HOST_FILE I_MPI_PIN

LOCALTOPDIR=/dev/shm/maho/pubchem/
LOCALPKGDIR=/dev/shm/maho/pubchem/pkg/x86_64
PUBCHEMQCPKG=pkg.x86_64.20180503.tar.bz2

mkdir -p $LOCALTOPDIR
cd $LOCALTOPDIR
cp /home/maho/b3lyp_pm6/$PUBCHEMQCPKG $LOCALTOPDIR
tar xfj $PUBCHEMQCPKG

FILES=`ls -S /home/maho/b3lyp_pm6/pubchem/notyet/*/*tar.xz | tac`
mkdir work
cd work
###
for __file in $FILES; do
    cp $__file $LOCALTOPDIR
    _file=`basename $__file`
    notyet_date=`echo $_file | cut -c 1-8`
    mkdir -p /home/maho/b3lyp_pm6/pubchem/notyet_stamp2/$notyet_date/
    touch /home/maho/b3lyp_pm6/pubchem/notyet_stamp2/$notyet_date/.SUBMITTED_${_file}
    tar xfJ $LOCALTOPDIR/$_file
    NUMOFFILES=`ls */*inp | wc -l`
    if [ $NUMOFFILES -gt 100 ]; then
        break
    fi 
done

function create_gamess_inp()
{
    dir=$1
    cd /dev/shm/maho/pubchem//work/$dir #somehow global variable doesn't work so hardcoded
    FILES=`ls *.PM6.S0.inp`
    for file in $FILES; do
    file_attributes=(${file//./ });
    cid=${file_attributes[0]}
    method=${file_attributes[1]}
    state=${file_attributes[2]}
    _file=${cid}".B3LYP@PM6."$state".inp"
    if [ -e ".DONE_$_file" ]; then
        continue 
    fi 
    # first generate GAMESS input file.
    sed -e '/^%/d' -e '/^$/d' -e '/^-/d'  -e '/^[0-9]/d' -e '/^#/d' -e '/PUBCHEM/d' $file > ${file}__
    wc -l ${file}__ | awk '{print $1}' > atoms.${file}__
    (cat atoms.${file}__ ; echo ; cat ${file}__ ) > ${file}.xyz
    rm ${file}__ atoms.${file}__

    ICHARG=`grep -A 2 PUBCHEM $file | tail -1 | awk '{print $1}'`
    MULT=`grep -A 2 PUBCHEM $file | tail -1 | awk '{print $2}'`
    if [ "$ICHARG" = "0" -a "$MULT" = "1" ]; then
        IM=""
    fi
    if [ "$ICHARG" != "0" -a "$MULT" = "1" ]; then
        IM="\ICHARG=$ICHARG "
    fi
    if [ "$ICHARG"  = "0" -a "$MULT" != "1" ]; then
        IM="SCFTYP=UHF \MULT=$MULT "
    fi
    if [ "$ICHARG" != "0" -a "$MULT" != "1" ]; then
        IM="SCFTYP=UHF \ICHARG=$ICHARG \MULT=$MULT "
    fi
    obabel --title "PUBCHEM $cid B3LYP 6-31G(d) at PM6 optimized geometry" -ixyz ${file}.xyz -ogamin -O $_file
    if [ x"$IM" != "x" ]; then
        sed -i "1c \ \$CONTRL RUNTYP=ENERGY DFTTYP=B3LYPV1R $IM\$END" $_file
    else
        sed -i '1c \ $CONTRL RUNTYP=ENERGY DFTTYP=B3LYPV1R $END' $_file
    fi
    sed -i '1a \ $SYSTEM MWORDS=200 $END' $_file
    sed -i '2a \ $SCF DIRSCF=.T. FDIFF=.T. $END' $_file
    sed -i '3a \ $BASIS GBASIS=N31 NGAUSS=6 NDFUNC=1 $END' $_file

    insert_basis_gms.sh $_file ${_file}.new
    mv ${_file}.new $_file    

    done
}
export -f create_gamess_inp

export GMSPATH=$LOCALPKGDIR/gamess
sed -i "s|set GMSPATH=/home/maho/b3lyp_pm6/pkg/x86_64/gamess|set GMSPATH=$GMSPATH|g" $LOCALPKGDIR/bin/rungms
export SCR="."
export PATH=$LOCALPKGDIR/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LOCALPKGDIR/lib
export BABEL_LIBDIR=$LOCALPKGDIR/lib/openbabel/2.4.1/
export BABEL_DATADIR=$LOCALPKGDIR/share/openbabel/2.4.1/

ls -S -r  */*inp | xargs dirname >_dirlist # we do not need serious sorting by mw.
DIRs=`cat _dirlist | xargs`
/usr/bin/time parallel --jobs 40 create_gamess_inp ::: $DIRs

rm */tmp*
ls */* | grep -v B3LYP | xargs rm -rf

mkdir -p $LOCALTOPDIR/00done
function execute_gamess()
{
    fullfile=$1
    file=`basename $fullfile` 
    _DIR=`dirname $fullfile`
    cd $_DIR
    rungms $file > ${file%.*}.out
    grep "DENSITY CONVERGED" ${file%.*}.out >&/dev/null
    FAILED=$?
    grep "GAMESS TERMINATED" ${file%.*}.out >&/dev/null
    FAILED=$(( $? * $FAILED ))
#    if [ "$FAILED" != "1" ]; then
    if [ 1 ]; then
        grep -B 5 'EXECUTION OF GAMESS TERMINATED NORMALLY' ${file%.*}.out | grep WALL
        bzip2 ${file%.*}.out             #xz somehow fails
        cd .. ; mv `dirname $fullfile` /dev/shm/maho/pubchem//00done
    fi
}
FILES=`ls -S -r */*B3LYP*S0.inp` # no serious sorting. just bigger input file size = bigger molecule
__CURRENT_TIME=`date +%s`
MARGIN=$(( 3600 + ($RANDOM % 10) ))
TIMEOUT_JOB_SECOND=$(( 24 * 3600 - $__CURRENT_TIME + $__START_TIME - $MARGIN ))
TIMEOUT_JOB_SECOND=3600
export -f execute_gamess
timeout -s9 $TIMEOUT_JOB_SECOND parallel --jobs 40 execute_gamess ::: $FILES


_DATE=`date "+%Y%m%d"`
_DATEHMS=`date "+%Y%m%d%H%M%S"`

cd /dev/shm/maho/pubchem//00done
rm -f *sh */*dat */*F?? *list*
tar cfJ ../../${_DATEHMS}_results.tar.xz */*B3LYP*
mkdir -p /home/maho/b3lyp_pm6/pubchem/00done2/$_DATE
mv ../../${_DATEHMS}_results.tar.xz /home/maho/b3lyp_pm6/pubchem/00done2/$_DATE

cd /dev/shm/maho/pubchem/work
rm -f *sh */*dat */*F?? *list*

if ls */*B3LYP*.inp > /dev/null 2>&1
then
    tar cfJ ../${_DATEHMS}_notyet.tar.xz */*B3LYP*.inp
    mv ../${_DATEHMS}.tar.xz /home/maho/b3lyp_pm6/pubchem/00done2/$_DATE
    mkdir -p /home/maho/b3lyp_pm6/pubchem/notyet2/${_DATE}
    cp /home/maho/b3lyp_pm6/pubchem/00done2/$_DATE/${_DATEHMS}_notyet.tar.xz  /home/maho/b3lyp_pm6/pubchem/notyet2/${_DATE}/
fi

rm -rf /dev/shm/*
__END_TIME=`date +%s`
__ELAPSED=$(( $__END_TIME - $__START_TIME ))


#!/bin/sh -x
#PJM -L rscunit=bwmpc
#PJM -L rscgrp=batch
#PJM -L elapse=%%TIMEOUT_JOB%%:00:00
#PJM -L vnode=1
#PJM -L vnode-core=%%PARALLEL_JOB%%
#PJM -j

rm -rf /dev/shm/*
__START_TIME=`date +%s`

### remove unnecessary stuffs for GW hokusai
unset MKLROOT IPPROOT INTEL_LICENSE_FILE GDBSERVER_MIC LIBRARY_PATH FPATH MIC_LD_LIBRARY_PATH
unset MIC_LIBRARY_PATH MANPATH CPATH NLSPATH TBBROOT MODULEPATH GDB_CROSS LOADEDMODULES MPM_LAUNCHER
unset INTEL_PYTHONHOME INFOPATH INCLUDE I_MPI_ROOT _LMFILES_ I_MPI_HYDRA_HOST_FILE I_MPI_PIN

LOCALTOPDIR=%%LOCALTOPDIR%%
LOCALPKGDIR=/dev/shm/maho/pubchem/pkg/%%PUBCHEMQCARCH%%
PUBCHEMQCPKG=pkg.%%PUBCHEMQCARCH%%.20180503.tar.bz2

mkdir -p $LOCALTOPDIR
cd $LOCALTOPDIR
cp %%PUBCHEMQCTOPDIR%%/$PUBCHEMQCPKG $LOCALTOPDIR
tar xfvj $PUBCHEMQCPKG

cd %%PUBCHEMQCTOPDIR%%/pubchem/00work/%%TODAYHMS%%
cp %%COMPOUNDS%% $LOCALTOPDIR
cd $LOCALTOPDIR
mkdir work
cd work

for compoundfile in %%COMPOUNDS%% ; do
    tar xfJ $LOCALTOPDIR/$compoundfile
done

export GMSPATH=$LOCALPKGDIR/gamess
sed -i "s|set GMSPATH=/home/maho/b3lyp_pm6/pkg/%%PUBCHEMQCARCH%%/gamess|set GMSPATH=$GMSPATH|g" $LOCALPKGDIR/bin/rungms

export SCR="."
export PATH=$LOCALPKGDIR/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LOCALPKGDIR/lib
export BABEL_LIBDIR=$LOCALPKGDIR/lib/openbabel/2.4.1/
export BABEL_DATADIR=$LOCALPKGDIR/share/openbabel/2.4.1/

#first, sort by molecular weight
 
function create_mw4molecule()
{
    dir=$1
    cd %%LOCALTOPDIR%%/work/$dir #somehow global variable doesn't work so hardcoded
    obabel -ixyz ${dir}.initial.xyz -oreport -O ${dir}.report
    cat ${dir}.report | grep ^MASS | awk -v __dir=${dir} '{print __dir " " $2}' > ${dir}.mw
}

export -f create_mw4molecule
ls -S -r  */*xyz | xargs dirname >_dirlist # we do not need serious sorting by mw.

#/usr/bin/time parallel --jobs 30 create_mw4molecule ::: $DIRs
#cd $LOCALTOPDIR/work/
#cat */*.mw > mwlist
#rm  */*.mw
#sort -n -k 2 mwlist > mwlist__
#cat mwlist__ | awk '{if ($2 < %%MWLIMIT%% ) print $1 " " $2}' > mwlist_
#cat mwlist_
#cat mwlist_ | awk '{print $1}' > _dirlist

function create_gamess_inp()
{
    dir=$1
    cd %%LOCALTOPDIR%%/work/$dir #somehow global variable doesn't work so hardcoded
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
DIRs=`cat _dirlist | xargs`
/usr/bin/time parallel --jobs %%PARALLEL_JOB%% create_gamess_inp ::: $DIRs

###

cd $LOCALTOPDIR/work/
rm */tmp*B3LYP*

mkdir -p $LOCALTOPDIR/00done
function execute_gamess()
{
    file=$1
    _SIZE=`wc -c $file | awk '{print $1}'`
#    if [ $_SIZE -gt 6000 ]; then
#        return
#    fi 
    rungms $file > ${file%.*}.out
    grep "DENSITY CONVERGED" ${file%.*}.out >&/dev/null
    FAILED=$?
    grep "GAMESS TERMINATED" ${file%.*}.out >&/dev/null
    FAILED=$(( $? * $FAILED ))
    if [ "$FAILED" != "1" ]; then
        grep -B 5 'EXECUTION OF GAMESS TERMINATED NORMALLY' ${file%.*}.out | grep WALL
        bzip2 ${file%.*}.out             #xz somehow fails
        mv `dirname $file` %%LOCALTOPDIR%%/00done
    fi
}

FILES=`cat _dirlist | awk '{print "ls "$1"/"$1"*B3LYP*S0.inp"}' | sh | grep -v No`
__CURRENT_TIME=`date +%s`
MARGIN=$(( 3600 + ($RANDOM % 10) ))
TIMEOUT_JOB_SECOND=$(( %%TIMEOUT_JOB%% * 3600 - $__CURRENT_TIME + $__START_TIME - $MARGIN ))
export -f execute_gamess
timeout -s9 $TIMEOUT_JOB_SECOND parallel --jobs %%PARALLEL_JOB%% execute_gamess ::: $FILES

cd %%LOCALTOPDIR%%/00done
rm -f *sh */*dat */*F?? *list*
tar cfJ ../../%%TODAYHMS%%_results.tar.xz */*B3LYP*
_DATE=`date "+%Y%m%d"`
mkdir -p %%PUBCHEMQCTOPDIR%%/pubchem/00done/$_DATE
mv ../../%%TODAYHMS%%_results.tar.xz %%PUBCHEMQCTOPDIR%%/pubchem/00done/$_DATE

cd %%LOCALTOPDIR%%/work
rm -f *sh */*dat */*F?? *list*

if ls */*B3LYP*.inp > /dev/null 2>&1
then
    tar cfJ ../%%TODAYHMS%%_notyet.tar.xz */*B3LYP*.inp
    cp ../%%TODAYHMS%%_notyet.tar.xz %%PUBCHEMQCTOPDIR%%/pubchem/00done/$_DATE
    mkdir -p %%PUBCHEMQCTOPDIR%%/pubchem/notyet/$_DATE
    mv ../%%TODAYHMS%%_notyet.tar.xz %%PUBCHEMQCTOPDIR%%/pubchem/notyet/$_DATE
fi

rm -rf /dev/shm/*
__END_TIME=`date +%s`
__ELAPSED=$(( $__END_TIME - $__START_TIME ))
touch %%PUBCHEMQCTOPDIR%%/pubchem/00work/%%TODAYHMS%%/.DONE

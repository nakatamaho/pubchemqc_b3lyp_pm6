#!/bin/sh

WRKDIR=$PUBCHEMQCSETUPDIR/work_gamess
USE_INTELCOMPOSER=no
OPENMP=false
PARALLEL=`echo $MAKEFLAGS | sed 's/\-j//g'`
GAMESSVERSION=20180214.R1
NAME=GAMESS-${GAMESSVERSION}

if [ x"PUBCHEMQCARCH" = x"s64fx" ]; then
    echo "must be cross built"
fi

if [ x"$1" != x"" ]; then
    PUBCHEMQCARCH=$1
fi

if [ x"$USE_INTELCOMPOSER" = x"yes" ]; then
_PUBCHEMQCARCH=${PUBCHEMQCARCH}_intel
else
_PUBCHEMQCARCH=${PUBCHEMQCARCH}
fi

if [ x"$OPENMP" = x"true" ]; then
PUBCHEMQCPKG_SUFFIX=${_PUBCHEMQCARCH}_OpenMP
else
PUBCHEMQCPKG_SUFFIX=${_PUBCHEMQCARCH}
fi
####
if [ -e "$PUBCHEMQCSETUPDIR/.done_${NAME}_${PUBCHEMQCPKG_SUFFIX}" ]; then
    echo "already installed"
    exit
fi
####

rm -rf $WRKDIR
mkdir $WRKDIR
cd $WRKDIR
tar xvfz $PUBCHEMQCARCHIVESDIR/gamess.$GAMESSVERSION/gamess-current.tar.gz
mv gamess gamess_orig
tar xvfz $PUBCHEMQCARCHIVESDIR/gamess.$GAMESSVERSION/gamess-current.tar.gz
cd gamess

if [ x"$PUBCHEMQCARCH" = x"x86_64" -a x"$USE_INTELCOMPOSER" = x"yes" ]; then
patch -p1 < $PUBCHEMQCARCHIVESDIR/gamess.$GAMESSVERSION/patch-gamess.${GAMESSVERSION}


__HOSTNAME=`hostname -s`
if [[ $__HOSTNAME =~ hokusai ]] ; then
module load intel/18.1.038
fi
source /opt/intel/bin/compilervars.sh intel64
FORTRAN=ifort
IFORTVER=`ifort --version >& l ; head -1 l | awk '{print $3}' | sed 's/\..*$//'`
rm l
cat > install.info << _EOF_
#!/bin/csh
#   compilation configuration for GAMESS
#   generated on
#   generated at
setenv GMS_BUILD_DIR       %%GAMESS_BUILD_DIR%%/gamess
setenv GMS_PATH            %%GAMESS_BUILD_DIR%%/gamess
#         machine type
setenv GMS_TARGET	linux64
#         FORTRAN compiler setup
setenv GMS_FORTRAN	ifort
setenv GMS_IFORT_VERNO  %%IFORTVER%%
#         mathematical library setup
setenv GMS_MATHLIB         mkl
setenv GMS_MATHLIB_PATH    /opt/intel/mkl/lib/intel64
setenv GMS_MKL_VERNO      12
#         parallel message passing model setup
setenv GMS_DDI_COMM        sockets
#         LIBCCHEM CPU/GPU code interface
setenv GMS_LIBCCHEM        false
setenv GMS_PHI             false
setenv GMS_SHMTYPE         posix
setenv GMS_OPENMP          %%OPENMP%%
_EOF_
fi

if [ x"$PUBCHEMQCARCH" = x"x86_64" -a x"$USE_INTELCOMPOSER" != x"yes" ]; then
patch -p1 < $PUBCHEMQCARCHIVESDIR/gamess.$GAMESSVERSION/patch-gamess.${GAMESSVERSION}

FORTRAN=gfortran
GFORTRANVERSION=`$FORTRAN -v >& l ;  tail -1 l | awk '{print $3}' | sed 's/\.[^.]*$//'`
rm l
cat > install.info << _EOF_
#!/bin/csh
#   compilation configuration for GAMESS
#   generated on
#   generated at
setenv GMS_BUILD_DIR       %%GAMESS_BUILD_DIR%%/gamess
setenv GMS_PATH            %%GAMESS_BUILD_DIR%%/gamess
#         machine type
setenv GMS_TARGET	linux64
#         FORTRAN compiler setup
setenv GMS_FORTRAN	  %%FORTRAN%%
setenv GMS_GFORTRAN_VERNO %%GFORTRANVERSION%%
#         mathematical library setup
setenv GMS_MATHLIB         openblas
setenv GMS_MATHLIB_PATH    -L/usr/lib/
#         parallel message passing model setup
setenv GMS_DDI_COMM        sockets
#         LIBCCHEM CPU/GPU code interface
setenv GMS_LIBCCHEM        false
setenv GMS_PHI             false
setenv GMS_SHMTYPE         posix
setenv GMS_OPENMP          %%OPENMP%%
_EOF_
fi

if [ x"$PUBCHEMQCARCH" = x"s64fx" ]; then
FORTRAN=mpifrtpx
patch -p1 < $PUBCHEMQCARCHIVESDIR/gamess.$GAMESSVERSION/patch-gamess.${GAMESSVERSION}_fx10
cat > install.info << _EOF_
#!/bin/csh
#   compilation configuration for GAMESS
#   generated on
#   generated at
setenv GMS_BUILD_DIR       %%GAMESS_BUILD_DIR%%/gamess
setenv GMS_PATH            %%GAMESS_BUILD_DIR%%/gamess
#         machine type
setenv GMS_TARGET	xtcos
#         FORTRAN compiler setup
setenv GMS_FORTRAN	  %%FORTRAN%%
#         mathematical library setup
setenv GMS_MATHLIB         SSL2BLAMP
#         parallel message passing model setup
setenv GMS_DDI_COMM        mpi
setenv GMS_MPI_LIB         Fujitsu-MPI
#         LIBCCHEM CPU/GPU code interface
setenv GMS_LIBCCHEM        false
setenv GMS_PHI             false
setenv GMS_SHMTYPE         posix
setenv GMS_OPENMP          %%OPENMP%%
setenv PATH                $PATH
_EOF_
fi

#######################################
sed -i "s|%%GAMESS_BUILD_DIR%%|$WRKDIR|g" install.info
sed -i "s|%%GFORTRANVERSION%%|$GFORTRANVERSION|g" install.info
sed -i "s|%%GFORTRANVERSION%%|$GFORTRANVERSION|g" install.info
sed -i "s|%%OPENMP%%|$OPENMP|g" install.info
sed -i "s|%%IFORTVER%%|$IFORTVER|g" install.info
sed -i "s|%%FORTRAN%%|$FORTRAN|g" install.info
sed -i "s|%%PARALLEL%%|$PARALLEL|g" compall
sed -i "s/%%FORTRAN%%/$FORTRAN/g" comp
sed -i "s/%%FORTRAN%%/$FORTRAN/g" lked
#######################################
cd tools
cp actvte.code actvte.f
sed 's/*UNX/    /g' < actvte.code > actvte.f
gfortran -o actvte.x actvte.f
cd ..

csh -x ./compall 

cd ddi ; ./compddi ; cp ddikick.x ..; cd ..
csh ./lked gamess 00

export PUBCHEMQCPKGDIR=$PUBCHEMQCTOPDIR/pkg/$PUBCHEMQCARCH
rm -rf $PUBCHEMQCPKGDIR/gamess
rm $PUBCHEMQCPKGDIR/bin/rungms
mkdir -p $PUBCHEMQCPKGDIR/gamess
mkdir -p $PUBCHEMQCPKGDIR/bin
sed -i "s|set GMSPATH.*|set GMSPATH=$PUBCHEMQCPKGDIR/gamess|g" rungms
cp rungms $PUBCHEMQCPKGDIR/bin/rungms
cp ddikick.x $PUBCHEMQCPKGDIR/gamess
cp gamess.00.x $PUBCHEMQCPKGDIR/gamess
cp gms-files.csh $PUBCHEMQCPKGDIR/gamess
cp -r auxdata $PUBCHEMQCPKGDIR/gamess

pushd $PUBCHEMQCPKGDIR
tar cvfJ $PUBCHEMQCSETUPDIR/gamess_${GAMESSVERSION}_${PUBCHEMQCPKG_SUFFIX}.tar.xz gamess bin/rungms
popd

touch "$PUBCHEMQCSETUPDIR/.done_${NAME}_${PUBCHEMQCPKG_SUFFIX}"

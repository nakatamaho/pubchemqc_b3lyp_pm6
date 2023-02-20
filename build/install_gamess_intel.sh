#!/bin/sh

GAMESSVERSION=gamess.20141205.R1
WRKDIR=$PUBCHEMQCSETUPDIR/work_gamess_intel
FORTRAN=ifort
source /opt/intel/bin/compilervars.sh intel64

rm -rf $WRKDIR
mkdir $WRKDIR

cd $WRKDIR
tar xvfz $PUBCHEMQCARCHIVESDIR/$GAMESSVERSION/gamess-current.tar.gz
cd gamess

patch -p1 < $PUBCHEMQCARCHIVESDIR/$GAMESSVERSION/patch-gamess

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
setenv GMS_IFORT_VERNO  14
#         mathematical library setup
setenv GMS_MATHLIB         mkl
setenv GMS_MATHLIB_PATH    /opt/intel/mkl/lib/intel64
setenv GMS_MKL_VERNO      12-so
#         parallel message passing model setup
setenv GMS_DDI_COMM        sockets
#         LIBCCHEM CPU/GPU code interface
setenv GMS_LIBCCHEM        false
_EOF_

sed -i "s|%%GAMESS_BUILD_DIR%%|$WRKDIR|g" install.info

cd tools
cp actvte.code actvte.f
sed 's/*UNX/    /g' < actvte.code > actvte.f
gfortran -o actvte.x actvte.f
cd ..

sed -i -e "s/%%FORTRAN%%/$FORTRAN/g" comp
sed -i -e "s/%%FORTRAN%%/$FORTRAN/g" lked

csh -x ./compall 

cd ddi ; sed -i 's/stdout/stderr/g' src/* ; ./compddi ; cp ddikick.x ..; cd ..
csh ./lked gamess 00

mkdir -p $PUBCHEMQCPKGDIR/gamess_intel
mkdir -p $PUBCHEMQCPKGDIR/bin
sed -i "s|set GMSPATH.*|set GMSPATH=$PUBCHEMQCPKGDIR/gamess_intel|g" rungms
cp rungms $PUBCHEMQCPKGDIR/bin/rungms_intel
cp ddikick.x $PUBCHEMQCPKGDIR/gamess_intel
cp gamess.00.x $PUBCHEMQCPKGDIR/gamess_intel
cp gms-files.csh $PUBCHEMQCPKGDIR/gamess_intel
cp -r auxdata $PUBCHEMQCPKGDIR/gamess_intel


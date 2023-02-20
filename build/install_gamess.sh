#!/bin/sh

GAMESSVERSION=gamess.20141205.R1
WRKDIR=$PUBCHEMQCSETUPDIR/work_gamess
GFORTRANVERSION=4.4
FORTRAN=gfortran

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
setenv GMS_FORTRAN	  gfortran  # do not change here!
setenv GMS_GFORTRAN_VERNO %%GFORTRANVERSION%%
#         mathematical library setup
setenv GMS_MATHLIB         openblas
setenv GMS_MATHLIB_PATH    -L%%PUBCHEMQCPKGDIR%%/lib/
#         parallel message passing model setup
setenv GMS_DDI_COMM        sockets
#         LIBCCHEM CPU/GPU code interface
setenv GMS_LIBCCHEM        false
_EOF_

sed -i "s|%%GAMESS_BUILD_DIR%%|$WRKDIR|g" install.info
sed -i "s|%%PUBCHEMQCPKGDIR%%|$PUBCHEMQCPKGDIR|g" install.info
sed -i "s|%%FORTRAN%%|$FORTRAN|g" install.info
sed -i "s|%%GFORTRANVERSION%%|$GFORTRANVERSION|g" install.info

cd tools
cp actvte.code actvte.f
sed 's/*UNX/    /g' < actvte.code > actvte.f
$FORTRAN -o actvte.x actvte.f
cd ..

sed -i -e "s/%%FORTRAN%%/$FORTRAN/g" comp
sed -i -e "s/%%FORTRAN%%/$FORTRAN/g" lked
sed -i "s|set LDR='gfortran'|set LDR=\'$FORTRAN\'|g" lked

csh -x ./compall 

cd ddi ; sed -i 's/stdout/stderr/g' src/* ; ./compddi ; cp ddikick.x ..; cd ..
csh ./lked gamess 00

mkdir -p $PUBCHEMQCPKGDIR/bin
mkdir -p $PUBCHEMQCPKGDIR/gamess
sed -i "s|set GMSPATH.*|set GMSPATH=$PUBCHEMQCPKGDIR/gamess|g" rungms
cp rungms $PUBCHEMQCPKGDIR/bin/rungms
cp ddikick.x $PUBCHEMQCPKGDIR/gamess
cp gamess.00.x $PUBCHEMQCPKGDIR/gamess
cp gms-files.csh $PUBCHEMQCPKGDIR/gamess
cp -r auxdata $PUBCHEMQCPKGDIR/gamess

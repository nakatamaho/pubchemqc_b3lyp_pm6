if [ x"$qctopdir" = x"" ]; then
echo "Do 'source pubchemqc.sh'" 
exit
fi
rm -rf gamess
tar xvfz ../archives/gamess.20130501.R1/gamess-current.tar.gz
#tar xvfz ../archives/gamess.20120501.R2/gamess-current.tar.gz
cd gamess
patch -p1 < ../../archives/patch-gamess
cat > install.info << _EOF_
#!/bin/csh
#   compilation configuration for GAMESS
#   generated on
#   generated at
setenv GMS_BUILD_DIR       %%QCTOPDIR%%/build/gamess
setenv GMS_PATH            %%QCTOPDIR%%/build/gamess
#         machine type
setenv GMS_TARGET	linux64
#         FORTRAN compiler setup
setenv GMS_FORTRAN	ifort
setenv GMS_IFORT_VERNO	13
#setenv GMS_FORTRAN	gfortran
#setenv GMS_GFORTRAN_VERNO 4.6
#         mathematical library setup
setenv GMS_MATHLIB         mkl
setenv GMS_MATHLIB_PATH    /opt/intel/composerxe/mkl/lib/intel64
setenv GMS_MKL_VERNO       12
#         parallel message passing model setup
setenv GMS_DDI_COMM        sockets
#         LIBCCHEM CPU/GPU code interface
setenv GMS_LIBCCHEM        false
_EOF_


source /opt/intel/composerxe/bin/compilervars.sh intel64
sed -i.bak -e "s+%%QCTOPDIR%%+$qctopdir+g" install.info

cd tools
cp actvte.code actvte.f
sed 's/*UNX/    /g' < actvte.code > actvte.f
ifort -o actvte.x actvte.f
cd ..
pwd
source /opt/intel/composerxe/bin/compilervars.sh intel64
csh -x ./compall 
cd ddi ; sed -i 's/stdout/stderr/g' src/* ; ./compddi ; cp ddikick.x ..; cd ..
csh ./lked gamess 00
cp rungms $qctopdir/pkg/bin


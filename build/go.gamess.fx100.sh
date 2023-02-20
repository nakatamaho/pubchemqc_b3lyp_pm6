if [ x"$qctopdir" = x"" ]; then
echo "Do 'source pubchemqc.sh'" 
exit
fi
module load sparc
rm -rf gamess
tar xvfz ../archives/gamess.20130501.R1/gamess-current.tar.gz
#tar xvfz ../archives/gamess.20120501.R2/gamess-current.tar.gz
cd gamess
patch -p1 < ../../archives/patch-gamess-fx10

cat > install.info << _EOF_
#!/bin/csh
#   compilation configuration for GAMESS
#   generated on oakleaf-fx-4
setenv GMS_BUILD_DIR       %%QCTOPDIR%%/build/gamess
setenv GMS_PATH            %%QCTOPDIR%%/build/gamess
#         machine type
setenv GMS_TARGET          xtcos
#         FORTRAN compiler setup
setenv GMS_FORTRAN         mpifrtpx
#         mathematical library setup
setenv GMS_MATHLIB         SSL2MPI
#         parallel message passing model setup
setenv GMS_DDI_COMM        mpi
setenv GMS_MPI_LIB         Fujitsu-MPI
#         LIBCCHEM CPU/GPU code interface
setenv GMS_LIBCCHEM        false
_EOF_

sed -i.bak -e "s+%%QCTOPDIR%%+$qctopdir+g" install.info
sed -i.bak -e "s+%%QCTOPDIR%%+$qctopdir+g" rungms
cd tools
cp actvte.code actvte.f
sed 's/*UNX/    /g' < actvte.code > actvte.f
gfortran -o actvte.x actvte.f
cd ..
pwd

csh -x ./compall 
cd ddi ; ./compddi ; cp ddikick.x ..; cd ..
csh ./lked gamess 00
cp rungms $qctopdir/pkg/bin


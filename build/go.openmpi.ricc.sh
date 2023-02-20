if [ x"$qctopdir" = x"" ]; then
echo "Do 'source pubchemqc.sh'" 
exit
fi
OPENMPIVER=1.6.5
export CLTK_TARGET_MACHINE=pc
rm -rf openmpi-$OPENMPIVER
tar zxf ../archives/openmpi-$OPENMPIVER.tar.gz
cd openmpi-$OPENMPIVER
./configure CC=gcc CFLAGS=-m32 CXX=g++ CXXFLAGS=-m32 F77=gfortran FCFLAGS=-m32 FC=gfortran FFLAGS=-m32 --prefix=$qctopdir/openmpi
make
make install
rm -rf $qctopdir/openmpi/share/man

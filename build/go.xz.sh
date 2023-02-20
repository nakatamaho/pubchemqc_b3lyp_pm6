if [ x"$qctopdir" = x"" ]; then
echo "Do 'source pubchemqc.sh'" 
exit
fi

export CC=gcc
export CXX=g++
export CLTK_TARGET_MACHINE=pc
export CLTK_COMPILER_PC=gcc

XZVER=5.0.1
rm -rf xz-$XZVER
tar xfj ../archives/xz-$XZVER.tar.bz2
cd xz-$XZVER
./configure --prefix=$qctopdir/pkg
make install



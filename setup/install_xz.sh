XZVERSION=5.2.2
NAME=XZ-${XZVERSION}

if [ -e "$PUBCHEMQCSETUPDIR/.done_${NAME}_${PUBCHEMQCARCH}" ]; then
    echo "already installed"
    exit
fi

WRKDIR=$PUBCHEMQCSETUPDIR/work_xz
rm -rf $WRKDIR
mkdir $WRKDIR

cd $WRKDIR
tar xvfz  $PUBCHEMQCARCHIVESDIR/xz-$XZVERSION.tar.gz
cd xz-$XZVERSION
if [ x"$PUBCHEMQCARCH" = x"s64fx" ]; then
./configure --prefix=$PUBCHEMQCPKGDIR --build=x86_64-linux-gnu
else
./configure --prefix=$PUBCHEMQCPKGDIR
fi
make
make install

touch "$PUBCHEMQCSETUPDIR/.done_${NAME}_${PUBCHEMQCARCH}"



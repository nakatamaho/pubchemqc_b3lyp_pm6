COREUTILSVERSION=8.25

NAME=COREUTILS-${COREUTILSVERSION}

if [ -e "$PUBCHEMQCSETUPDIR/.done_${NAME}_${PUBCHEMQCARCH}" ]; then
    echo "already installed"
    exit
fi

WRKDIR=$PUBCHEMQCSETUPDIR/work_coreutils
rm -rf $WRKDIR
mkdir $WRKDIR

cd $WRKDIR
cat $PUBCHEMQCARCHIVESDIR/coreutils-$COREUTILSVERSION.tar.xz | unxz | tar xvf -
cd coreutils-$COREUTILSVERSION
if [ x"$PUBCHEMQCARCH" = x"s64fx" ]; then
./configure --prefix=$PUBCHEMQCPKGDIR --build=x86_64-linux-gnu
else
./configure --prefix=$PUBCHEMQCPKGDIR
fi
make 
make install

touch "$PUBCHEMQCSETUPDIR/.done_${NAME}_${PUBCHEMQCARCH}"

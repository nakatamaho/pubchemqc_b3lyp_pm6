NGVERSION=1.5beta1
NAME=NG-${NGVERSION}

if [ -e "$PUBCHEMQCSETUPDIR/.done_${NAME}_${PUBCHEMQCARCH}" ]; then
    echo "already installed"
    exit
fi

WRKDIR=$PUBCHEMQCSETUPDIR/work_ng
rm -rf $WRKDIR
mkdir $WRKDIR

cd $WRKDIR
tar xvfz $PUBCHEMQCARCHIVESDIR/ng-$NGVERSION.tar.gz
cd ng-$NGVERSION
cat $PUBCHEMQCARCHIVESDIR/ng_1.5~beta1-3.1build1.diff.gz | gunzip | patch -p1
if [ x"$PUBCHEMQCARCH" = x"s64fx" ]; then
./configure --prefix=$PUBCHEMQCPKGDIR --build=x86_64-linux-gnu
else
./configure --prefix=$PUBCHEMQCPKGDIR
fi
make
$PUBCHEMQCPKGDIR/bin/install -c -m 755 ng $PUBCHEMQCPKGDIR/bin/ng

touch "$PUBCHEMQCSETUPDIR/.done_${NAME}_${PUBCHEMQCARCH}"



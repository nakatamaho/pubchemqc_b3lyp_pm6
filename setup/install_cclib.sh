CCLIBVERSION=1.5.3.post1
NAME=CCLIB-${CCLIBVERSION}

if [ -e "$PUBCHEMQCSETUPDIR/.done_${NAME}_${PUBCHEMQCARCH}" ]; then
    echo "already installed"
    exit
fi

WRKDIR=$PUBCHEMQCSETUPDIR/work_cclib
rm -rf $WRKDIR
mkdir $WRKDIR

cd $WRKDIR
tar xvf $PUBCHEMQCARCHIVESDIR/cclib-${CCLIBVERSION}.tar.gz
cd cclib-$CCLIBVERSION
patch -p0 < $PUBCHEMQCARCHIVESDIR/patch-cclib-1.5.3

python3 setup.py build
python3 setup.py install --prefix $PUBCHEMQCPKGDIR
mkdir -p $PUBCHEMQCPYTHONPATH
cp -r cclib $PUBCHEMQCPYTHONPATH
touch "$PUBCHEMQCSETUPDIR/.done_${NAME}_${PUBCHEMQCARCH}"



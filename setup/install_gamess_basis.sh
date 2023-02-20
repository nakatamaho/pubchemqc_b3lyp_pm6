GAMESS_BASISVERSION=1.0
NAME=GAMESS_BASIS-${GAMESS_BASISVERSION}

if [ -e "$PUBCHEMQCSETUPDIR/.done_${NAME}_${PUBCHEMQCARCH}" ]; then
    echo "already installed"
    exit
fi

WRKDIR=$PUBCHEMQCSETUPDIR/work_gamess_basis
rm -rf $WRKDIR
mkdir $WRKDIR

cd $WRKDIR
tar xvfz $PUBCHEMQCARCHIVESDIR/gamess_basis-${GAMESS_BASISVERSION}.tar.gz
$PUBCHEMQCPKGDIR/bin/install -c -m 755 bin/insert_basis_gms.sh ${PUBCHEMQCPKGDIR}/bin/insert_basis_gms.sh
rm -rf ${PUBCHEMQCPKGDIR}/basis
mv basis ${PUBCHEMQCPKGDIR}/basis

touch "$PUBCHEMQCSETUPDIR/.done_${NAME}_${PUBCHEMQCARCH}"



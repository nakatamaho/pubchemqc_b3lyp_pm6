#!/bin/sh

SMASH_VERSIONs="gaussian-b3lyp 2.0.0 1.1.0"
WRKDIR=$PUBCHEMQCSETUPDIR/work_smash/$SMASHVERSION

for SMASH_VERSION in $SMASH_VERSIONs; do
rm -rf $WRKDIR
mkdir -p $WRKDIR
cd $WRKDIR
tar xvfz $PUBCHEMQCARCHIVESDIR/smash/smash-$SMASH_VERSION.tgz
cd smash
patch -p1 < $PUBCHEMQCARCHIVESDIR/smash/patch-smash-${SMASH_VERSION}
patch -p1 < $PUBCHEMQCARCHIVESDIR/smash/patch-smash-${SMASH_VERSION}-gnu
make -f Makefile.x86_64.noMPI
mkdir -p $PUBCHEMQCPKGDIR/bin
cp bin/smash $PUBCHEMQCPKGDIR/bin/smash_${SMASH_VERSION}

done

SMASHVERSION=gaussian-b3lyp

if [ x"$qctopdir" = x"" ]; then
echo "Do 'source qc.sh'"
exit
fi

module load sparc
rm -rf smash
tar xvfz ../archives/smash-$SMASHVERSION.tgz
cd smash
patch -p0 < ../../archives/patch-smash-fx100
make -f Makefile.fujitsu
cp bin/smash $qctopdir/pkg/bin
cd ..

if [ x"$qctopdir" = x"" ]; then
echo "Do 'source pubchemqc.sh'" 
exit
fi
UNRARVER=5.0.14
rm -rf unrar
tar zxf ../archives/unrarsrc-$UNRARVER.tar.gz
cd unrar
make
cp unrar $qctopdir/pkg/bin


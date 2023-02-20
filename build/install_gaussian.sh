#!/bin/sh

GAUSSIAN_VERSIONs="g09_E.01"
for installprefix in $GAUSSIAN_VERSIONs; do

rm -rf $installprefix
tar xvfz $PUBCHEMQCARCHIVESDIR/gaussian/$installprefix/$installprefix.bin.tgz
rm -rf $PUBCHEMQCPKGDIR/$installprefix
mkdir -p $PUBCHEMQCPKGDIR/$installprefix
mkdir -p $PUBCHEMQCPKGDIR/bin
cp -r $installprefix/g09 $PUBCHEMQCPKGDIR/$installprefix
rm -f $PUBCHEMQCPKGDIR/$installprefix/g09/*.F
rm -f $PUBCHEMQCPKGDIR/$installprefix/g09/*.a
rm -rf $PUBCHEMQCPKGDIR/$installprefix/g09/tests

cat << _EOF_ > $PUBCHEMQCPKGDIR/bin/$installprefix
#!/bin/csh -f
#   usage:  gaussian09 InputFile 
# 
setenv g09root %%PUBCHEMQCPKGDIR%%/%%installprefix%%
setenv GAUSS_SCRDIR \$cwd
source \$g09root/g09/bsd/g09.login
setenv GAUSS_EXEDIR \$g09root/g09/
if (\$#argv == 0 ) then
	echo "Usage: gaussian09 <input file>"
else if (\$#argv == 1 ) then
	cat \$1 | \$g09root/g09/g09 
endif 
_EOF_

sed -i "s+%%PUBCHEMQCPKGDIR%%+$PUBCHEMQCPKGDIR+g" $PUBCHEMQCPKGDIR/bin/$installprefix
sed -i "s+%%installprefix%%+$installprefix+g" $PUBCHEMQCPKGDIR/bin/$installprefix

chmod +x $PUBCHEMQCPKGDIR/bin/$installprefix

done


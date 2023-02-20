ELEMENTS=`grep -A1 -e '^\s*#' -e '^\s*$' < Basisset | grep -v -e '^\s*$' -e '--'`
ECPS=`grep ECP < Basisset | grep - | awk '{print $1}'`
TOP=`head -1 Basisset`

for element in $TOP $ELEMENTS; do
    perl -ne "print if /^$element/ .. /^\n/p" < Basisset | head -1
done

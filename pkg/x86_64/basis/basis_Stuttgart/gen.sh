ELEMENTS=`grep -A1 -e '^\s*#' -e '^\s*$' < Basisset | grep -v -e '^\s*$' -e '--'`
ECPS=`grep ECP < Basisset | grep - | awk '{print $1}'`
TOP=`head -1 Basisset`

for element in $TOP $ELEMENTS; do
    perl -ne "print if /^$element/ .. /^\n/p" < Basisset > $element
    sed -i -e '1,1d' $element
done

for ecp in $ECPS; do
    perl -ne "print if /^(.*)$ecp(.*)$/ .. /^(.*)END(.*)$/p" < Basisset > ${ecp}
    head -1 ${ecp} > ${ecp}_head
    sed -i -e '1,1d' ${ecp}
    perl -ne 'print unless /^(.*)GEN(.*)$/ .. /^(.*)END(.*)$/' ${ecp} > ${ecp}_
    cat ${ecp}_head ${ecp}_ > ${ecp}
    rm ${ecp}_head ${ecp}_
done

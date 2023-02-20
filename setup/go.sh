#!/bin/bash

if [ x"$PUBCHEMQCTOPDIR" = x"" ]; then
    echo "Do 'source pubchemqc_settings.sh'"
    exit
fi

function _install_ ()
{
   bash -x $1 $2 2>&1 | tee log.$1.${PUBCHEMQCARCH}$2
}

export MAKEFLAGS='-j 1'

_install_ install_parallel.sh
_install_ install_xz.sh
_install_ install_coreutils.sh
_install_ install_tar.sh
_install_ install_ng.sh
_install_ install_gamess_basis.sh
_install_ install_numdiff.sh
_install_ install_cclib.sh
_install_ install_openbabel.sh
_install_ install_gamess.sh
#_install_ install_gamess.sh s64fx

DATE=`date "+%Y%m%d"`
rm -rf $PUBCHEMQCPKGDIR/include/eigen3
rm -rf $PUBCHEMQCPKGDIR/doc
rm -rf $PUBCHEMQCPKGDIR/share/cmake*
rm -rf $PUBCHEMQCPKGDIR/share/doc*
rm -rf $PUBCHEMQCPKGDIR/share/man*
rm -rf $PUBCHEMQCPKGDIR/share/info
pushd ${PUBCHEMQCTOPDIR} ; tar cvfj pkg.${PUBCHEMQCARCH}.${DATE}.tar.bz2 pkg ; popd

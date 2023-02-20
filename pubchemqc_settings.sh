#!/bin/bash

export PUBCHEMQCTOPDIR=/home/maho/b3lyp_pm6
_ARCH=`uname -p`
if [ x"$_ARCH" = x"s64fx" ] ; then
    export PUBCHEMQCARCH=s64fx
else
    export PUBCHEMQCARCH=x86_64

fi

_HOST=`hostname -s`
if echo $_HOST | grep hokusai ; then
    module load intel_python3/18.1.038
fi
export PUBCHEMQCARCHIVESDIR=$PUBCHEMQCTOPDIR/archives
export PUBCHEMQCSETUPDIR=$PUBCHEMQCTOPDIR/setup
export PUBCHEMQCPKGDIR=$PUBCHEMQCTOPDIR/pkg/$PUBCHEMQCARCH
export PUBCHEMQCTMPDIR=$PUBCHEMQCTOPDIR/tmp
export PATH=$PUBCHEMQCPKGDIR/bin:$PUBCHEMQCPKGDIR/openbabel/bin:$PUBCHEMQCTOPDIR/pkg/s64fx/bin:$PUBCHEMQCPKGDIR/openbabel/bin:$PATH
export LD_LIBRARY_PATH=$PUBCHEMQCHOSTPKGDIR/lib:$LD_LIBRARY_PATH
export BABEL_DATADIR=$PUBCHEMQCPKGDIR/openbabel/share/openbabel/2.4.1/
export BABEL_LIBDIR=$PUBCHEMQCPKGDIR/openbabel/lib/openbabel/2.4.1/
export PATH=$PUBCHEMQCPKGDIR/bin:$PATH
export PYTHONPATH="$PUBCHEMQCPKGDIR/lib64/python2.7/site-packages:$PYTHONPATH"

alias clean='rm -f *~ \#* Gau-* *.sh.[i,o,e,s]*'

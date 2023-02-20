#!/bin/bash
BACKUPDIR=/data/G18012/backup/pubchemqc/b3lyp_pm6/hokusai

if [ x"$PUBCHEMQCTOPDIR" = x"" ]; then
    echo "Do 'source pubchemqc.sh'"
    exit
fi

DONEs=`ls 00done/*/*results*`

for _done in $DONEs; do
    BASE=`basename "$_done" | sed 's/_results\.tar\.xz//g'`
    DIR=`dirname "$_done"`
    LOG=`ls 00work/$BASE/run_gms*sh.o* 2> /dev/null | head -1`
    if [ x"$LOG" != x"" ]; then
        mv ${LOG} $DIR/${BASE}.out
        xz $DIR/${BASE}.out
    fi
    rm -rf 00work/$BASE
done

_DATE=`date "+%Y%m%d"`
DONEs=`ls $PUBCHEMQCTOPDIR/pubchem/00done`

for _done in $DONEs; do
    if [ $_DATE -gt $_done ]; then
        echo "$_DATE"
        echo "$_done"
        cd $PUBCHEMQCTOPDIR/pubchem/00done/${_done}
        GO2ARCHIVE=`ls *_results.tar* *.out.*`
        GO2NOTYET=`ls *_notyet.tar*`
        tar cvf $PUBCHEMQCTOPDIR/pubchem/${_done}.tar $GO2ARCHIVE
        tar cvf $PUBCHEMQCTOPDIR/pubchem/${_done}_notyet.tar $GO2NOTYET
        cd $PUBCHEMQCTOPDIR/pubchem/; md5sum ${_done}.tar > ${_done}.tar.md5sum; md5sum ${_done}_notyet.tar > ${_done}_notyet.tar.md5sum
        openssl enc -e -aes-256-cbc -salt -k RrAeBOPXUJw61k1v -in ${_done}.tar -out ${_done}.tar_encrypt
        mv ${_done}.tar_encrypt ${_done}.tar
        openssl enc -e -aes-256-cbc -salt -k RrAeBOPXUJw61k1v -in ${_done}_notyet.tar -out ${_done}_notyet.tar_encrypt
        mv ${_done}_notyet.tar_encrypt ${_done}_notyet.tar
        mv ${_done}.tar.md5sum ${_done}.tar ${_done}_notyet.tar ${_done}_notyet.tar.md5sum ${BACKUPDIR}/
        mkdir -p $PUBCHEMQCTOPDIR/pubchem/notyet/${_done} ; cd $PUBCHEMQCTOPDIR/pubchem/notyet/${_done} ; tar xf ${BACKUPDIR}/${_done}_notyet.tar
        cd $PUBCHEMQCTOPDIR/pubchem/00done/${_done}
        mv $GO2NOTYET $PUBCHEMQCTOPDIR/pubchem/notyet/${_done}
        cd $PUBCHEMQCTOPDIR/pubchem/00done/
        rm -rf ${_done}
    fi
done

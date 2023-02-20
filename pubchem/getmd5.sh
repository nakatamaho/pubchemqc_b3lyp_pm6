#!/bin/sh

FILES=`ls /arc/Q17101/pubchemqc/pm6/compounds_20180425/*.tar.xz`
_TMPDIR=/dev/shm/maho/
rm -rf /dev/shm/*
mkdir -p $_TMPDIR

for file in $FILES; do
     cd $_TMPDIR
     rm -rf *
     cp $file $_TMPDIR
     __file=`basename $file`
     if [ -e /home/maho/b3lyp_pm6/pubchem/compounds_20180425_md5s/${__file}.md5 ]; then
         echo "$__file already done"
         continue
     fi
     cd $_TMPDIR ; md5sum `basename $file` > l2
     diff -u ${file%.*}.md5sum l2
     FAILED=$?
     if [ "$FAILED" = "1" ]; then
         echo "$__file : FAILED"
     else
         echo "$__file : md5 is okay"
     fi
     rm -rf p
     mkdir p
     cd p
     tar xfJ ../$__file
     cd Com*
     rm -f $_TMPDIR/${__file}.md5
     find . -type f -name "*json" | xargs rm
     find . -type f -name "*inchisame" | xargs rm
     find . -type f -name "*mulliken" | xargs rm
     find . -type f -name "*" | xargs md5sum >> $_TMPDIR/${__file}.md5
     sort -k 2 $_TMPDIR/${__file}.md5 >  $_TMPDIR/l
     mv $_TMPDIR/l /home/maho/b3lyp_pm6/pubchem/compounds_20180425_md5s/${__file}.md5 
done

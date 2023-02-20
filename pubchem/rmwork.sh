#!/bin/sh
TOPDIR=/home/maho/b3lyp_pm6/pubchem
cd $TOPDIR/00work
find . -type d -empty | xargs rm -rf
cd $TOPDIR
DIRS1=`ls 00work`
for _dir1 in $DIRS1; do
    cd $TOPDIR/00work/$_dir1
    DIRS2=`ls`
    for _dir2 in $DIRS2; do
#        grep touch $_dir2/*sh.o* 2>/dev/null | grep DONE 2>&1 /dev/null
        grep touch $_dir2/*sh.o* | grep DONE 
        SUCCESS=$?
        if [ "$SUCCESS" = "0" ]; then
            rm -rf $TOPDIR/00work/$_dir1/$_dir2
        fi  
    done
done

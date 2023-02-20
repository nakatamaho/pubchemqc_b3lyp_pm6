FILES=`ls notyet_old/*tar.xz`
rm -rf /dev/shm/*
mkdir -p /home/maho/b3lyp_pm6/pubchem/notyet_new/
mkdir -p /dev/shm/maho/

for _file in $FILES; do
   cd  /home/maho/b3lyp_pm6/pubchem
   rm -rf /dev/shm
   mkdir -p /dev/shm/maho
   tar xvfJ $_file -C /dev/shm/maho/
   __file=`basename $_file`
   ___file=${__file%.*}
   cd /dev/shm/maho/Com* ; tar cvf /dev/shm/$___file .
   mv /dev/shm/$___file /home/maho/b3lyp_pm6/pubchem/notyet/20200601/
done 

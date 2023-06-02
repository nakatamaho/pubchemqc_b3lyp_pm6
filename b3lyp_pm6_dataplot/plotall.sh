DIRs="all  CHNOPSFCl300noSalt  CHNOPSFCl500noSalt  CHNOPSFClNaKMgCa500  CHON300noSalt  CHON500noSalt"

for _dir in $DIRs; do
    cd /work1/pubchemqc_b3lyp_pm6/b3lyp_pm6_dataplot/$_dir
    rm -f *png *svg *eps
    bash -x go.sh 2>&1 | tee log.go.sh
#    bash -x plot.sh 2>&1 | tee log.plot.sh
done

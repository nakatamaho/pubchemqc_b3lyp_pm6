_TOPDIR=/work1/pubchemqc_b3lyp_pm6/b3lyp_pm6_dataplot
SUBSETNAME=CHNOPSFCl300noSalt
PM6VER="2.0.0"
B3LYP_PM6VER="1.0.1"

########################
TOPDIR=${_TOPDIR}/${SUBSETNAME}
B3LYPDATANAME=b3lyp_pm6_${SUBSETNAME}
PM6DATANAME=pm6opt_${SUBSETNAME}
MERGEDDATANAME=pm6_b3lyp_pm6_${SUBSETNAME}
########################
cd $TOPDIR

/usr/bin/time python3 homolumogap.py ${MERGEDDATANAME}
/usr/bin/time python3 dipole.py ${MERGEDDATANAME}
/usr/bin/time python3 homo.py ${MERGEDDATANAME}
/usr/bin/time python3 lumo.py ${MERGEDDATANAME}

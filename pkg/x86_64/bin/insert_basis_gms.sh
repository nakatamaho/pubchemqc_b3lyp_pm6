#!/bin/bash

FILEIN=$1
FILEOUT=$2

rm -f tmp_$FILEIN
__ELEMENTs=`cat $FILEIN | sed -ne '/DATA/,/END/p' | sed -e '1,3d' -e '$d' > tmp_$FILEIN`
ELEMENTs=`cat tmp_$FILEIN | awk '{printf "%d \n", $2}' | sort | uniq`
ELEMENTs_wDUPE=`cat tmp_$FILEIN | awk '{printf "%d ", $2}'`


#basis H-Kr ... 6-31G* 1-36
#basis Rb-Rn ... Def2-SV(P) 37-56, 72-86
#basis Ce-Yb ... Stuttgart RSC 1997 ECP 57-70
#basis Th-Lr ... Stuttgart RSC 1997 ECP 89-103
#unsupported 71

cp $FILEIN $FILEOUT

declare -a ELEMENTNAMEs=("Dummy" "Hydrogen" "Helium" "Lithium" "Beryllium" "Boron" "Carbon" "Nitrogen" "Oxygen" "Fluorine" "Neon" "Sodium" "Magnesium" "Aluminium" "Silicon" "Phosphorous" "Sulfur" "Chlorine" "Argon" "Potassium" "Calcium" "Scandium" "Titanium" "Vanadium" "Chromium" "Manganese" "Iron" "Cobalt" "Nickel" "Copper" "Zinc" "Gallium" "Germanium" "Arsenic" "Selenium" "Bromine" "Krypton" "Rubidium" "Strontium" "Yttrium" "Zirconium" "Niobium" "Molybdenum" "Technetium" "Ruthenium" "Rhodium" "Palladium" "Silver" "Cadmium" "Indium" "Tin" "Antimony" "Tellurium" "Iodine" "Xenon" "Caesium" "Barium" "Lanthanum" "Cerium" "Praseodymium" "Neodymium" "Promethium" "Samarium" "Europium" "Gadolinium" "Terbium" "Dysprosium" "Holmium" "Erbium" "Thulium" "Ytterbium" "Lutetium" "Hafnium" "Tantalum" "Tungsten" "Rhenium" "Osmium" "Iridium" "Platinum" "Gold" "Mercury" "Thallium" "Lead" "Bismuth" "Polonium" "Astatine" "Radon" "Francium" "Radium" "Actinium" "Thorium" "Protactinium" "Uranium" "Neptunium" "Plutonium" "Americium" "Curium" "Berkelium" "Californium" "Einsteinium" "Fermium" "Mendelevium" "Nobelium" "Lawrencium" "Rutherfordium" "Dubnium" "Seaborgium" "Bohrium" "Hassium" "Meitnerium" "Darmstadtium" "Roentgenium" "Copernicium" "Nihonium" "Flerovium" "Moscovium" "Livermorium" "Tennessine" "Oganesson")

declare -a ELEMENTSYMBOLs=("Xx" "H" "He" "Li" "Be" "B" "C" "N" "O" "F" "Ne" "Na" "Mg" "Al" "Si" "P" "S" "Cl" "Ar" "K" "Ca" "Sc" "Ti" "V" "Cr" "Mn" "Fe" "Co" "Ni" "Cu" "Zn" "Ga" "Ge" "As" "Se" "Br" "Kr" "Rb" "Sr" "Y" "Zr" "Nb" "Mo" "Tc" "Ru" "Rh" "Pd" "Ag" "Cd" "In" "Sn" "Sb" "Te" "I" "Xe" "Cs" "Ba" "La" "Ce" "Pr" "Nd" "Pm" "Sm" "Eu" "Gd" "Tb" "Dy" "Ho" "Er" "Tm" "Yb" "Lu" "Hf" "Ta" "W" "Re" "Os" "Ir" "Pt" "Au" "Hg" "Tl" "Pb" "Bi" "Po" "At" "Rn" "Fr" "Ra" "Ac" "Th" "Pa" "U" "Np" "Pu" "Am" "Cm" "Bk" "Cf" "Es" "Fm" "Md" "No" "Lr" "Rf" "Db" "Sg" "Bh" "Hs" "Mt" "Ds" "Rg" "Cn" "Nh" "Fl" "Mc" "Lv" "Ts" "Og")

is_ecp="NO"
for element in $ELEMENTs; do
    if (( element >= 37 )) ;
    then
	is_ecp="YES" 
    fi
done

#if ECP is used, nothing should be done
if [ ${is_ecp} = "YES" ]; then
    sed -i -e "/\$BASIS/d" $FILEOUT
else
    exit
fi

DIR=`dirname $0`

for element in $ELEMENTs; do
    ELEMENTNAME=${ELEMENTNAMEs[element]}
    if (( element < 37 )) ;
    then
	BASISSET="$DIR/../basis/basis_631Gd"
    fi
    if (( element >= 37 && element <=57 )) ;
    then
	BASISSET="$DIR/../basis/basis_Def2-SV_P_"
    fi
    if (( element >= 71 && element <=86 )) ;
    then
	BASISSET="$DIR/../basis/basis_Def2-SV_P_"
    fi
    if (( element >= 58 && element <=70 )) ;
    then
	BASISSET="$DIR/../basis/basis_Stuttgart"
    fi    
    if (( element >= 89 && element <=103 )) ;
    then
	BASISSET="$DIR/../basis/basis_Stuttgart"
    fi    
    sed -i -e "/ ${element}\.0 /r ${BASISSET}/${ELEMENTNAME^^}" $FILEOUT
done

if [ ${is_ecp} = "YES" ]; then
    echo ' $ECP' >> $FILEOUT
    for element in $ELEMENTs_wDUPE; do
	ELEMENTSYMBOL=${ELEMENTSYMBOLs[element]}
        if (( element < 37 )) ;
        then
              echo "  ${ELEMENTSYMBOL}-ECP NONE" >> $FILEOUT
	fi
        if (( element >= 37 && element <= 57 )) ;
        then
            BASISSET="$DIR/../basis/basis_Def2-SV_P_"
            cat "${BASISSET}/${ELEMENTSYMBOL^^}-ECP" >> $FILEOUT
	fi      
        if (( element >= 71 && element <=86 )) ;
        then
   	    BASISSET="$DIR/../basis/basis_Def2-SV_P_"
            cat "${BASISSET}/${ELEMENTSYMBOL^^}-ECP" >> $FILEOUT
        fi
        if (( element >= 58 && element <=70 )) ;
        then
	    BASISSET="$DIR/../basis/basis_Stuttgart"
            cat "${BASISSET}/${ELEMENTSYMBOL^^}-ECP" >> $FILEOUT
        fi    
        if (( element >= 89 && element <=103 )) ;
        then
   	    BASISSET="$DIR/../basis/basis_Stuttgart"
            cat "${BASISSET}/${ELEMENTSYMBOL^^}-ECP" >> $FILEOUT
        fi    
    done
    echo ' $END' >>$FILEOUT
fi
rm -f tmp_$FILEIN

import json
import sys

print("cid,formula,cansmi,b3lyp_pm6_gap,b3lyp_pm6_homo,b3lyp_pm6_lumo,b3lyp_pm6_dipole");
with open(sys.argv[1]) as fin:
    for line in fin:
        _line = line
        line = _line.rstrip(", \n")
        data = json.loads(line)
        print( str(data['cid']) + "," 
             + str(data['data']['pubchem']['B3LYP@PM6']['formula']) + "," 
             + "\"" + str(data['data']['pubchem']['B3LYP@PM6']['openbabel']['Canonical SMILES']) + "\""  + "," 
             + str(data['data']['pubchem']['B3LYP@PM6']['properties']['energy']['alpha']['gap']) + "," 
             + str(data['data']['pubchem']['B3LYP@PM6']['properties']['energy']['alpha']['homo']) + "," 
             + str(data['data']['pubchem']['B3LYP@PM6']['properties']['energy']['alpha']['lumo']) + "," 
             + str(data['data']['pubchem']['B3LYP@PM6']['properties']['total dipole moment'])
             )
        

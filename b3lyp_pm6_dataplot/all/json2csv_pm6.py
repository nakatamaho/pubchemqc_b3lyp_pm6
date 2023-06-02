import json
import sys

print("cid,formula,cansmi,pm6_gap,pm6_homo,pm6_lumo,pm6_dipole");
with open(sys.argv[1]) as fin:
    for line in fin:
        _line = line
        line = _line.rstrip(", \n")
        data = json.loads(line)
        if str(data['state']) == "S0":
            print( str(data['cid']) + "," 
                 + str(data['data']['pubchem']['molecular formula']) + "," 
                 + "\"" + str(data['data']['pubchem']['PM6']['openbabel']['Canonical SMILES']) + "\""  + "," 
                 + str(data['data']['pubchem']['PM6']['properties']['energy']['alpha']['gap']) + "," 
                 + str(data['data']['pubchem']['PM6']['properties']['energy']['alpha']['homo']) + "," 
                 + str(data['data']['pubchem']['PM6']['properties']['energy']['alpha']['lumo']) + "," 
                 + str(data['data']['pubchem']['PM6']['properties']['total dipole moment'])
                 )
        
        if str(data['state']) == "D0":
            print( str(data['cid']) + "," 
                 + str(data['data']['pubchem']['molecular formula']) + "," 
                 + "\"" + str(data['data']['pubchem']['PM6']['openbabel']['Canonical SMILES']) + "\""  + "," 
                 + str(data['data']['pubchem']['PM6']['properties']['energy']['alpha']['gap']) + "," 
                 + str(data['data']['pubchem']['PM6']['properties']['energy']['alpha']['homo']) + "," 
                 + str(data['data']['pubchem']['PM6']['properties']['energy']['alpha']['lumo']) + "," 
                 + str(data['data']['pubchem']['PM6']['properties']['total dipole moment'])
                 )
        


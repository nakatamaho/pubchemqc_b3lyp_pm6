import pandas as pd
import sys

pd.set_option('display.max_rows', None)
pd.set_option('display.width', None)

df_pm6 = pd.read_csv(sys.argv[1], index_col=0)
df_b3lyp_pm6 = pd.read_csv(sys.argv[2], index_col=0)

df = pd.merge(df_pm6, df_b3lyp_pm6, on=['cid'])

print("cid,formula,cansmi,pm6_gap,pm6_homo,pm6_lumo,pm6_dipole,b3lyp_pm6_gap,b3lyp_pm6_homo,b3lyp_pm6_lumo,b3lyp_pm6_dipole")
for index, row in df.iterrows():
    if (row[0] == row[6]):
        if (row[1] == row[7]):
            print(str(index) + "," + str(row[0]) + ",\"" + str(row[1]) + "\"," + str(row[2]) + "," + str(row[3]) + "," + str(row[4]) + "," + str(row[5]) + "," + str(row[8]) + "," + str(row[9])+ "," + str(row[10])+ "," + str(row[11]) )



 


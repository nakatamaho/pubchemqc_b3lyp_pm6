import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from scipy.stats import binned_statistic
import sys
import glob

basename = sys.argv[1]
csvfiles = sorted(glob.glob(basename  + "/*.csv"))
#csvfiles = sorted(glob.glob(basename  + "/*000000*.csv"))
df_from_each_file = (pd.read_csv(f) for f in csvfiles)
df = pd.concat(df_from_each_file, ignore_index=True)

df['mw'] = df['mw'].fillna(0).astype(np.float64)
xx = df['mw']

plt.rcParams["font.size"] = 22
plt.rcParams["figure.figsize"] = [294/25.4, 210/25.4]
plt.subplots_adjust(left=0.15,right=0.95)

binwidth=10
plt.xlabel("Molecular weight")
plt.ylabel("Frequency")
bins=(np.arange(min(xx), max(xx) + binwidth, binwidth))
freq,bins_,_=plt.hist(xx, bins=bins, label="binsize=" + str(binwidth), edgecolor='k')

plt.savefig("mw_b3lyp_pm6.eps",transparent=True)
plt.savefig("mw_b3lyp_pm6.svg",transparent=True)
plt.savefig("mw_b3lyp_pm6.png",transparent=True)

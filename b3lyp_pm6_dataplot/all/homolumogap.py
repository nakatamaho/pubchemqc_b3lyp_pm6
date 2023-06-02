import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from sklearn.linear_model import LinearRegression
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.ticker import FuncFormatter
import sys
import os
import glob

def comma_formatter(x, pos):
    return '{:,.0f}'.format(x)

#pd.set_option('display.max_rows', None)
#pd.set_option('display.width', None)

basename = sys.argv[1]
csvfiles = sorted(glob.glob(basename  + "/*.csv"))
df_from_each_file = (pd.read_csv(f) for f in csvfiles)
df = pd.concat(df_from_each_file, ignore_index=True)

print(df)

pd.set_option('display.max_rows', None)
pd.set_option('display.max_columns', None)

####
_df=df[df['b3lyp_pm6_dipole'] < 100.0]
df = _df.reset_index(drop=True)
_df=df[df['pm6_dipole'] < 100.0]
df = _df.reset_index(drop=True)
_df=df[df['b3lyp_pm6_gap'] < 100.0]
df = _df.reset_index(drop=True)
_df=df[df['pm6_gap'] < 100.0]
df = _df.reset_index(drop=True)
_df=df[df['b3lyp_pm6_homo'] < 0.5]
df = _df.reset_index(drop=True)
_df=df[df['b3lyp_pm6_homo'] > -15.0]
df = _df.reset_index(drop=True)
_df=df[df['pm6_homo'] > -15.0]
df = _df.reset_index(drop=True)
_df=df[df['b3lyp_pm6_lumo'] < 10.0]
df = _df.reset_index(drop=True)
_df=df[df['pm6_lumo'] < 10.0]
df = _df.reset_index(drop=True)
####

x_bin_edges = np.arange(-1000, +1000, 0.1)
y_bin_edges = np.arange(-1000, +1000, 0.1)
bins=([x_bin_edges, y_bin_edges])

x=df['pm6_gap']
y=df['b3lyp_pm6_gap']

mag=1

# histogram the data
hh, locx, locy = np.histogram2d(x, y, bins=bins)

# Sort the points by density, so that the densest points are plotted last
z = np.array([hh[np.argmax(a<=locx[1:]),np.argmax(b<=locy[1:])] for a,b in zip(x,y)])
idx = z.argsort()
x2, y2, z2 = x[idx], y[idx], z[idx]

plt.rcParams["font.size"] = 25 * mag
plt.rcParams["figure.figsize"] = [294/25.4, 210/25.4]

plt.xlabel("HOMO-LUMO GAP by PM6//PM6 in eV")
plt.ylabel("HOMO-LUMO GAP by B3LYP/6-31G*//PM6 in eV", fontsize=20)
#plt.xlim([0,17])
#plt.ylim([0,15])

X = df['pm6_gap'].to_numpy().reshape(-1,1)
Y = df['b3lyp_pm6_gap'].to_numpy().reshape(-1,1)

plt.gca().set_rasterization_zorder(0) # zorder < 0 

linear_regressor = LinearRegression()  # create object for the class
linear_regressor.fit(X, Y)  # perform linear regression
Y_pred = linear_regressor.predict(X)  # make predictions
plt.plot(X, Y_pred, color='red', linewidth= 5.0)
#plt.scatter(x2, y2, c=z2, cmap='Blues', marker='.', zorder=-10, vmin=100)
plt.scatter(x2, y2, c=z2, cmap='jet', marker='.', zorder=-10)
a=linear_regressor.coef_[0]
b=linear_regressor.intercept_
c=linear_regressor.score(X,Y)

plt.text(2, 14, r'$y='+ str(round(a[0],3)) +' x' + str(round(b[0],3)) +'$' , horizontalalignment='left',fontsize=32)
plt.text(2, 12.5, r'$r^{2} = ' + str(round(c,3)) +'$' , horizontalalignment='left',fontsize=32)

plt.gca().set_rasterization_zorder(0) # zorder < 0 
#plt.colorbar(ticks=[1, 100,20000,40000,60000,80000,100000,120000])

cbar = plt.colorbar()
comma_format = FuncFormatter(comma_formatter)
cbar.ax.yaxis.set_major_formatter(comma_format)

xlim = plt.gca().get_xlim()
start = np.ceil(xlim[0] / 2) * 2
end = np.floor(xlim[1] / 2) * 2
xticks = np.arange(start, end + 2, 2)
plt.xticks(xticks)

ylim = plt.gca().get_ylim()
start = np.ceil(ylim[0] / 2) * 2
end = np.floor(ylim[1] / 2) * 2
yticks = np.arange(start, end + 2, 2)
plt.yticks(yticks)

plt.title('PubChemQC B3LYP/6-31G*//PM6 HOMO-LUMO gap', pad=20,fontsize=28)
plt.savefig(basename + ".homolumogap.eps",transparent=True)
plt.savefig(basename + ".homolumogap.svg",transparent=True)
plt.savefig(basename + ".homolumogap.png",transparent=True)

###### 3d ######

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

x = df['pm6_gap'].to_numpy().reshape(1,-1)[0]
y = df['b3lyp_pm6_gap'].to_numpy().reshape(1,-1)[0]

hist, xedges, yedges = np.histogram2d(x, y, bins=bins)

# The start of each bucket.
xpos, ypos = np.meshgrid(xedges[:-1], yedges[:-1])

xpos = xpos.flatten()
ypos = ypos.flatten()
zpos = np.zeros_like(xpos)

# The width of each bucket.
dx, dy = np.meshgrid(xedges[1:] - xedges[:-1], yedges[1:] - yedges[:-1])

dx = dx.flatten()
dy = dy.flatten()
dz = hist.flatten()

cm = plt.get_cmap('jet')

comma_format = FuncFormatter(comma_formatter)
ax.zaxis.set_major_formatter(comma_format)

nonzero_indices = np.nonzero(dz)
ax.bar3d(xpos[nonzero_indices], ypos[nonzero_indices], zpos[nonzero_indices], dx[nonzero_indices], dy[nonzero_indices], dz[nonzero_indices], color=cm(dz[nonzero_indices] / np.max(dz[nonzero_indices])), alpha=0.3)

ax.set_title("PubChemQC B3LYP/6-31G*//PM6 HOMO-LUMO gap",y=1.0, pad=-30, fontsize=25)
ax.set_xlabel("HOMO-LUMO gap by PM6//PM6 in eV", fontsize=18, labelpad=18)
ax.set_ylabel("HOMO-LUMO gap by B3LYP/6-31G*//PM6 in eV", fontsize=18, labelpad=33)
ax.tick_params(axis='both', labelsize=16)
ax.tick_params(axis='z', labelsize=18, pad=20)

xlim = ax.get_xlim()
start_x = np.ceil(xlim[0] / 2) * 2
end_x = np.floor(xlim[1] / 2) * 2
xticks = np.arange(start_x, end_x + 2, 2)
ax.set_xticks(xticks)

ylim = ax.get_ylim()
start_y = np.ceil(ylim[0] / 2) * 2
end_y = np.floor(ylim[1] / 2) * 2
yticks = np.arange(start_y, end_y + 2, 2)
ax.set_yticks(yticks)

for ii in range(45,46,10):
    ax.view_init(elev=10., azim=ii)
    plt.savefig(basename + ".homolumogap.3d.%03d.eps" % ii ,transparent=True)
    plt.savefig(basename + ".homolumogap.3d.%03d.svg" % ii ,transparent=True)
    plt.savefig(basename + ".homolumogap.3d.%03d.png" % ii ,transparent=True)


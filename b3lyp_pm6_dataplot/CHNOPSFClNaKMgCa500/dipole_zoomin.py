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

basename = sys.argv[1]
csvfiles = sorted(glob.glob(basename  + "/*0000000*.csv"))
#csvfiles = sorted(glob.glob(basename  + "/*chon300nosalt.001*.csv"))
df_from_each_file = (pd.read_csv(f) for f in csvfiles)
df = pd.concat(df_from_each_file, ignore_index=True)

print(df)

###### 3d ######
x_bin_edges = np.arange(-1000, +1000, 0.1)
y_bin_edges = np.arange(-1000, +1000, 0.1)
bins=([x_bin_edges, y_bin_edges])

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

x = df['pm6_dipole'].to_numpy().reshape(1,-1)[0]
y = df['b3lyp_pm6_dipole'].to_numpy().reshape(1,-1)[0]

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

limit=10
_alpha=0.88
xpos_filtered = xpos[(0 <= xpos) & (xpos <= limit+_alpha) & (0 <= ypos) & (ypos <= limit+_alpha)]
ypos_filtered = ypos[(0 <= xpos) & (xpos <= limit+_alpha) & (0 <= ypos) & (ypos <= limit+_alpha)]
zpos_filtered = zpos[(0 <= xpos) & (xpos <= limit+_alpha) & (0 <= ypos) & (ypos <= limit+_alpha)]
dx_filtered = dx[(0 <= xpos) & (xpos <= limit+_alpha) & (0 <= ypos) & (ypos <= limit+_alpha)]
dy_filtered = dy[(0 <= xpos) & (xpos <= limit+_alpha) & (0 <= ypos) & (ypos <= limit+_alpha)]
dz_filtered = dz[(0 <= xpos) & (xpos <= limit+_alpha) & (0 <= ypos) & (ypos <= limit+_alpha)]
ax.set_xlim(0, limit)
ax.set_ylim(0, limit)

nonzero_indices = np.nonzero(dz_filtered)
ax.bar3d(xpos_filtered[nonzero_indices], ypos_filtered[nonzero_indices], zpos_filtered[nonzero_indices], dx_filtered[nonzero_indices], dy_filtered[nonzero_indices], dz_filtered[nonzero_indices], color=cm(dz_filtered[nonzero_indices] / np.max(dz_filtered[nonzero_indices])), alpha=0.3)

ax.set_title("CHNOPSFClNaKMgCa500 dipole moment",y=1.0, pad=-30)
ax.set_xlabel("Dipole moment by PM6//PM6 in debye", fontsize=15, labelpad=30)
ax.set_ylabel("Dipole moment by B3LYP/6-31G*//PM6 in debye", fontsize=15, labelpad=30)
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
    plt.savefig(basename + ".dipole_zoomin.3d.%03d.eps" % ii ,transparent=True)
    plt.savefig(basename + ".dipole_zoomin.3d.%03d.svg" % ii ,transparent=True)
    plt.savefig(basename + ".dipole_zoomin.3d.%03d.png" % ii ,transparent=True)

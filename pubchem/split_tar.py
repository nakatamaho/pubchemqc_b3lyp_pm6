import os
import tarfile
import sys
import glob
import copy
import shutil
import lzma
from operator import attrgetter
import subprocess
 
file=sys.argv[1]
filesize=os.path.getsize(file)
file_basename=os.path.basename(file)
file_dirnamename=os.path.dirname(file)
_filename, ext = os.path.splitext(file_basename)
filename, ext = os.path.splitext(_filename)

print ("start reading " + file)
tar = tarfile.open(file, bufsize=20*1024*1024*1024, mode='r:xz') #20GB
members=tar.getmembers()
print ("done reading " + file)

compounds = []
for member in members:
    if member.name.find("xyz") > -1:
        _m = member.name.split("/")
        compounds.append(_m[1])
compounds_uniq=list(set(compounds))
compounds_uniq.sort()

chunksize=256
compounds_dd=[compounds_uniq[i:i+chunksize] for i in range(0,len(compounds_uniq),chunksize)]
#print(len(compounds_dd))

__tar = {}
for i in range(len(compounds_dd)):
    suffix = '%03d' % (i+1)
    __tar[i] = tarfile.open(filename + ".splitted." + suffix + ".tar", mode='a')

for i in compounds_dd:
    index = compounds_dd.index(i)
#    print(index)
    for member in members:
        _m=member.name.split("/")
        if (len(_m) == 3): 
            if _m[1] in i:
                a = tar.extractfile(member)
                _member = member
                _member.name = _m[1] + "/" + _m[2]
                __tar[index].addfile(_member,fileobj=a)

print ("done splitting " + file)

for i in range(len(compounds_dd)):
    __tar[i].close()
    suffix = '%03d' % (i+1)
    subprocess.call ( ["xz", filename + ".splitted." + suffix + ".tar" ])

print ("done compressing " + file)

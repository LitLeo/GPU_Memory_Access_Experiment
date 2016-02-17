import os
import string
import re
import getopt
import sys
# -*- coding: UTF-8 -*-

def usage():
    print  "SYNOPSIS \n\
    [-f data_form] [-m memory_location] [-s size] [-a access_num_per_thread] [-b block_size] [-c data_content] [-m access_mode] [-t step]\n\
DESCRIPTION \n\
    -f     1D,2D,tree \n\
    -l     Global, Shared, Constant \n\
    -s     global_memory[1024,4096,10240,40960,102400,1024000],shared_memory[512, 1024, 4096, 10240] \n\
    -a     1, 2, 4 \n\
    -b     256, 512, 1024 \n\
    -c     dc_random, dc_standard_normal, dc_poisson, dc_uniform, dc_geometric, dc_exponential \n\
    -m     am_sequential, am_step, am_random, am_standard_normal, am_poisson, am_geometric, am_exponential \n\
    -t     [1,2,4] \n\
EXAMPLE \n\
    python out_process.py -f 1D -l Global -s 1024 -a 2 -b 512 -c dc_random -m am_sequential -t 1"

class Case(object):
    """docstring for Case"""
    def __init__(self, df, ml, ds, anpt, bs, dc, am, rt):
        super(Case, self).__init__()
        self.data_form = df
        self.memory_location = ml
        self.data_size = ds
        self.access_num_per_thread = anpt
        self.block_size = bs
        self.data_content = dc
        self.access_mode = am
        self.run_time = rt

    def printf(self):
        print self.data_form + " " + self.memory_location + " " + self.data_size + " " + self.access_num_per_thread \
         + " " + self.block_size + " " + self.data_content + " " + self.access_mode + " " + self.run_time

# df_1D Global: size=512 access_num_per_thread=1 block_size=256 data_content=dc_random access_mode=am_sequential runTime=0.001664 ms
all_case = []   

file_buffer = open("1D_out.txt")

alllines = file_buffer.readlines()
for line in alllines:
    if len(line)==0:
        continue
    if line.count('\n')==len(line):
        continue
    case = Case(
                re.search('df_(\w*) .*', line).group(1),
                re.search('df_.* (.*):.*', line).group(1),
                re.search('df_.*: size=(\d*) .*', line).group(1),
                re.search('df_.*access_num_per_thread=(\d) .*', line).group(1),
                re.search('df_.*block_size=(\d*) .*', line).group(1),
                re.search('df_.*data_content=(.*) a.*', line).group(1),
                re.search('df_.*access_mode=(\w*) .*', line).group(1),
                re.search('df_.*runTime=(.*) m*', line).group(1))
    if line.find('step') != -1:
        setattr(case, 'step', re.search('.*step=(\d).*', line).group(1))
        # print re.search('.*step=(\d).*', line).group(1)
    all_case.append(case)
file_buffer.close()

# print len(all_case)

dicts = {}

opts, args = getopt.getopt(sys.argv[1:], "f:l:s:a:b:c:m:t:", ["help"])
for op, value in opts:
    if op in ["--help", "--h"]:
        usage()
        exit(1)
    dicts[op] = value

# print dicts
for c in all_case:
    if dicts["-f"] != "-1":
        if c.data_form != dicts["-f"]:
            continue

    if dicts["-l"] != "-1":
        if c.memory_location != dicts["-l"]:
            continue

    if dicts["-s"] != "-1":
        if c.data_size != dicts["-s"]:
            continue

    if dicts["-a"] != "-1":
        if c.access_num_per_thread != dicts["-a"]:
            continue

    if dicts["-b"] != "-1":
        if c.block_size != dicts["-b"]:
            continue

    if dicts["-c"] != "-1":
        if c.data_content != dicts["-c"]:
            continue

    if dicts["-m"] != "-1":
        if c.access_mode != dicts["-m"]:
            continue

    if dicts["-t"] != "-1":
        if hasattr(c, 'step') and c.step != dicts["-t"]:
            continue

    c.printf()



    


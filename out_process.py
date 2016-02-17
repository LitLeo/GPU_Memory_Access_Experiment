import os
import string
import re
# -*- coding: UTF-8 -*-

class Case(object):
    """docstring for Case"""
    def __init__(self, df, ml, ds, anpt, bs, dc, am, rt):
        super(Case, self).__init__()
        self.sdata_form = df
        self.memory_location = ml
        self.data_size = ds
        self.access_num_per_thread = anpt
        self.block_size = bs
        self.data_content = dc
        self.access_mode = am
        self.run_time = rt




# hasattr(emp1, 'age')    
# getattr(emp1, 'age')    
# setattr(emp1, 'age', 8) 

# df_1D Global: size=512 access_num_per_thread=1 block_size=256 data_content=dc_random access_mode=am_sequential runTime=0.001664 ms
all_case = []   

outfilename="out.txt"
file_buffer = open(outfilename)

alllines = file_buffer.readlines()
for line in alllines:
    if len(line)==0:
        continue
    if line.count('\n')==len(line):
        continue
    # else :
    # print re.search('df_.* (.*):.*', line).group(1)
    case = Case(
                re.search('df_(.*) G.*', line).group(1),
                re.search('df_.* (.*):.*', line).group(1),
                re.search('df_.*size=(\d*) .*', line).group(1),
                re.search('df_.*access_num_per_thread=(\d) .*', line).group(1),
                re.search('df_.*block_size=(\d*) .*', line).group(1),
                re.search('df_.*data_content=(.*) a.*', line).group(1),
                re.search('df_.*access_mode=(.*) r.*', line).group(1),
                re.search('df_.*runTime=(.*) m*', line).group(1))
    if line.find('step') != -1:
        setattr(case, step, re.search('.*step=(\d).*', line).group(1))
    print re.search('.*step=(\d).*', line).group(1)
    # exit(1)


file_buffer.close()


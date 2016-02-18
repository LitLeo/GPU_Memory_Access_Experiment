# GPU_Memory_Access_Experiment

##out_process.py 文档##
out_process的设计仿照Linux命令格式，
输入 help 参数，
`
    python out_process.py --help
    
    SYNOPSIS 
    [-f data_form] [-m memory_location] [-s size] [-a access_num_per_thread] [-b block_size] [-c data_content] [-m access_mode] [-t step]
DESCRIPTION 
    -f     1D,2D,tree 
    -l     Global, Shared, Constant 
    -s     global_memory[1024,4096,10240,40960,102400,1024000],shared_memory[512, 1024, 4096, 10240] 
    -a     1, 2, 4 
    -b     256, 512, 1024 
    -c     dc_random, dc_standard_normal, dc_poisson, dc_uniform, dc_geometric, dc_exponential 
    -m     am_sequential, am_step, am_random, am_standard_normal, am_poisson, am_geometric, am_exponential 
    -t     [1,2,4] 
EXAMPLE 
    python out_process.py -f 1D -l Global -s 1024 -a 2 -b 512 -c dc_random -m am_sequential -t 1
`
可以通过设置参数值来得到想要的数据，参数值设为-1表示缺省。
比如想获得数据组织形式为1D，内存位置为Global，数据大小为1024，每个线程访问数据量为2，block大小为512时，数据内容与访问模式对性能的影响，命令如下：
`
	python out_process.py -f 1D -l Global -s 1024 -a 2 -b 512 -c -1 -m -1 -t -1
`
注：
（1）命令中的step选项，只要在access_mode为am_step时才有意义。
（2）可通过修改Case类的printf成员函数来修改输出格式
#include <iostream>
#include "Case.h"
using namespace std;
#ifndef LOOP
#define LOOP 1  // 因为使用了warmup函数，所以就不需要循环多次了
#endif
int main()
{
    // global 测试数据大小
    const int global_size_num = 5; // 数组大小;
    const int global_size[global_size_num] = {512, 1024, 4096, 10240, 40960};

    // constant 和 
    // const int con_size_num = 4;
    // const int con_size[con_size_num] = {512, 1024, 4096, 10240};
    // shared 测试数据大小,这里的大小设置受 DATA_TYPE 的影响。
    const int shared_size_num = 4;
    const int shared_size[shared_size_num] = {512, 1024, 4096, 10240};
    // block size
    const int block_size_num = 3;
    const int block_size[block_size_num] = {256, 512, 1024};
    // 六种数据内部分布，具体见common.h
    const int dc = 6;
    // 七种访问数据类型，具体见common.h
    const int am = 7;
    // 每个线程访问多少数据
    const int am_num_num = 3;
    const int am_num[am_num_num] = {1, 2, 4};
    
    const int step_num = 3;
    const int step[step_num] = {1, 2, 4};

    // 1D Global
    for (int gs = 0; gs < global_size_num; gs++)
        for (int _dc= 0; _dc < dc; _dc++)
            for (int _am = 0; _am < am; _am++) {
                Case c;
                c.df = df_1D;
                c.size = global_size[gs];
                c.dc = (enum data_content)_dc;
                c.am = (enum access_mode)_am;
                // c.initData();

                for (int bs= 0; bs < block_size_num; bs++)
                    for (int an = 0; an < am_num_num; an++) {   
                        c.thread_num = c.size;         // 线程数与数据量大小相同
                        c.block_size = block_size[bs];   
                        c.am_num = am_num[an];

                        cout<<endl<<(c.df)
                        << " Global:"
                        <<" size="<< c.size 
                        <<" access_num_per_thread=" << am_num[an]
                        <<" block_size="<<c.block_size
                        <<" data_content="<< (c.dc)
                        <<" access_mode="<<(c.am);

                        float runTime;

                        // step access mode 
                        if (_am == 1) {
                            for (int s = 0; s < step_num; ++s) {
                                c.step = step[s];

                                if (s != 0) {
                                    cout<<endl<<(c.df)
                                    << " Global:"
                                    <<" size="<< c.size 
                                    <<" access_num_per_thread=" << am_num[an]
                                    <<" block_size="<<c.block_size
                                    <<" data_content="<< (c.dc)
                                    <<" access_mode="<<(c.am);
                                }

                                cout << " step=" << step[s];

                                // warmup();
                                // cudaEvent_t start, stop;
                                // cudaEventCreate(&start);
                                // cudaEventCreate(&stop);
                                // cudaEventRecord(start, 0);
                                // for (int i = 0; i < LOOP; i++) 
                                    // c.global_run();
                                // cudaEventRecord(stop, 0);
                                // cudaEventSynchronize(stop);
                                // cudaEventElapsedTime(&runTime, start, stop);
                                // cout << " runTime=" << (runTime) / LOOP << " ms" << endl;
                            }
                        } else {

                            // warmup();
                            // cudaEvent_t start, stop;
                            // cudaEventCreate(&start);
                            // cudaEventCreate(&stop);
                            // cudaEventRecord(start, 0);
                            // for (int i = 0; i < LOOP; i++) 
                                // c.global_run();
                            // cudaEventRecord(stop, 0);
                            // cudaEventSynchronize(stop);
                            // cudaEventElapsedTime(&runTime, start, stop);
                            // cout << " runTime=" << (runTime) / LOOP << " ms" << endl;
                        }

                    }
            }

    // 1D constant
    // for (int cs = 0; cs < con_size_num; cs++)
        for (int _dc= 0; _dc < dc; _dc++)
            for (int _am = 0; _am < am; _am++) {
                Case c;
                c.df = df_1D;
                c.size = 512;//  这里每一次都需要手动设置
                c.dc = (enum data_content)_dc;
                c.am = (enum access_mode)_am;
                // c.initData();

                for (int bs= 0; bs < block_size_num; bs++)
                    for (int an = 0; an < am_num_num; an++) {   
                        c.thread_num = c.size;         // 线程数与数据量大小相同
                        c.block_size = block_size[bs];   
                        c.am_num = am_num[an];

                        cout<<endl<<(c.df)
                        << " Constant:"
                        <<" size="<< c.size 
                        <<" access_num_per_thread=" << am_num[an]
                        <<" block_size="<<c.block_size
                        <<" data_content="<< (c.dc)
                        <<" access_mode="<<(c.am);

                        float runTime;
                        // warmup();
                        // cudaEvent_t start, stop;
                        // step access mode 
                        if (_am == 1) {
                            for (int s = 0; s < step_num; ++s) {
                                c.step = step[s];

                                if (s != 0) {
                                    cout<<endl<<(c.df)
                                    << " Constant:"
                                    <<" size="<< c.size 
                                    <<" access_num_per_thread=" << am_num[an]
                                    <<" block_size="<<c.block_size
                                    <<" data_content="<< (c.dc)
                                    <<" access_mode="<<(c.am);
                                }

                                cout << " step=" << step[s];
                                
                                // cudaEventCreate(&start);
                                // cudaEventCreate(&stop);
                                // cudaEventRecord(start, 0);
                                // for (int i = 0; i < LOOP; i++) 
                                    // c.constant_run();
                                // cudaEventRecord(stop, 0);
                                // cudaEventSynchronize(stop);
                                // cudaEventElapsedTime(&runTime, start, stop);
                                // cout << " runTime=" << (runTime) / LOOP << " ms" << endl;
                            }
                        } else {
                            // cudaEventCreate(&start);
                            // cudaEventCreate(&stop);
                            // cudaEventRecord(start, 0);
                            // for (int i = 0; i < LOOP; i++) 
                                // c.constant_run();
                            // cudaEventRecord(stop, 0);
                            // cudaEventSynchronize(stop);
                            // cudaEventElapsedTime(&runTime, start, stop);
                            // cout << " runTime=" << (runTime) / LOOP << " ms" << endl;
                        }
                    }
            }
    // 1D shared
    for (int ss = 0; ss < shared_size_num; ss++)
        for (int _dc= 0; _dc < dc; _dc++)
            for (int _am = 0; _am < am; _am++) {
                Case c;
                c.df = df_1D;
                c.size = shared_size[ss];
                c.dc = (enum data_content)_dc;
                c.am = (enum access_mode)_am;
                // c.initData();

                for (int bs= 0; bs < block_size_num; bs++)
                    for (int an = 0; an < am_num_num; an++) {   
                        c.thread_num = c.size;         // 线程数与数据量大小相同
                        c.block_size = block_size[bs];   
                        c.am_num = am_num[an];

                        cout<<endl<<(c.df)
                        << " Shared:"
                        <<" size="<< c.size 
                        <<" access_num_per_thread=" << am_num[an]
                        <<" block_size="<<c.block_size
                        <<" data_content="<< (c.dc)
                        <<" access_mode="<<(c.am);

                        float runTime;
                        // warmup();
                        // cudaEvent_t start, stop;
                        // step access mode 
                        if (_am == 1) {
                            for (int s = 0; s < step_num; ++s) {
                                c.step = step[s];

                                if (s != 0)
                                {
                                    cout<<endl<<(c.df)
                                    << " Shared:"
                                    <<" size="<< c.size 
                                    <<" access_num_per_thread=" << am_num[an]
                                    <<" block_size="<<c.block_size
                                    <<" data_content="<< (c.dc)
                                    <<" access_mode="<<(c.am);
                                }

                                cout << " step=" << step[s];

                                // cudaEventCreate(&start);
                                // cudaEventCreate(&stop);
                                // cudaEventRecord(start, 0);
                                // for (int i = 0; i < LOOP; i++) 
                                    // c.shared_run();
                                // cudaEventRecord(stop, 0);
                                // cudaEventSynchronize(stop);
                                // cudaEventElapsedTime(&runTime, start, stop);
                                // cout << " runTime=" << (runTime) / LOOP << " ms" << endl;
                            }
                        } else {
                            // cudaEventCreate(&start);
                            // cudaEventCreate(&stop);
                            // cudaEventRecord(start, 0);
                            // for (int i = 0; i < LOOP; i++) 
                                // c.shared_run();
                            // cudaEventRecord(stop, 0);
                            // cudaEventSynchronize(stop);
                            // cudaEventElapsedTime(&runTime, start, stop);
                            // cout << " runTime=" << (runTime) / LOOP << " ms" << endl;
                        }
                    }
            }

    const int col_num = 2;
    const int col[col_num] = {256, 512};
    // 二维数组分别在global、constant、shared中进行访存
    // 2D global
    for (int gs = 0; gs < global_size_num; gs++)
        for (int _dc= 0; _dc < dc; _dc++)
            for (int _am = 0; _am < am; _am++)
                for (int cn = 0; cn < col_num; cn++) {
                    Case c;
                    c.df = df_2D;
                    c.size = global_size[gs];
                    c.c = col[cn];  
                    c.r = (c.size + c.c - 1) / c.c;
                    
                    c.dc = (enum data_content)_dc;
                    c.am = (enum access_mode)_am;
                    // c.initData();
                    c.thread_num = c.size;         // 线程数与数据量大小相同
                    for (int an = 0; an < am_num_num; an++)
                        for (int bs= 0; bs < block_size_num; bs++) {
                            c.block_size = block_size[bs];
                            c.am_num = am_num[an];

                            cout<<endl<<(c.df)
                            << " Global:"
                            <<" size="<< c.size 
                            <<" r=" << c.r
                            <<",c=" << c.c
                            <<" access_num_per_thread=" << am_num[an]
                            <<" block_size="<<c.block_size
                            <<" data_content="<< (c.dc)
                            <<" access_mode="<<(c.am);
  
                            float runTime;
                            // warmup();
                            // cudaEvent_t start, stop;
                            // step access mode 
                            if (_am == 1) {
                                for (int s = 0; s < step_num; ++s) {
                                    c.step = step[s];

                                    if (s != 0)
                                    {
                                        cout<<endl<<(c.df)
                                        << " Global:"
                                        <<" size="<< c.size 
                                        <<" r=" << c.r
                                        <<",c=" << c.c
                                        <<" access_num_per_thread=" << am_num[an]
                                        <<" block_size="<<c.block_size
                                        <<" data_content="<< (c.dc)
                                        <<" access_mode="<<(c.am);
                                    }

                                    cout << " step=" << step[s];

                                    // cudaEventCreate(&start);
                                    // cudaEventCreate(&stop);
                                    // cudaEventRecord(start, 0);
                                    // for (int i = 0; i < LOOP; i++) 
                                        // c.global_run();
                                    // cudaEventRecord(stop, 0);
                                    // cudaEventSynchronize(stop);
                                    // cudaEventElapsedTime(&runTime, start, stop);
                                    // cout << " runTime=" << (runTime) / LOOP << " ms" << endl;
                                }
                            } else {
                                // cudaEventCreate(&start);
                                // cudaEventCreate(&stop);
                                // cudaEventRecord(start, 0);
                                // for (int i = 0; i < LOOP; i++) 
                                    // c.global_run();
                                // cudaEventRecord(stop, 0);
                                // cudaEventSynchronize(stop);
                                // cudaEventElapsedTime(&runTime, start, stop);
                                // cout << " runTime=" << (runTime) / LOOP << " ms" << endl;
                            }
                        }
                }
    
    // 2D constant
    // for (int cs = 0; cs < con_size_num; cs++)
        for (int _dc= 0; _dc < dc; _dc++)
            for (int _am = 0; _am < am; _am++)
                for (int cn = 0; cn < col_num; cn++) {
                    Case c;
                    c.df = df_2D;
                    c.size = 512;//con_size[cs];
                    c.c = col[cn];  
                    c.r = (c.size + c.c - 1) / c.c;
                    c.thread_num = c.size;         // 线程数与数据量大小相同
                    c.dc = (enum data_content)_dc;
                    c.am = (enum access_mode)_am;
                    // c.initData();
                    for (int an = 0; an < am_num_num; an++)
                        for (int bs= 0; bs < block_size_num; bs++)
                        {
                            c.am_num = am_num[an];
                            c.block_size = block_size[bs];

                            cout<<endl<<(c.df)
                            << " Constant:"
                            <<" size="<< c.size 
                            <<" access_num_per_thread=" << am_num[an]
                            <<" block_size="<<c.block_size
                            <<" data_content="<< (c.dc)
                            <<" access_mode="<<(c.am);

                            float runTime;
                            // warmup();
                            // cudaEvent_t start, stop;
                            // step access mode 
                            if (_am == 1) {
                                for (int s = 0; s < step_num; ++s) {
                                    c.step = step[s];

                                    if (s != 0)
                                    {
                                        cout<<endl<<(c.df)
                                        << " Constant:"
                                        <<" size="<< c.size 
                                        <<" access_num_per_thread=" << am_num[an]
                                        <<" block_size="<<c.block_size
                                        <<" data_content="<< (c.dc)
                                        <<" access_mode="<<(c.am);
                                    }

                                    cout << " step=" << step[s];

                                    // cudaEventCreate(&start);
                                    // cudaEventCreate(&stop);
                                    // cudaEventRecord(start, 0);
                                    // for (int i = 0; i < LOOP; i++) 
                                        // c.constant_run();
                                    // cudaEventRecord(stop, 0);
                                    // cudaEventSynchronize(stop);
                                    // cudaEventElapsedTime(&runTime, start, stop);
                                    // cout << " runTime=" << (runTime) / LOOP << " ms" << endl;
                                }
                            } else {
                                // cudaEventCreate(&start);
                                // cudaEventCreate(&stop);
                                // cudaEventRecord(start, 0);
                                // for (int i = 0; i < LOOP; i++) 
                                    // c.constant_run();
                                // cudaEventRecord(stop, 0);
                                // cudaEventSynchronize(stop);
                                // cudaEventElapsedTime(&runTime, start, stop);
                                // cout << " runTime=" << (runTime) / LOOP << " ms" << endl;
                            }
                        }
                }
   
    // 2D shared
    for (int ss = 0; ss < shared_size_num; ss++)
        for (int _dc= 0; _dc < dc; _dc++)
            for (int _am = 0; _am < am; _am++)
                for (int cn = 0; cn < col_num; cn++) {
                    Case c;
                    c.df = df_2D;
                    c.size = shared_size[ss];
                    c.c = col[cn];  
                    c.r = (c.size + c.c - 1) / c.c;
                    c.thread_num = c.size;         // 线程数与数据量大小相同
                    c.dc = (enum data_content)_dc;
                    c.am = (enum access_mode)_am;
                    // c.initData();
                    for (int an = 0; an < am_num_num; an++)
                        for (int bs= 1; bs < block_size_num; bs++) {
                            c.block_size = block_size[bs];
                            c.am_num = am_num[an];

                            cout<<endl<<(c.df)
                            << " Shared:"
                            <<" size="<< c.size 
                            <<" access_num_per_thread=" << am_num[an]
                            <<" block_size="<<c.block_size
                            <<" data_content="<< (c.dc)
                            <<" access_mode="<<(c.am);
                            
                            float runTime;
                            // warmup();
                            // cudaEvent_t start, stop;
                            // step access mode 
                            if (_am == 1) {
                                for (int s = 0; s < step_num; ++s) {
                                    c.step = step[s];

                                    if (s != 0)
                                    {
                                        cout<<endl<<(c.df)
                                        << " Shared:"
                                        <<" size="<< c.size 
                                        <<" access_num_per_thread=" << am_num[an]
                                        <<" block_size="<<c.block_size
                                        <<" data_content="<< (c.dc)
                                        <<" access_mode="<<(c.am);
                                    }

                                    cout << " step=" << step[s];

                                    // cudaEventCreate(&start);
                                    // cudaEventCreate(&stop);
                                    // cudaEventRecord(start, 0);
                                    // for (int i = 0; i < LOOP; i++) 
                                        // c.shared_run();
                                    // cudaEventRecord(stop, 0);
                                    // cudaEventSynchronize(stop);
                                    // cudaEventElapsedTime(&runTime, start, stop);
                                    // cout << " runTime=" << (runTime) / LOOP << " ms" << endl;
                                }
                            } else {
                                // cudaEventCreate(&start);
                                // cudaEventCreate(&stop);
                                // cudaEventRecord(start, 0);
                                // for (int i = 0; i < LOOP; i++) 
                                    // c.shared_run();
                                // cudaEventRecord(stop, 0);
                                // cudaEventSynchronize(stop);
                                // cudaEventElapsedTime(&runTime, start, stop);
                                // cout << " runTime=" << (runTime) / LOOP << " ms" << endl;
                            }
                        }
                }
    
    // Tree Global
    for (int gs = 0; gs < global_size_num; gs++)
        for (int _dc= 0; _dc < dc; _dc++)
            for (int _am = 0; _am < am; _am++) {
                Case c;
                c.df = df_tree;
                c.size = global_size[gs];
                c.thread_num = c.size;         // 线程数与数据量大小相同
                c.dc = (enum data_content)_dc;
                c.am = (enum access_mode)_am;
                // c.initData();
                for (int an = 0; an < am_num_num; an++) 
                    for (int bs= 0; bs < block_size_num; bs++){
                        c.am_num = am_num[an];
                        c.block_size = block_size[bs];

                        cout<<endl<<(c.df)
                        << " Global:"
                        <<" size="<< c.size 
                        <<" access_num_per_thread=" << am_num[an]
                        <<" block_size="<<c.block_size
                        <<" data_content="<< (c.dc)
                        <<" access_mode="<<(c.am);

                        float runTime;

                        // step access mode 
                        if (_am == 1) {
                            for (int s = 0; s < step_num; ++s) {
                                c.step = step[s];

                                if (s != 0)
                                {
                                    cout<<endl<<(c.df)
                                    << " Global:"
                                    <<" size="<< c.size 
                                    <<" access_num_per_thread=" << am_num[an]
                                    <<" block_size="<<c.block_size
                                    <<" data_content="<< (c.dc)
                                    <<" access_mode="<<(c.am);
                                }

                                cout << " step=" << step[s];

                                // warmup();
                                // cudaEvent_t start, stop;
                                // cudaEventCreate(&start);
                                // cudaEventCreate(&stop);
                                // cudaEventRecord(start, 0);
                                // for (int i = 0; i < LOOP; i++) 
                                    // c.global_run();
                                // cudaEventRecord(stop, 0);
                                // cudaEventSynchronize(stop);
                                // cudaEventElapsedTime(&runTime, start, stop);
                                // cout << " runTime=" << (runTime) / LOOP << " ms" << endl;
                            }
                        } else {

                            // warmup();
                            // cudaEvent_t start, stop;
                            // cudaEventCreate(&start);
                            // cudaEventCreate(&stop);
                            // cudaEventRecord(start, 0);
                            // for (int i = 0; i < LOOP; i++) 
                                // c.global_run();
                            // cudaEventRecord(stop, 0);
                            // cudaEventSynchronize(stop);
                            // cudaEventElapsedTime(&runTime, start, stop);
                            // cout << " runTime=" << (runTime) / LOOP << " ms" << endl;
                        }
                    }
            }
    // Tree constant
    // for (int cs = 0; cs < con_size_num; cs++)
        for (int _dc= 0; _dc < dc; _dc++)
            for (int _am = 0; _am < am; _am++) {
                Case c;
                c.df = df_tree;
                c.size = 512;//  这里每一次都需要手动设置
                c.thread_num = c.size; // 线程数与数据量大小相同
                
                c.dc = (enum data_content)_dc;
                c.am = (enum access_mode)_am;
                // c.initData();
                for (int an = 0; an < am_num_num; an++)
                    for (int bs= 0; bs < block_size_num; bs++) {
                        c.am_num = am_num[an];
                        c.block_size = block_size[bs];

                        cout<<endl<<(c.df)
                        << " Constant:"
                        <<" size="<< c.size 
                        <<" access_num_per_thread=" << am_num[an]
                        <<" block_size="<<c.block_size
                        <<" data_content="<< (c.dc)
                        <<" access_mode="<<(c.am);

                        float runTime;
                        // warmup();
                        // cudaEvent_t start, stop;
                        // step access mode 
                        if (_am == 1) {
                            for (int s = 0; s < step_num; ++s) {
                                c.step = step[s];

                                if (s != 0)
                                {
                                    cout<<endl<<(c.df)
                                    << " Constant:"
                                    <<" size="<< c.size 
                                    <<" access_num_per_thread=" << am_num[an]
                                    <<" block_size="<<c.block_size
                                    <<" data_content="<< (c.dc)
                                    <<" access_mode="<<(c.am);
                                }

                                cout << " step=" << step[s];
                                
                                // cudaEventCreate(&start);
                                // cudaEventCreate(&stop);
                                // cudaEventRecord(start, 0);
                                // for (int i = 0; i < LOOP; i++) 
                                    // c.constant_run();
                                // cudaEventRecord(stop, 0);
                                // cudaEventSynchronize(stop);
                                // cudaEventElapsedTime(&runTime, start, stop);
                                // cout << " runTime=" << (runTime) / LOOP << " ms" << endl;
                            }
                        } else {
                            // cudaEventCreate(&start);
                            // cudaEventCreate(&stop);
                            // cudaEventRecord(start, 0);
                            // for (int i = 0; i < LOOP; i++) 
                                // c.constant_run();
                            // cudaEventRecord(stop, 0);
                            // cudaEventSynchronize(stop);
                            // cudaEventElapsedTime(&runTime, start, stop);
                            // cout << " runTime=" << (runTime) / LOOP << " ms" << endl;
                        }
                    }
            }
    
    // Tree shared
    // 在这里要重新设计大小，因为sizeof(tree) = 4+4+sizof(DATA_TYPE)，
    // 同时还要考虑结构体对齐问题
    // DATA_TYPE = unsigned char时, sizeof(tree) = 12B，
    const int tree_shared_size_num = 4;
    const int tree_shared_size[tree_shared_size_num] = {256, 512, 1024, 2048};

    for (int tss = 0; tss < tree_shared_size_num; tss++)
        for (int _dc= 0; _dc < dc; _dc++)
            for (int _am = 0; _am < am; _am++) {
                Case c;
                c.df = df_tree;
                c.size = tree_shared_size[tss];
                c.thread_num = c.size;         // 线程数与数据量大小相同
                c.dc = (enum data_content)_dc;
                c.am = (enum access_mode)_am;
                // c.initData();
                for (int an = 0; an < am_num_num; an++) 
                    for (int bs= 0; bs < block_size_num; bs++){
                        c.am_num = am_num[an];
                        c.block_size = block_size[bs];

                        cout<<endl<<(c.df)
                        << " Shared:"
                        <<" size="<< c.size 
                        <<" access_num_per_thread=" << am_num[an]
                        <<" block_size="<<c.block_size
                        <<" data_content="<< (c.dc)
                        <<" access_mode="<<(c.am);

                        float runTime;
                        // warmup();
                        // cudaEvent_t start, stop;
                        // step access mode 
                        if (_am == 1) {
                            for (int s = 0; s < step_num; ++s) {
                                c.step = step[s];

                                if (s != 0)
                                {
                                    cout<<endl<<(c.df)
                                    << " Shared:"
                                    <<" size="<< c.size 
                                    <<" access_num_per_thread=" << am_num[an]
                                    <<" block_size="<<c.block_size
                                    <<" data_content="<< (c.dc)
                                    <<" access_mode="<<(c.am);
                                }

                                cout << " step=" << step[s];

                                // cudaEventCreate(&start);
                                // cudaEventCreate(&stop);
                                // cudaEventRecord(start, 0);
                                // for (int i = 0; i < LOOP; i++) 
                                    // c.shared_run();
                                // cudaEventRecord(stop, 0);
                                // cudaEventSynchronize(stop);
                                // cudaEventElapsedTime(&runTime, start, stop);
                                // cout << " runTime=" << (runTime) / LOOP << " ms" << endl;
                            }
                        } else {
                            // cudaEventCreate(&start);
                            // cudaEventCreate(&stop);
                            // cudaEventRecord(start, 0);
                            // for (int i = 0; i < LOOP; i++) 
                                // c.shared_run();
                            // cudaEventRecord(stop, 0);
                            // cudaEventSynchronize(stop);
                            // cudaEventElapsedTime(&runTime, start, stop);
                            // cout << " runTime=" << (runTime) / LOOP << " ms" << endl;
                        }
                    }
            }


    return 0;
}



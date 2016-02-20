#include <iostream>
/*#include "Case.h"*/
#include "GenerateParams.h"
#include <stdlib.h>
#include <string>
using namespace std;

int main(int argc, char const *argv[])
{
    // for (int i = 0; i < argc; ++i)
    // {
    //     cout << argv[i] << " ";
    // }
    // cout << endl;
    // return 0;
    /*generate_params();*/
    /*return 0;*/

    Case c;
    unsigned int index = 1;
    c.df = (enum data_form)atoi(argv[index ++]);
    index ++;
    c.size = atoi(argv[index ++]);
    if (c.df == df_2D) {
        c.c = atoi(argv[index ++]);  
        c.r = atoi(argv[index ++]); 
    }
    c.am_num = atoi(argv[index ++]);
    c.block_size = atoi(argv[index ++]);
    c.dc = (enum data_content)atoi(argv[index ++]);
    c.am = (enum access_mode)atoi(argv[index ++]);
    c.thread_num = c.size;         // 线程数与数据量大小相同
      
    if (c.am == am_step)
        c.step = atoi(argv[index ++]);
    
    /*c.print();*/

    warmup();
    c.initData();
    float runTime = 0.0f;
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);

    if (string(argv[2]) == "Global:") {
         c.global_run();
        /*cout << "c.global_run();" << endl;*/
    } else if (string(argv[2]) == "Shared:") {
         c.shared_run();
        /*cout << "c.shared_run();" << endl;*/
    } else if (string(argv[2]) == "Constant:"){
         c.constant_run();
        /*cout << "c.constant_run();" << endl;*/
    }

    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&runTime, start, stop);

    cout<<endl<<EnumToString(c.df) << " " 
        << argv[2] 
        <<" size="<< c.size;
        if (c.df == df_2D)
            cout<<" r=" << c.r
            <<",c=" << c.c;
        cout<<" access_num_per_thread=" << c.am_num
        <<" block_size="<<c.block_size
        <<" data_content="<< EnumToString(c.dc)
        <<" access_mode="<<EnumToString(c.am);
        if (c.am == am_step)
            cout << " step=" << c.step;
    cout << " runTime=" << (runTime)  << " ms" << endl;
    

    return 0;
}

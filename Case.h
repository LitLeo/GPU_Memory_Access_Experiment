#ifndef CASE_H_
#define CASE_H_

#include "Distribution.h"


// 核心组织类
// 在该类中，定义了不同的数据结构形式，不同的访问方式，不同的内存以及不同的线程数目
// void global_run();
// void shared_run();
// void constant_run();
// 为核心函数，以得出在不同内存下的访存性能
class Case
{
public:
    // 初始化默认参数
    Case()
    {
        this->df = df_1D; // 默认为一维数组
        this->size = 512;// 数据大小默认512
        this->r = -1;
        this->c = -1;

        this->dc = dc_random; // 数据内部默认随机分布
        this->thread_num = this->size; // 默认线程数与数据大小相同
        this->block_size = 256; // 默认线程块大小为 256

        this->am = am_sequential; // 默认访问方式为顺序访问
        this->am_num = 1;    // 默认访问一个数据.
        this->step = -1;

        this->data1D = NULL;
        this->tree = NULL;
        this->data2D.data = NULL;
        this->host_am_data = NULL;
    }

    void print()
    {
        cout<<endl<<EnumToString(this->df)
        << " Global:"
        <<" size="<< this->size;
        if (this->df == df_2D)
            cout<<" r=" << this->r
            <<",c=" << this->c;
        cout<<" access_num_per_thread=" << this->am_num
        <<" block_size="<<this->block_size
        <<" data_content="<< EnumToString(this->dc)
        <<" access_mode="<<EnumToString(this->am);
        if (this->am == am_step)
            cout << " step=" << this->step;
    }

    ~Case()
    {
        //if (this->data1D != NULL)
            //free(this->data1D);
        //if (this->data2D.data != NULL)
            //free(this->data2D.data);
        //if (this->tree != NULL)
            //free(this->tree);
        // if (this->host_am_data != NULL)
            // free(this->host_am_data);

    }
    // 数据组织形式
    // 一维数组，树等
    data_form df; 
    // 数据大小
    int size;
    int r,c;  // 二维数组所需数据
    // 数据内容形式
    // 随机、各种分布
    data_content dc;
    // 根据数据组织形式、数据大小和数据内容形式初始化数据
    int initData();

    // 线程数目
    int thread_num;
    int block_size;   // 线程块大小
    // 不同的访问方式
    access_mode am;
    int step;
    int am_num;       // 访问数据的数量

    // 三个运行函数，即核心函数
    // 分别得出在不同内存下的访问性能
    // 每个函数内执行流程如下：
    // (1)（申请空间，初始化数据需提前完成）
    // (2)数据拷贝，执行核函数
    // (3)释放数据
    int global_run();
    int shared_run();
    int constant_run();
private:
    // 数据组织形式
    DATA_TYPE *data1D;
    Data2D data2D;
    Tree *tree;

    int *host_am_data;
};

#endif

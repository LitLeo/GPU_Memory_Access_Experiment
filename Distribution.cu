#include "Distribution.h"

#include <stdlib.h>
#include <time.h>

// 代码实现参考
// http://blog.csdn.net/zhengnanlee/article/details/12619483
// http://m.blog.csdn.net/blog/asiaLIYAZHOU/45509047
// http://www.cnblogs.com/yeahgis/archive/2012/07/15/2592696.html

// 随机函数，私有函数，供该文件内其他函数调用
double  _random(double min, double max)
{
    int nbRand = rand() % 10001;
    return (min + nbRand*(max - min) / 10000);
}

// 随机分布函数
int random(int min, int max, int size, DATA_TYPE* data)
{
    if (data == NULL)
        return -1;
    srand((unsigned)time(NULL));
    for (int i = 0; i < size; i++)
        data[i] = _random(min, max);
    return 0;
}
// 随机分布函数，用于生成访问下标
int random(int min, int max, int* data)
{
    if (data == NULL)
        return -1;
    srand((unsigned)time(NULL));
    for (int i = 0; i < max; i++)
        data[i] = _random(min, max);
    return 0;
}
/*为树节点初始化数据*/
int random(int min, int max, int size, Node *nodes)
{
    if (nodes == NULL)
        return -1;
    srand((unsigned)time(NULL));
    for (int i = 0; i < size; i++)
        nodes[i].data = _random(min, max);
    return 0;
}

// 标准正态分布函数
double Normal(double x, double miu, double sigma)
{
    return 1.0 / sqrt(2 * PI*sigma) * exp(-1 * (x - miu)*(x - miu) / (2 * sigma*sigma));
}
double NormalRandom(double miu, double sigma, double min, double max)
{
    double x;
    double dScope;
    double y;
    do
    {
        x = _random(min, max);
        y = Normal(x, miu, sigma);
        dScope = _random(0, Normal(miu, miu, sigma));
    } while (dScope > y);
    return x;
}
int standard_normal(int min, int max, int miu, int sigma, int size, DATA_TYPE* data)
{
    if (data == NULL || max <= min)
        return -1;
    srand((unsigned)time(NULL));
    for (int i = 0; i < size; i++)
    {
        data[i] = NormalRandom(miu, sigma, min, max);
    }
    return 0;
}
// 标准正态分布函数，用于生成访问下标
int standard_normal(int min, int max, int miu, int sigma, int* data)
{
    if (data == NULL || max <= min)
        return -1;
    srand((unsigned)time(NULL));
    for (int i = 0; i < max; i++)
    {
        data[i] = NormalRandom(miu, sigma, min, max);
    }
    return 0;
}
/*为树节点初始化数据*/
int standard_normal(int min, int max, int miu, int sigma, int size, Node *nodes)
{
    if (nodes == NULL || max <= min)
        return -1;
    srand((unsigned)time(NULL));
    for (int i = 0; i < size; i++)
    {
        nodes[i].data = NormalRandom(miu, sigma, min, max);
    }
    return 0;
}

// 泊松分布
int _possion(int Lambda)
{
    int  k = 0;
    long double p = 1.0;
    long double l = exp(-Lambda);
    while(p>=l)
    {
        double u = (float)(rand() %100) / 100;
        p *= u;
        k++;
    }
    return k-1;
}
int poisson(int min, int max, int Lambda, int size, DATA_TYPE* data)
{
    if (data == NULL || max <= min)
        return -1;
    srand((unsigned)time(NULL));

    for (int i = 0; i < size; i++)
    {
        data[i] = _possion(Lambda) % (max - min);
    }
    return 0;
}
// 泊松分布函数，用于生成访问下标
int poisson(int min, int max, int Lambda, int* data)
{
    if (data == NULL || max <= min)
        return -1;
    srand((unsigned)time(NULL));

    for (int i = 0; i < max; i++)
    {
        data[i] = _possion(Lambda) % (max - min);
    }
    return 0;
}
/*为树节点初始化数据*/
int poisson(int min, int max, int Lambda, int size, Node *nodes)
{
    if (nodes == NULL || max <= min)
        return -1;
    srand((unsigned)time(NULL));

    for (int i = 0; i < size; i++)
    {
        nodes[i].data = _possion(Lambda) % (max - min);
    }
    return 0;
}

// 均匀分布
int uniform(int min, int max, int size, DATA_TYPE* data)
{
    if (data == NULL || max <= min)
        return -1;

    for (int i = 0; i < size; i++)
        data[i] = (min + i) % (max - min);
    return 0;
}
// 均匀分布函数，用于生成访问下标
int uniform(int min, int max, int* data)
{
    if (data == NULL || max <= min)
        return -1;

    for (int i = 0; i < max; i++)
        data[i] = (min + i) % (max - min);
    return 0;
}
/*为树节点初始化数据*/
int uniform(int min, int max, int size, Node *nodes)
{
    if (nodes == NULL || max <= min)
        return -1;

    for (int i = 0; i < size; i++)
        nodes[i].data = (min + i) % (max - min);
    return 0;
}

// 几何分布
long randomGeometric(double  probability)
{
    long rnd = 0;
    while(true)
    {
        rnd++;
        double pV = (double)rand()/(double)RAND_MAX;
        if (pV<probability)
        {
            break;
        }
    }
    return rnd;
}
int geometric(double probability, int min, int max, int size, DATA_TYPE* data)
{
    if (data == NULL || max <= min)
        return -1;
     srand((unsigned)time(NULL));
     for (int i = 0; i < size; i++)
     {
         data[i] = randomGeometric(probability) % (max - min);
     }
     return 0;
}
// 几何分布函数，用于生成访问下标
int geometric(double probability, int min, int max, int* data)
{
    if (data == NULL || max <= min)
        return -1;
     srand((unsigned)time(NULL));
     for (int i = 0; i < max; i++)
     {
         data[i] = randomGeometric(probability) % (max - min);
     }
     return 0;
}
/*为树节点初始化数据*/
int geometric(double probability, int min, int max, int size, Node *nodes)
{
    if (nodes == NULL || max <= min)
        return -1;
     srand((unsigned)time(NULL));
     for (int i = 0; i < size; i++)
     {
         nodes[i].data = randomGeometric(probability) % (max - min);
     }
     return 0;
}

// 指数分布
double randomExponential(double lambda)
{
    double pv = 0.0;
    pv = (double)(rand()%100)/100;
    while(pv == 0)
    {
        pv = (double)(rand() % 100)/100;
    }
    pv = (-1  / lambda)*log(1-pv);
    return pv;
}
int exponential(double lambda, int min, int max, int size, DATA_TYPE* data)
{
    if (data == NULL || max <= min)
       return -1;
    srand((unsigned)time(NULL));

    for (int i = 0; i < size; i++)
        data[i] = (int)randomExponential(lambda) % (max - min);
    return 0;
}
// 指数分布函数，用于生成访问下标
int exponential(double lambda, int min, int max, int* data)
{
    if (data == NULL || max <= min)
       return -1;
    srand((unsigned)time(NULL));

    for (int i = 0; i < max; i++)
        data[i] = (int)randomExponential(lambda) % (max - min);
    return 0;
}
/*为树节点初始化数据*/
int exponential(double lambda, int min, int max, int size, Node *nodes)
{
    if (nodes == NULL || max <= min)
        return -1;
    srand((unsigned)time(NULL));

    for (int i = 0; i < size; i++)
        nodes[i].data = (int)randomExponential(lambda) % (max - min);
    return 0;
}

// device 端函数，用于在核函数中根据不同的访问方式产生访问下标
// __device__ __host__ int dev_sequential(int index)
// {
//     return index;
// }
// __device__ __host__ int dev_step(int index, int step)
// {
//     return index * step;
// }
// __device__ __host__ int dev_random()
// {

// }
// __device__ __host__ int dev_standard_normal(int index)
// {

// }
// __device__ __host__ int dev_poisson(int index)
// {

// }
// __device__ __host__ int dev_geometric(int index)
// {

// }
// __device__ __host__ int dev_exponential(int index)
// {

// }

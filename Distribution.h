#ifndef DIS_H_
#define DIS_H_

#include "Common.h"

#include <iostream>
#include <cmath>
using namespace std;



// 根据分布类型和所给出的下标生成生成各种分布数据
// 共有6种分布，随机分布、正态分布、泊松分布、均匀分布、几何分布和指数分布
/*为一维和二维随机分配数据*/
int random(int min, int max, int size, DATA_TYPE* data); 
/*随机生成访问下标*/ 
int random(int min, int max, int* data);
/*为树节点随机分配数据*/
int random(int min, int max, int size, Node *nodes);

int standard_normal(int min, int max, int miu, int sigma, int size, DATA_TYPE* data);
int standard_normal(int min, int max, int miu, int sigma, int* data);
int standard_normal(int min, int max, int miu, int sigma, int size, Node *nodes);
int poisson(int min, int max, int Lambda, int size, DATA_TYPE* data);
int poisson(int min, int max, int Lambda, int* data);
int poisson(int min, int max, int Lambda, int size, Node *nodes);
int uniform(int min, int max, int size, DATA_TYPE* data);
int uniform(int min, int max, int* data);
int uniform(int min, int max, int size, Node *nodes);
int geometric(double probability, int min, int max, int size, DATA_TYPE* data);
int geometric(double probability, int min, int max, int* data);
int geometric(double probability, int min, int max, int size, Node *nodes);
int exponential(double lambda, int min, int max, int size, DATA_TYPE* data);
int exponential(double lambda, int min, int max, int* data);
int exponential(double lambda, int min, int max, int size, Node *nodes);


#endif
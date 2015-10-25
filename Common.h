#ifndef COMMON_H_
#define COMMON_H_ 

#include <iostream>
#include <string>
using namespace std;

// 测试数据的类型
#define DATA_TYPE unsigned char

// !!注意，这里的最大最小值跟 DATA_TYPE 的类型有关
// 值域为 [MIN, MAX)
#define MIN 0
#define MAX 256

#ifndef PI
#define PI 3.141592654
#endif

#ifndef e
#define e 2.718281828459
#endif

// 数据内部分布
enum data_content
{
    dc_random = 0,       // 随机分布
    dc_standard_normal,  // 标准正态分布
    dc_poisson,          // 泊松分布
    dc_uniform,          // 均匀分布
    dc_geometric,        // 几何分布
    dc_exponential       // 指数分布
};
// 访问方式
enum access_mode
{
    am_sequential=0,          // 顺序访问
    am_step,              // step 访问
    am_random,            // 随机访问
    am_standard_normal,  // 标准正态分布访问
    am_poisson,       // 泊松分布访问
    am_geometric,         // 几何分布访问
    am_exponential        // 指数分布访问
};

// 数据组织形式
enum data_form
{
    df_1D = 0,
    df_2D,
    df_tree
};

// 枚举类型转换为string
string EnumToString(enum data_form df);
string EnumToString(enum access_mode am);
string EnumToString(enum data_content dc);

/* 树节点 */ 
class Node
{
public:
    Node* left;
    Node* right;
    DATA_TYPE data;

    //Node()
    //{
        //left = NULL;
        //right = NULL;
    //}
};


// 一维模拟二维
typedef struct data2D_st
{
    size_t rows;            
    size_t cols;                       
    DATA_TYPE *data;  
    size_t pitchBytes;

}Data2D;

class Tree
{
public:
    // 申请空间并设置父节点和子节点的关系
    Tree(int _num)
    {
        // 0
        // 1 2
        // 3 4 5 6 
        this->num = _num;
        this->nodes = new Node[this->num];
        for (int i = 0; i < this->num; i++) {
            if (2 * i + 1 < this->num) {
                this->nodes[i].left = &this->nodes[2 * i + 1];
            }
            if (2 * i + 2 < this->num) {
                this->nodes[i].right = &this->nodes[2 * i + 2];
            }
        }
    }
    // 无参构造函数，用于申请device端内存时使用
    Tree() 
    {
        this->nodes = NULL;
    }
    ~Tree()
    {
        if (this->nodes != NULL)
            free(this->nodes);
    }

    Node *nodes;
    int num;  // 节点数量 
};

void print(DATA_TYPE* data_1D, int size);


#endif

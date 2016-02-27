#include "Case.h"

// 设置二维默认线程数
#define DEF_BLOCK_X  32
#define DEF_BLOCK_Y   8

// 全局内容的大小必须提前设置，对于不同数据大小的测试只能一次次手动改了
__constant__ DATA_TYPE constant_data1D[1];
/*__constant__ DATA_TYPE constant_data1D[CONSTANT_SIZE];*/
__constant__ DATA_TYPE constant_data2D[1][1];
/*__constant__ DATA_TYPE constant_data2D[CONSTANT_SIZE/CONSTANT_2D_ROW][CONSTANT_2D_ROW];*/
// 每个 node 的大小为 12 B，所以在设置大小时一定要注意不能超过 constant memory 的大小
/*__constant__ Node constant_treeNodes[1];*/
__constant__ Node constant_treeNodes[CONSTANT_SIZE];

// 根据数据组织形式、数据大小和数据内容形式初始化数据
int Case::initData()
{
    // 数据组织形式
    switch (this->df)
    {
    case df_1D:
        this->data1D = new DATA_TYPE[this->size];
        // 数据内容形式初始化数据
        switch (this->dc)
        {
        case dc_exponential:
            // 设置 lambda = 10
            if (exponential(10 ,MIN, MAX, this->size, this->data1D))
                return -1;
            break;
        case dc_geometric:
            // 设置 p = 0.5
            if (geometric(0.5 ,MIN, MAX, this->size, this->data1D))
                return -1;
            break;
        case dc_poisson:
            // 设置 Lambda = 05
            if (poisson(MIN, MAX, 5, this->size, this->data1D))
                return -1;
            break;
        case dc_random:
            if (random(MIN, MAX, this->size, this->data1D))
                return -1;
            break;
        case dc_standard_normal:
            if (standard_normal(MIN, MAX, MAX - MIN, 1,  this->size, this->data1D))
                return -1;
            break;
        case dc_uniform:
            if (uniform(MIN, MAX, this->size, this->data1D))
                return -1;
            break;
        }
        break;
    case df_2D:
    {
        if (this->r * this->c != this->size)
            this->size = this->r * this->c;
        this->data2D.data = new DATA_TYPE[this->size];
        this->data2D.rows = this->r;
        this->data2D.cols = this->c;
        // 数据内容形式初始化数据
        switch (this->dc)
        {
        case dc_exponential:
            if (exponential(10 ,MIN, MAX, this->size, this->data2D.data))
                return -1;
            break;
        case dc_geometric:
            // 设置 p = 0.5
            if (geometric(0.5 ,MIN, MAX, this->size, this->data2D.data))
                return -1;
            break;
        case dc_poisson:
            // 设置 Lambda = 05
            if (poisson(MIN, MAX, 5, this->size, this->data2D.data))
                return -1;
            break;
        case dc_random:
            if (random(MIN, MAX, this->size, this->data2D.data))
                return -1;
            break;
        case dc_standard_normal:
            if (standard_normal(MIN, MAX, MAX - MIN, 1,  this->size, this->data2D.data))
                return -1;
            break;
        case dc_uniform:
            if (uniform(MIN, MAX, this->size, this->data2D.data))
                return -1;
            break;
        }

        break;
    }
    case df_tree:
        this->tree= new Tree(size);

        switch (this->dc)
        {
        case dc_exponential:
            if (exponential(10 ,MIN, MAX, this->size, this->tree->nodes))
                return -1;
            break;
        case dc_geometric:
            // 设置 p = 0.5
            if (geometric(0.5 ,MIN, MAX, this->size, this->tree->nodes))
                return -1;
            break;
        case dc_poisson:
            // 设置 Lambda = 05
            if (poisson(MIN, MAX, 5, this->size, this->tree->nodes))
                return -1;
            break;
        case dc_random:
            if (random(MIN, MAX, this->size, this->tree->nodes))
                return -1;
            break;
        case dc_standard_normal:
            if (standard_normal(MIN, MAX, MAX - MIN, 1,  this->size, this->tree->nodes))
                return -1;
            break;
        case dc_uniform:
            if (uniform(MIN, MAX, this->size, this->tree->nodes))
                return -1;
            break;
        }

        break;
    }
    // 当访问方式为分布访问时（即不是顺序访问和step访问）
    // 需要生成访问下标数据
    if (this->am != am_sequential && this->am != am_step) {
        this->host_am_data = new int[this->size];
        switch(this->am)
        {
            case am_random:
            if (random(0, this->size, host_am_data))
                return -1;
            break;
            case am_standard_normal:
            if (standard_normal(0, this->size, this->size, 1,  host_am_data))
                return -1;
            break;
            case am_poisson:
            if (poisson(0, this->size, 5, host_am_data))
                return -1;
            break;

            case am_geometric:
            if (geometric(0.5, 0, this->size, host_am_data))
                return -1;
           
            break;
            case am_exponential:
            if (exponential(10 ,0, this->size, host_am_data))
                return -1;
            break;
        }
    }

    return 0;
}

// 全局内存
// data1D,dev_out,am_data的size与线程数相同
/*顺序访问数据*/
static __global__ void _d1DGloalSequentialKer(DATA_TYPE *data1D, DATA_TYPE* dev_out, int am_num, int size)
{
    // 获得线程索引
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index >= size)
        return ;
    for (int i = 0; i < am_num; ++i)
        dev_out[index] += data1D[(index + i) % size]; 

}
/*step方式访问数据*/
static __global__ void _d1DGloalStepKer(DATA_TYPE *data1D, DATA_TYPE* dev_out, int step, int am_num, int size)
{
    // 获得线程索引
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index >= size)
        return ;
    for (int i = 0; i < am_num; ++i)
        dev_out[index] += data1D[(index + i * step) % size]; 
}
/*根据不同的分布进行访问，标准正态分布、泊松分布、指数分布、几何分布
因为生成 am_data 需要使用随机数，所以 am_data 需要在核函数外生成, am_data内数据值域为[0, size)*/ 
static __global__ void _d1DGloalCommonKer(DATA_TYPE *data1D, DATA_TYPE* dev_out, int am_num, 
                                          int* am_data, int size)
{
    // 获得线程索引
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index >= size)
        return ;
    for (int i = 0; i < am_num; ++i)
        dev_out[i] += data1D[am_data[(index + i) % size]];
}

// 共享内存
// 将数据全部拷贝到共享内存中
// 数据量与线程的关系
static __global__ void _d1DSharedSequentialKer(DATA_TYPE *data1D, DATA_TYPE* dev_out, int am_num, 
                                               int size, int copy_num_per_thread)
{
    // 获得线程索引
    int index = blockIdx.x * blockDim.x + threadIdx.x;

    if (index >= size)
        return ;

    // 将数据拷贝到共享内存中, shared memory size = data size，
    // 大小需要在核函数外设置
    extern __shared__ DATA_TYPE sharedData[];
    // 一个线程拷贝 (data_size + T - 1) / T 个数据
    for (int i = 0; i < copy_num_per_thread; ++i) {
        // 计算要拷贝数据的下标
        int copt_index = index * copy_num_per_thread + i;
        if (copt_index < size)
            sharedData[copt_index] = data1D[copt_index];
    }
    __syncthreads();

    for (int i = 0; i < am_num; ++i)
        dev_out[index] += sharedData[(index + i) % size]; 
}
static __global__ void _d1DSharedStepKer(DATA_TYPE *data1D, DATA_TYPE* dev_out, int step, int am_num,
                                         int size, int copy_num_per_thread)
{
    // 获得线程索引
    int index = blockIdx.x * blockDim.x + threadIdx.x;

    if (index >= size)
        return ;

    // 将数据拷贝到共享内存中
    extern __shared__ DATA_TYPE sharedData[];
    // 一个线程拷贝 (data_size + T - 1) / T 个数据
    for (int i = 0; i < copy_num_per_thread; ++i) {
        // 计算要拷贝数据的下标
        int copt_index = index * copy_num_per_thread + i;
        if (copt_index < size)
            sharedData[copt_index] = data1D[copt_index];
    }
    __syncthreads();

    for (int i = 0; i < am_num; ++i)
        dev_out[index] += sharedData[(index + i * step) % size]; 
}
static __global__ void _d1DSharedCommonKer(DATA_TYPE *data1D, DATA_TYPE* dev_out, int am_num, int size, int* am_data,
                                           int copy_num_per_thread)
{
    // 获得线程索引
    int index = blockIdx.x * blockDim.x + threadIdx.x;

    if (index >= size)
        return ;

    // 将数据拷贝到共享内存中
    extern __shared__ DATA_TYPE sharedData[];
    // 一个线程拷贝 (data_size + T - 1) / T 个数据
    for (int i = 0; i < copy_num_per_thread; ++i) {
        // 计算要拷贝数据的下标
        int copt_index = index * copy_num_per_thread + i;
        if (copt_index < size)
            sharedData[copt_index] = data1D[copt_index];
    }
    __syncthreads();

    for (int i = 0; i < am_num; ++i)
        dev_out[index] += sharedData[am_data[(index + i)%size] % size];
}

// 常量内存
// constant_data1D
static __global__ void _d1DConstantSequentialKer(DATA_TYPE* dev_out, int am_num, int size)
{
    // 获得线程索引
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index >= size)
        return ;
    for (int i = 0; i < am_num; ++i)
        dev_out[index] += constant_data1D[(index + i) % size]; 
}
static __global__ void _d1DConstantStepKer(DATA_TYPE* dev_out, int step, int am_num, int size)
{
    // 获得线程索引
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index >= size)
        return ;
    for (int i = 0; i < am_num; ++i)
        dev_out[index] += constant_data1D[(index + i * step) % size]; 
}
static __global__ void _d1DConstantCommonKer(DATA_TYPE* dev_out, int am_num, int* am_data, int size)
{
    // 获得线程索引
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index >= size)
        return ;
    for (int i = 0; i < am_num; ++i)
        dev_out[index] += constant_data1D[am_data[(index + i)%size]];
}

// ！！！！需要考虑越界问题
// 一维与二维的区别，在根据下标访问时，需要考虑 pitchByte 问题
// 访问二维数组的方式：输入是相对应的一维下标 index，将 index 由二维矩阵的 width 转变为 row, col，
// 根据偏移量 offset 更新 col, row（此时要考虑col + offset >= width 问题），从而得到数据的索引为
// index = row * pitchBytes + col.
// 输出数据的大小 == thread num == data2D.cols * data2D.rows
static __global__ void _d2DGloalSequentialKer(Data2D data2D, DATA_TYPE* dev_out, int am_num)
{
    // 获得线程索引
    unsigned int c = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned int r = blockIdx.y * blockDim.y + threadIdx.y;
    if (c >= data2D.cols || r >= data2D.rows)
        return ;
    // 计算输出数据的下标
    unsigned int index = r * data2D.cols + c;
    for (int i = 0; i < am_num; ++i) {
        int temp_c = c + i;
        // 进行越界判断，并重新计算下标
        if (temp_c >= data2D.cols) {
            r += (temp_c) / data2D.cols; 
            c = (temp_c) % data2D.cols;
            if (r >= data2D.rows)
                r = data2D.rows - 1;
        }
        dev_out[index] += data2D.data[r * data2D.pitchBytes + c]; 
    }
}
/*step 访问时，col * step*/
static __global__ void _d2DGloalStepKer(Data2D data2D, DATA_TYPE* dev_out, int step, int am_num)
{
    // 获得线程索引
    int c = blockIdx.x * blockDim.x + threadIdx.x;
    int r = blockIdx.y * blockDim.y + threadIdx.y;
    if (c >= data2D.cols || r >= data2D.rows)
        return ;
    // 计算输出数据的下标
    unsigned int index = r * data2D.cols + c;
    for (int i = 0; i < am_num; ++i){
        int temp_c = c + i * step;
        // 进行越界判断，并重新计算下标
        if (temp_c >= data2D.cols) {
            r += (temp_c) / data2D.cols; 
            c = (temp_c) % data2D.cols;
            if (r >= data2D.rows)
                r = data2D.rows - 1;
        }
        dev_out[index] += data2D.data[(r * data2D.pitchBytes + c)];
    }
}
static __global__ void _d2DGloalCommonKer(Data2D data2D, DATA_TYPE* dev_out, int am_num, int* am_data)
{
    // 获得线程索引
    unsigned int c = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned int r = blockIdx.y * blockDim.y + threadIdx.y;
    if (c >= data2D.cols || r >= data2D.rows)
        return ;
    // 计算输出数据的下标
    unsigned int index = r * data2D.cols + c;
    // 数据大小
    unsigned int size = data2D.cols * data2D.rows;
    for (int i = 0; i < am_num; ++i){
        // 从 am_data 中根据线程下标得到访问数据下标
        // 并重新计算 r c
        unsigned int temp_am_data = am_data[(index + i) % size];
        c = temp_am_data % data2D.cols;
        r = temp_am_data / data2D.rows;
        if (r >= data2D.rows)
            r = data2D.rows - 1;
        dev_out[index] += data2D.data[r * data2D.pitchBytes + c];
    }
}

static __global__ void _d2DSharedSequentialKer(Data2D data2D, DATA_TYPE* dev_out, int am_num, int copy_num_per_thread)
{
    // 获得线程索引
    unsigned int c = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned int r = blockIdx.y * blockDim.y + threadIdx.y;
    if (c >= data2D.cols || r >= data2D.rows)
        return ;
    // 计算输出数据的下标
    unsigned int index = r * data2D.cols + c;
    // 数据大小
    unsigned int size = data2D.cols * data2D.rows;
    // 申请 shared memory，并拷贝数据
    extern __shared__ DATA_TYPE sharedData[];
    for (int i = 0; i < copy_num_per_thread; ++i) {
        // 计算要拷贝数据的下标
        int copt_index = index * copy_num_per_thread + i;
        if (copt_index < size) {
            // 又要考虑溢出问题……
            r = r + (c+i) / data2D.cols;
            if (r >= data2D.rows)
                r = data2D.rows - 1;
            sharedData[copt_index] = data2D.data[r * data2D.pitchBytes + (c+i) % data2D.cols];
        }
    }
    __syncthreads();

    for (int i = 0; i < am_num; ++i) {
        // 因为 shared 是一维数组，所以在这里并不需要考虑溢出问题
        dev_out[index] += sharedData[(r * data2D.cols + c + i) % size]; 
    }
}
static __global__ void _d2DSharedStepKer(Data2D data2D, DATA_TYPE* dev_out, int step, int am_num, int copy_num_per_thread)
{
    // 获得线程索引
    unsigned int c = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned int r = blockIdx.y * blockDim.y + threadIdx.y;
    if (c >= data2D.cols || r >= data2D.rows)
        return ;
    // 计算输出数据的下标
    unsigned int index = r * data2D.cols + c;
    // 数据大小
    unsigned int size = data2D.cols * data2D.rows;
    // 申请 shared memory，并拷贝数据
    extern __shared__ DATA_TYPE sharedData[];
    for (int i = 0; i < copy_num_per_thread; ++i) {
        // 计算要拷贝数据的下标
        int copt_index = index * copy_num_per_thread + i;
        if (copt_index < size) {
            // 又要考虑溢出问题……
            r = r + (c+i) / data2D.cols;
            if (r >= data2D.rows)
                r = data2D.rows - 1;
            sharedData[copt_index] = data2D.data[r  * data2D.pitchBytes + (c+i) % data2D.cols];
        }
    }
    __syncthreads();

    for (int i = 0; i < am_num; ++i) {
        // 因为 shared 是一维数组，所以在这里并不需要考虑溢出问题
        dev_out[index] += sharedData[(r * data2D.cols + c + i * step) % size]; 
    }
}
static __global__ void _d2DSharedCommonKer(Data2D data2D, DATA_TYPE* dev_out, int am_num, int* am_data, int copy_num_per_thread)
{
    // 获得线程索引
    unsigned int c = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned int r = blockIdx.y * blockDim.y + threadIdx.y;
    if (c >= data2D.cols || r >= data2D.rows)
        return ;
    // 计算输出数据的下标
    unsigned int index = r * data2D.cols + c;
    // 数据大小
    unsigned int size = data2D.cols * data2D.rows;
    // 申请 shared memory，并拷贝数据
    extern __shared__ DATA_TYPE sharedData[];
    for (int i = 0; i < copy_num_per_thread; ++i) {
        // 计算要拷贝数据的下标
        int copt_index = index * copy_num_per_thread + i;
        if (copt_index < size) {
            // 又要考虑溢出问题……
            r = r + (c+i) / data2D.cols;
            if (r >= data2D.rows)
                r = data2D.rows - 1;
            sharedData[copt_index] = data2D.data[r * data2D.pitchBytes + (c+i) % data2D.cols];
        }
    }
    __syncthreads();

    for (int i = 0; i < am_num; ++i) {
        // 从 am_data 中根据线程下标得到访问数据下标
        // 并重新计算 r c
        unsigned int temp_am_data = am_data[(index + i) % size];
        c = temp_am_data % data2D.cols;
        r = temp_am_data / data2D.rows;
        if (r >= data2D.rows)
            r = data2D.rows - 1;
        dev_out[index] += sharedData[r * data2D.cols + c];
    }
}
/*
申请一个二维的常量内存
常量内存需要设置成二维的，设成成一维的话，就跟一维数组没有区别了……
 */
static __global__ void _d2DConstantSequentialKer(DATA_TYPE* dev_out, int am_num, int cols, int rows)
{
    // 获得线程索引
    unsigned int c = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned int r = blockIdx.y * blockDim.y + threadIdx.y;
    if (c >= cols || r >= rows)
        return ;
    // 计算输出数据的下标
    unsigned int index = r * cols + c;
    // 数据大小
    // unsigned int size = cols * rows;

    for (int i = 0; i < am_num; ++i) {
        r += (c+i) / cols;
        c = (c+i) % cols;
        if (r >= rows)
            r = rows - 1;
        dev_out[index] += constant_data2D[r][c]; 
    }

}
static __global__ void _d2DConstantStepKer(DATA_TYPE* dev_out, int step, int am_num, int cols, int rows)
{
    // 获得线程索引
    unsigned int c = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned int r = blockIdx.y * blockDim.y + threadIdx.y;
    if (c >= cols || r >= rows)
        return ;
    // 计算输出数据的下标
    unsigned int index = r * cols + c;
    // 数据大小
    // unsigned int size = cols * rows;

    for (int i = 0; i < am_num; ++i) {
        r += (c + i*step) / cols;
        c = (c + i*step) % cols;
        if (r >= rows)
            r = rows - 1;
        dev_out[index] += constant_data2D[r][c]; 
    }
}
static __global__ void _d2DConstantCommonKer(DATA_TYPE* dev_out, int am_num, int* am_data, int cols, int rows)
{
    // 获得线程索引
    unsigned int c = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned int r = blockIdx.y * blockDim.y + threadIdx.y;
    if (c >= cols || r >= rows)
        return ;
    // 计算输出数据的下标
    unsigned int index = r * cols + c;
    // 数据大小
    // unsigned int size = cols * rows;

    for (int i = 0; i < am_num; ++i) {
        r += am_data[index] / cols;
        c = am_data[index] % cols;
        if (r >= rows)
            r = rows - 1;
        dev_out[index] += constant_data2D[r][c]; 
    }
}

/*
树的访问方式：
根据下标访问某一个节点，然后求该节点的子节点之和
树结构本质上是一个一维数组
*/
static __global__ void _treeGloalSequentialKer(Tree tree, int am_num, DATA_TYPE* dev_out)
{
    // 获得线程索引
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index >= tree.num)
        return ;
    for (int i = 0; i < am_num; ++i) {
        int tempindex = (index + i) * 2 + 1;
        dev_out[index] += tree.nodes[tempindex % tree.num].data;
        tempindex ++;
        dev_out[index] += tree.nodes[tempindex % tree.num].data;     
    }
}
static __global__ void _treeGloalStepKer(Tree tree, int step, int am_num, DATA_TYPE* dev_out)
{
    // 获得线程索引
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index >= tree.num)
        return ;
    for (int i = 0; i < am_num; ++i) {
        int tempindex = (index + i) * 2 + 1;
        dev_out[index] += tree.nodes[tempindex % tree.num].data;
        tempindex ++;
        dev_out[index] += tree.nodes[tempindex % tree.num].data;     
    }
}
static __global__ void _treeGloalCommonKer(Tree tree, int am_num, DATA_TYPE* dev_out, int* am_data)
{
    // 获得线程索引
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index >= tree.num)
        return ;
    for (int i = 0; i < am_num; ++i) {
        int tempindex = (index + i) * 2 + 1;
        dev_out[index] += tree.nodes[tempindex % tree.num].data;
        tempindex ++;
        dev_out[index] += tree.nodes[tempindex % tree.num].data;     
    }
}

static __global__ void _treeSharedSequentialKer(Tree tree, int am_num, DATA_TYPE* dev_out, int copy_num_per_thread)
{
    // 获得线程索引
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index >= tree.num)
        return ;
    // 将数据拷贝到共享内存中,
    // 大小需要在核函数外设置
    extern __shared__ Node sharedNodes[];
    // 一个线程拷贝 (data_size + T - 1) / T 个数据
    for (int i = 0; i < copy_num_per_thread; ++i) {
        // 计算要拷贝数据的下标
        int copy_index = index * copy_num_per_thread + i;
        if (copy_index < tree.num) {
            sharedNodes[copy_index].left = tree.nodes[copy_index].left;
            sharedNodes[copy_index].right = tree.nodes[copy_index].right;
            sharedNodes[copy_index].data = tree.nodes[copy_index].data;
        }
    }
    __syncthreads();

    for (int i = 0; i < am_num; ++i) {
        int tempindex = (index + i) * 2 + 1;
        dev_out[index] += sharedNodes[tempindex % tree.num].data;
        tempindex ++;
        dev_out[index] += sharedNodes[tempindex % tree.num].data;     
    }
}
static __global__ void _treeSharedStepKer(Tree tree, int step, int am_num, DATA_TYPE* dev_out, int copy_num_per_thread)
{
    // 获得线程索引
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index >= tree.num)
        return ;
    // 将数据拷贝到共享内存中,
    // 大小需要在核函数外设置
    extern __shared__ Node sharedNodes[];
    // 一个线程拷贝 (data_size + T - 1) / T 个数据
    for (int i = 0; i < copy_num_per_thread; ++i) {
        // 计算要拷贝数据的下标
        int copy_index = index * copy_num_per_thread + i;
        if (copy_index < tree.num) {
            sharedNodes[copy_index].left = tree.nodes[copy_index].left;
            sharedNodes[copy_index].right = tree.nodes[copy_index].right;
            sharedNodes[copy_index].data = tree.nodes[copy_index].data;
        }
    }
    __syncthreads();

    for (int i = 0; i < am_num; ++i) {
        int tempindex = (index + i) * 2 + 1;
        dev_out[index] += sharedNodes[tempindex % tree.num].data;
        tempindex ++;
        dev_out[index] += sharedNodes[tempindex % tree.num].data;     
    }
}
static __global__ void _treeSharedCommonKer(Tree tree, int am_num, DATA_TYPE* dev_out, int* am_data, int copy_num_per_thread)
{
    // 获得线程索引
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index >= tree.num)
        return ;
    // 将数据拷贝到共享内存中,
    // 大小需要在核函数外设置
    extern __shared__ Node sharedNodes[];
    // 一个线程拷贝 (data_size + T - 1) / T 个数据
    for (int i = 0; i < copy_num_per_thread; ++i) {
        // 计算要拷贝数据的下标
        int copy_index = index * copy_num_per_thread + i;
        if (copy_index < tree.num) {
            sharedNodes[copy_index].left = tree.nodes[copy_index].left;
            sharedNodes[copy_index].right = tree.nodes[copy_index].right;
            sharedNodes[copy_index].data = tree.nodes[copy_index].data;
        }
    }
    __syncthreads();

    for (int i = 0; i < am_num; ++i) {
        int tempindex = (index + i) * 2 + 1;
        dev_out[index] += sharedNodes[tempindex % tree.num].data;
        tempindex ++;
        dev_out[index] += sharedNodes[tempindex % tree.num].data;     
    }
}

static __global__ void _treeConstantSequentialKer(int size, int am_num, DATA_TYPE* dev_out)
{
    // 获得线程索引
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index >= size)
        return ;

    for (int i = 0; i < am_num; ++i) {
        int tempindex = (index + i) * 2 + 1;
        dev_out[index] += constant_treeNodes[tempindex % size].data;
        tempindex ++;
        dev_out[index] += constant_treeNodes[tempindex % size].data;     
    }
}
static __global__ void _treeConstantStepKer(int size, int step, int am_num, DATA_TYPE* dev_out)
{
    // 获得线程索引
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index >= size)
        return ;
    for (int i = 0; i < am_num; ++i) {
        int tempindex = (index + i) * 2 + 1;
        dev_out[index] += constant_treeNodes[tempindex % size].data;
        tempindex ++;
        dev_out[index] += constant_treeNodes[tempindex % size].data;     
    }
}
static __global__ void _treeConstantCommonKer(int size, int am_num, DATA_TYPE* dev_out, int* am_data)
{
    // 获得线程索引
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index >= size)
        return ;
    for (int i = 0; i < am_num; ++i) {
        int tempindex = (index + i) * 2 + 1;
        dev_out[index] += constant_treeNodes[tempindex % size].data;
        tempindex ++;
        dev_out[index] += constant_treeNodes[tempindex % size].data;     
    }
}

// 申请device内存
// 内存拷贝
// 核函数
int Case::global_run()
{
    // 错误代码
    cudaError_t cuerrcode;

    // 申请device内存
    DATA_TYPE *d_data1D = NULL;
    Data2D d_data2D;
    d_data2D.data = NULL;
    Tree d_tree;  // 无参构造函数，没有申请节点空间
    d_tree.nodes = NULL;

    DATA_TYPE *dev_out1D = NULL;
    DATA_TYPE *dev_out2D = NULL;
    DATA_TYPE *dev_outTree = NULL;

    int *dev_am_data = NULL;

    // 根据内部数据分布，申请空间并拷贝数据
    switch (this->df)
    {
    case df_1D:
        // 申请device端空间
        cuerrcode = cudaMalloc((void **)&d_data1D, sizeof(DATA_TYPE) * this->size);
        if (cuerrcode != cudaSuccess) 
            return -1;
        // 数据拷贝
        cuerrcode = cudaMemcpy(d_data1D, this->data1D, sizeof(DATA_TYPE) * this->size, cudaMemcpyHostToDevice);
        if (cuerrcode != cudaSuccess) {
            // 数据拷贝出错，返回错误代码前释放申请的空间
            cudaFree(d_data1D);
            return -1;
        }
        break;
    case df_2D:
        // 错误情况判断
        if (this->c == -1 || this->r == -1)
            return -2;
        d_data2D.cols = this->c;
        d_data2D.rows = this->r;
        this->size = this->r * this->c;
        cuerrcode = cudaMallocPitch((void **)&d_data2D.data, &d_data2D.pitchBytes,
                                      d_data2D.cols * sizeof(DATA_TYPE), d_data2D.rows);
        if (cuerrcode != cudaSuccess) 
            return -1;
        cuerrcode = cudaMemcpy2D(d_data2D.data, d_data2D.pitchBytes, 
                                   this->data2D.data, d_data2D.pitchBytes,
                                   d_data2D.cols * sizeof(DATA_TYPE), d_data2D.rows,
                                   cudaMemcpyHostToDevice);
        if (cuerrcode != cudaSuccess) {
            // 数据拷贝出错，返回错误代码前释放申请的空间
            cudaFree(d_data2D.data);
            return -1;
        }
        break;
    case df_tree:
        d_tree.num = this->size;
        cuerrcode = cudaMalloc((void**)&d_tree.nodes, sizeof(Node) * d_tree.num);
        if (cuerrcode != cudaSuccess)
            return -1;
        cuerrcode = cudaMemcpy(d_tree.nodes, this->tree->nodes, sizeof(Node) * d_tree.num, cudaMemcpyHostToDevice);
        if (cuerrcode != cudaSuccess) {
            cudaFree(d_tree.nodes);
            return -1;
        }
        break;
    }
    // 根据数据形式和访问方式的不同执行不同的核函数
    switch(this->df) {
    case df_1D:
    {
        // 申请 out 数组空间
        cuerrcode = cudaMalloc((void**)&dev_out1D, sizeof(DATA_TYPE) * this->size);
        if (cuerrcode != cudaSuccess) {
            cudaFree(d_data1D);
            return -1;
        }
        cuerrcode = cudaMemset((void*)dev_out1D, 0, sizeof(DATA_TYPE) * this->size);
        if (cuerrcode != cudaSuccess) {
            cudaFree(dev_out1D);
            cudaFree(d_data1D);
            return -1;
        }
        // 核函数
        // 计算线程数
        int gridsize_1d, blocksize_1d;
        blocksize_1d = this->block_size;
        gridsize_1d = (this->thread_num + blocksize_1d - 1) / blocksize_1d;
        if (this->am == am_step) {
            _d1DGloalStepKer<<<gridsize_1d, blocksize_1d>>>(d_data1D, dev_out1D, this->step, this->am_num, this->size);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(d_data1D);
                cudaFree(dev_out1D);
                return -3;
            }
        } else if (this->am == am_sequential) {
            _d1DGloalSequentialKer<<<gridsize_1d, blocksize_1d>>>(d_data1D, dev_out1D, this->am_num, this->size);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(d_data1D);
                cudaFree(dev_out1D);
                return -3;
            }
        } else {
            // device 端访问下标数据
            int *dev_am_data;
            cuerrcode = cudaMalloc((void**)&dev_am_data, sizeof(int) * this->size);
            if (cuerrcode != cudaSuccess) {
                cudaFree(d_data1D);
                cudaFree(dev_out1D);
                return -3;
            }

            cuerrcode = cudaMemcpy(dev_am_data, host_am_data, sizeof(int) * this->size, cudaMemcpyHostToDevice);
            if (cuerrcode != cudaSuccess) {
                cudaFree(d_data1D);
                cudaFree(dev_out1D);
                cudaFree(dev_am_data);
                return -3;
            }
            // curandDestroyGenerator(gen);

            _d1DGloalCommonKer<<<gridsize_1d, blocksize_1d>>>(d_data1D, dev_out1D, this->am_num, dev_am_data, this->size);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(d_data1D);
                cudaFree(dev_out1D);
                cudaFree(dev_am_data);
                return -3;
            }
        }
        break;
    }
    case df_2D:
    {
        // 计算二维数组的大小，这里重新计算的是为了方式只测试二维数组时，成员变量size
        // 没有及时更新。
        unsigned int size_2D = d_data2D.cols * d_data2D.rows;
        // 申请 out 数组空间
        cuerrcode = cudaMalloc((void**)&dev_out2D, sizeof(DATA_TYPE) * size_2D);
        if (cuerrcode != cudaSuccess) {
            cudaFree(d_data2D.data);
            return -1;
        }
        cuerrcode = cudaMemset((void*)dev_out2D, 0, sizeof(DATA_TYPE) * size_2D);
        if (cuerrcode != cudaSuccess) {
            cudaFree(dev_out2D);
            cudaFree(d_data2D.data);
            return -1;
        }
        // 计算线程数，设置二维网格
        // 默认 block.x为 32
        dim3 gridsize, blocksize;
        blocksize.x = DEF_BLOCK_X; // = 32
        blocksize.y = this->block_size / blocksize.x;
        gridsize.x = (d_data2D.cols + blocksize.x - 1) / blocksize.x;
        gridsize.y = (d_data2D.rows + blocksize.y - 1) / blocksize.y;
        if (this->am == am_sequential) {
            _d2DGloalSequentialKer<<<gridsize, blocksize>>>(d_data2D, dev_out2D, this->am_num);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(dev_out2D);
                cudaFree(d_data2D.data);
                return -3;
            }
        } else if (this->am == am_step) {
            _d2DGloalStepKer<<<gridsize, blocksize>>>(d_data2D, dev_out2D, this->step, this->am_num);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(dev_out2D);
                cudaFree(d_data2D.data);
                return -3;
            }
        } else {

            // 根据不同访问方式在核函数外生成访问下标
            // P.S. 虽然可以用curand在核函数外生成一些分布，但am_geometric分布和am_exponential分布无法生成，
            // 为了考虑性能测试统一，不使用curand。
            // 先在 host 端生成下标分布数据，然后再拷贝到 device 端。
            // device 端访问下标数据
            int *dev_am_data;
            cuerrcode = cudaMalloc((void**)&dev_am_data, sizeof(int) * this->size);
            if (cuerrcode != cudaSuccess) {
                cudaFree(d_data2D.data);
                cudaFree(dev_out2D);
                return -3;
            }

            cuerrcode = cudaMemcpy(dev_am_data, host_am_data, sizeof(int) * size_2D, cudaMemcpyHostToDevice);
            if (cuerrcode != cudaSuccess) {
                cudaFree(dev_am_data);
                cudaFree(dev_out2D);
                cudaFree(d_data2D.data);
                return -3;
            }

            _d2DGloalCommonKer<<<gridsize, blocksize>>>(d_data2D, dev_out2D, this->am_num, dev_am_data);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(dev_am_data);
                cudaFree(dev_out2D);
                cudaFree(d_data2D.data);
                return -3;
            }
        }
        break;
    }
    case df_tree: {
        cuerrcode = cudaMalloc((void**)&dev_outTree, sizeof(DATA_TYPE) * this->tree->num);
        if (cuerrcode != cudaSuccess) {
            cudaFree(d_tree.nodes);
            return -1;
        }
        cuerrcode = cudaMemset((void*)dev_outTree, 0, sizeof(DATA_TYPE) * this->tree->num);
        if (cuerrcode != cudaSuccess) {
            cudaFree(d_tree.nodes);
            cudaFree(dev_outTree);
            return -1;
        }
        int gridsize_1d, blocksize_1d;
        blocksize_1d = this->block_size;
        gridsize_1d = (this->thread_num + blocksize_1d - 1) / blocksize_1d;
        // 核函数
        if (this->am == am_sequential) {
            _treeGloalSequentialKer<<<gridsize_1d, blocksize_1d>>>(d_tree, this->am_num, dev_outTree);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(dev_outTree);
                cudaFree(d_tree.nodes);
                return -3;
            }
        } else if (this->am == am_step) {
            _treeGloalStepKer<<<gridsize_1d, blocksize_1d>>>(d_tree, this->step, this->am_num, dev_outTree);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(dev_outTree);
                cudaFree(d_tree.nodes);
                return -3;
            }
        } else {
            // device 端访问下标数据
            cuerrcode = cudaMalloc((void**)&dev_am_data, sizeof(int) * this->size);
            if (cuerrcode != cudaSuccess) {
                cudaFree(dev_outTree);
                cudaFree(d_tree.nodes);
                return -3;
            }

            cuerrcode = cudaMemcpy(dev_am_data, host_am_data, sizeof(int) * this->size, cudaMemcpyHostToDevice);
            if (cuerrcode != cudaSuccess) {
                cudaFree(dev_outTree);
                cudaFree(d_tree.nodes);
                cudaFree(dev_am_data);
                return -3;
            }

            _treeGloalCommonKer<<<gridsize_1d, blocksize_1d>>>(d_tree, this->am_num, dev_outTree, dev_am_data);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(dev_outTree);
                cudaFree(d_tree.nodes);
                cudaFree(dev_am_data);
                return -3;
            }
        }
        break;
    }
    }

    if (d_data1D == NULL)
        cudaFree(d_data1D);
    if (d_data2D.data == NULL)
        cudaFree(d_data2D.data);
    if (d_tree.nodes == NULL)
        cudaFree(d_tree.nodes);

    if (dev_out1D == NULL)
        cudaFree(dev_out1D);
    if (dev_out2D == NULL)
        cudaFree(dev_out2D);
    if (dev_outTree == NULL)
        cudaFree(dev_outTree);
    if (dev_am_data == NULL)
        cudaFree(dev_am_data);

    return 0;
}

int Case::shared_run()
{
    // 错误代码
    cudaError_t cuerrcode;

    // 申请device内存
    DATA_TYPE *d_data1D = NULL;
    Data2D d_data2D;
    d_data2D.data = NULL;
    Tree d_tree;  // 无参构造函数，没有申请节点空间
    d_tree.nodes = NULL;
    d_tree.num = this->size;


    DATA_TYPE *dev_out1D = NULL;
    DATA_TYPE *dev_out2D = NULL;
    DATA_TYPE *dev_outTree = NULL;

    int *dev_am_data = NULL;

    // 根据内部数据分布，申请空间并拷贝数据
    switch (this->df)
    {
    case df_1D:
        // 申请device端空间
        cuerrcode = cudaMalloc((void **)&d_data1D, sizeof(DATA_TYPE) * this->size);
        if (cuerrcode != cudaSuccess) 
            return -1;
        // 数据拷贝
        cuerrcode = cudaMemcpy(d_data1D, this->data1D, sizeof(DATA_TYPE) * this->size, cudaMemcpyHostToDevice);
        if (cuerrcode != cudaSuccess) {
            // 数据拷贝出错，返回错误代码前释放申请的空间
            cudaFree(d_data1D);
            return -1;
        }
        break;
    case df_2D:
        // 错误情况判断
        if (this->c == -1 || this->r == -1)
            return -2;
        d_data2D.cols = this->c;
        d_data2D.rows = this->r;
        cuerrcode = cudaMallocPitch((void **)&d_data2D.data, &d_data2D.pitchBytes,
                                      d_data2D.cols * sizeof(DATA_TYPE), d_data2D.rows);
        if (cuerrcode != cudaSuccess) 
            return -1;
        cuerrcode = cudaMemcpy2D(d_data2D.data, d_data2D.pitchBytes, 
                                   this->data2D.data, d_data2D.pitchBytes,
                                   d_data2D.cols * sizeof(DATA_TYPE), d_data2D.rows,
                                   cudaMemcpyHostToDevice);
        if (cuerrcode != cudaSuccess) {
            // 数据拷贝出错，返回错误代码前释放申请的空间
            cudaFree(d_data2D.data);
            return -1;
        }
        break;
    case df_tree:
        cuerrcode = cudaMalloc((void**)&d_tree.nodes, sizeof(Node) * d_tree.num);
        if (cuerrcode != cudaSuccess)
            return -1;
        cuerrcode = cudaMemcpy(d_tree.nodes, this->tree->nodes, sizeof(Node) * d_tree.num, cudaMemcpyHostToDevice);
        if (cuerrcode != cudaSuccess)
        {
            cudaFree(d_tree.nodes);
            return -1;
        }
        break;
    }
    // 根据数据形式和访问方式的不同执行不同的核函数
    switch(this->df) {
    case df_1D: {
        // 申请 out 数组空间
        cuerrcode = cudaMalloc((void**)&dev_out1D, sizeof(DATA_TYPE) * this->size);
        if (cuerrcode != cudaSuccess) {
            cudaFree(d_data1D);
            return -1;
        }
        cuerrcode = cudaMemset((void*)dev_out1D, 0, sizeof(DATA_TYPE) * this->size);
        if (cuerrcode != cudaSuccess) {
            cudaFree(dev_out1D);
            cudaFree(d_data1D);
            return -1;
        }
        // 核函数
        // 计算线程数
        int gridsize_1d, blocksize_1d;
        blocksize_1d = this->block_size;
        gridsize_1d = (this->thread_num + blocksize_1d - 1) / blocksize_1d;
        // 每个线程拷贝多少个数据到shared memory
        int copy_num_per_thread = (this->size + this->block_size - 1) / this->block_size;
        if (this->am == am_step) {
            _d1DSharedStepKer<<<gridsize_1d, blocksize_1d, this->size>>>
                             (d_data1D, dev_out1D, this->step, this->am_num, this->size, copy_num_per_thread);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(d_data1D);
                cudaFree(dev_out1D);
                return -3;
            }
        } else if (this->am == am_sequential) {
            _d1DSharedSequentialKer<<<gridsize_1d, blocksize_1d, this->size>>>
                                   (d_data1D, dev_out1D, this->am_num, this->size, copy_num_per_thread);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(d_data1D);
                cudaFree(dev_out1D);
                return -3;
            }
        } else {
            // device 端访问下标数据
            int *dev_am_data;
            cuerrcode = cudaMalloc((void**)&dev_am_data, sizeof(int) * this->size);
            if (cuerrcode != cudaSuccess) {
                cudaFree(d_data1D);
                cudaFree(dev_out1D);
                return -3;
            }
            cuerrcode = cudaMemcpy(dev_am_data, host_am_data, sizeof(float) * this->size, cudaMemcpyHostToDevice);
            if (cuerrcode != cudaSuccess) {
                cudaFree(d_data1D);
                cudaFree(dev_out1D);
                cudaFree(dev_am_data);
                return -3;
            }

            _d1DSharedCommonKer<<<gridsize_1d, blocksize_1d, this->size>>>
                               (d_data1D, dev_out1D, this->am_num, this->size, dev_am_data, copy_num_per_thread);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(d_data1D);
                cudaFree(dev_out1D);
                cudaFree(dev_am_data);
                return -3;
            }
        }
        break;
    }
    case df_2D: 
    {
        // 计算二维数组的大小，这里重新计算的是为了方式只测试二维数组时，成员变量size
        // 没有及时更新。
        unsigned int size_2D = d_data2D.cols * d_data2D.rows;

        // 申请 out 数组空间
        cuerrcode = cudaMalloc((void**)&dev_out2D, sizeof(DATA_TYPE) * size_2D);
        if (cuerrcode != cudaSuccess) {
            cudaFree(d_data2D.data);
            return -1;
        }
        cuerrcode = cudaMemset((void*)dev_out2D, 0, sizeof(DATA_TYPE) * size_2D);
        if (cuerrcode != cudaSuccess) {
            cudaFree(dev_out2D);
            cudaFree(d_data2D.data);
            return -1;
        }
        // 每个线程拷贝多少个数据到shared memory
        int copy_num_per_thread = (size_2D + this->block_size - 1) / this->block_size;
        // 计算线程数，设置二维网格
        // 默认 block.x为 32
        dim3 gridsize, blocksize;
        blocksize.x = DEF_BLOCK_X; // = 32
        blocksize.y = this->block_size / blocksize.x;
        gridsize.x = (d_data2D.cols + blocksize.x - 1) / blocksize.x;
        gridsize.y = (d_data2D.rows + blocksize.y - 1) / blocksize.y;
        if (this->am == am_sequential) {
            _d2DSharedSequentialKer<<<gridsize, blocksize, size_2D>>>(d_data2D, dev_out2D, this->am_num, copy_num_per_thread);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(d_data2D.data);
                cudaFree(dev_out2D);
                return -3;
            }
        } else if (this->am == am_step) {
            _d2DSharedStepKer<<<gridsize, blocksize, size_2D>>>(d_data2D, dev_out2D, this->step, this->am_num, copy_num_per_thread);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(d_data2D.data);
                cudaFree(dev_out2D);
                return -3;
            }
        } else {

            // 根据不同访问方式在核函数外生成访问下标
            // P.S. 虽然可以用curand在核函数外生成一些分布，但am_geometric分布和am_exponential分布无法生成，
            // 为了考虑性能测试统一，不使用curand。
            // 先在 host 端生成下标分布数据，然后再拷贝到 device 端。
            // device 端访问下标数据
            cuerrcode = cudaMalloc((void**)&dev_am_data, sizeof(int) * this->size);
            if (cuerrcode != cudaSuccess) {
                cudaFree(d_data1D);
                cudaFree(dev_out2D);
                return -3;
            }

            cuerrcode = cudaMemcpy(dev_am_data, host_am_data, sizeof(int) * size_2D, cudaMemcpyHostToDevice);
            if (cuerrcode != cudaSuccess) {
                cudaFree(dev_am_data);
                cudaFree(d_data2D.data);
                cudaFree(dev_out2D);
                return -3;
            }

            _d2DSharedCommonKer<<<gridsize, blocksize, size_2D>>>(d_data2D, dev_out2D, this->am_num, dev_am_data, copy_num_per_thread);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(dev_am_data);
                cudaFree(d_data2D.data);
                cudaFree(dev_out2D);
                return -3;
            }
        }
        break;
    }
    case df_tree: 
    {
        cuerrcode = cudaMalloc((void**)&dev_outTree, sizeof(DATA_TYPE) * this->tree->num);
        if (cuerrcode != cudaSuccess) {
            cudaFree(d_tree.nodes);
            return -1;
        }
        cuerrcode = cudaMemset((void*)dev_outTree, 0, sizeof(DATA_TYPE) * this->tree->num);
        if (cuerrcode != cudaSuccess) {
            cudaFree(d_tree.nodes);
            cudaFree(dev_outTree);
            return -1;
        }
        int gridsize_1d, blocksize_1d;
        blocksize_1d = this->block_size;
        gridsize_1d = (this->thread_num + blocksize_1d - 1) / blocksize_1d;
        // 每个线程拷贝多少个数据到shared memory
        int copy_num_per_thread = (this->size + this->block_size - 1) / this->block_size;

        // 核函数
        if (this->am == am_sequential) {
            _treeSharedSequentialKer<<<gridsize_1d, blocksize_1d, this->size>>>(d_tree, this->am_num, dev_outTree, copy_num_per_thread);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(dev_outTree);
                cudaFree(d_tree.nodes);
                return -3;
            }
        } else if (this->am == am_step) {
            _treeSharedStepKer<<<gridsize_1d, blocksize_1d, this->size>>>(d_tree, this->step, this->am_num, dev_outTree, copy_num_per_thread);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(dev_outTree);
                cudaFree(d_tree.nodes);
                return -3;
            }
        } else {
            // device 端访问下标数据
            int *dev_am_data;
            cuerrcode = cudaMalloc((void**)&dev_am_data, sizeof(int) * this->size);
            if (cuerrcode != cudaSuccess) {
                cudaFree(dev_outTree);
                cudaFree(d_tree.nodes);
                return -3;
            }

            cuerrcode = cudaMemcpy(dev_am_data, host_am_data, sizeof(int) * this->size, cudaMemcpyHostToDevice);
            if (cuerrcode != cudaSuccess) {
                cudaFree(dev_outTree);
                cudaFree(d_tree.nodes);
                cudaFree(dev_am_data);
                return -3;
            }

            _treeSharedCommonKer<<<gridsize_1d, blocksize_1d, this->size>>>(d_tree, this->am_num, dev_outTree, dev_am_data, copy_num_per_thread);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(dev_outTree);
                cudaFree(d_tree.nodes);
                cudaFree(dev_am_data);
                return -3;
            }
        }
        break;
    }
    }

    if (d_data1D == NULL)
        cudaFree(d_data1D);
    if (d_data2D.data == NULL)
        cudaFree(d_data2D.data);
    if (d_tree.nodes == NULL)
        cudaFree(d_tree.nodes);

    if (dev_out1D == NULL)
        cudaFree(dev_out1D);
    if (dev_out2D == NULL)
        cudaFree(dev_out2D);
    if (dev_outTree == NULL)
        cudaFree(dev_outTree);
    if (dev_am_data == NULL)
        cudaFree(dev_am_data);

    return 0;
}

int Case::constant_run()
{
    // 错误代码
    cudaError_t cuerrcode;

    // 根据内部数据分布，申请空间并拷贝数据
    switch (this->df)
    {
    case df_1D:
        // 数据拷贝
        // (constant_lut, lut, sizeof(unsigned char) * 256);
        cuerrcode = cudaMemcpyToSymbol(constant_data1D, this->data1D, sizeof(DATA_TYPE) * this->size);
        if (cuerrcode != cudaSuccess) {
            // 数据拷贝出错，返回错误代码前释放申请的空间
            // free(this->data1D);
            return -1;
        }
        break;
    case df_2D:
        // 错误情况判断
        if (this->c == -1 || this->r == -1)
            return -2;
        // 虽然这里的赋值看似无用，但可增强代码健壮性
        data2D.cols = this->c;
        data2D.rows = this->r;

        cuerrcode = cudaMemcpyToSymbol(constant_data2D, this->data2D.data, sizeof(DATA_TYPE) * this->c * this->r);
        if (cuerrcode != cudaSuccess) {
            // 数据拷贝出错，返回错误代码前释放申请的空间
            // free(this->data2D.data);
            return -1;
        }
        break;
    case df_tree:

        cuerrcode = cudaMemcpyToSymbol(constant_treeNodes, this->tree->nodes, sizeof(Node) * this->tree->num);
        if (cuerrcode != cudaSuccess) {
            // cudaFree(this->tree->nodes);
            return -1;
        }
        break;
    }
    // 根据数据形式和访问方式的不同执行不同的核函数
    switch(this->df) {
    case df_1D:
    {
        DATA_TYPE *dev_out1D;
        // 申请 out 数组空间
        cuerrcode = cudaMalloc((void**)&dev_out1D, sizeof(DATA_TYPE) * this->size);
        if (cuerrcode != cudaSuccess) {
            return -1;
        }
        cuerrcode = cudaMemset((void*)dev_out1D, 0, sizeof(DATA_TYPE) * this->size);
        if (cuerrcode != cudaSuccess) {
            cudaFree(dev_out1D);
            return -1;
        }
        // 核函数
        // 计算线程数
        int gridsize_1d, blocksize_1d;
        blocksize_1d = this->block_size;
        gridsize_1d = (this->thread_num + blocksize_1d - 1) / blocksize_1d;
        if (this->am == am_step) {
            _d1DConstantStepKer<<<gridsize_1d, blocksize_1d>>>(dev_out1D, this->step, this->am_num, this->size);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(dev_out1D);
                return -3;
            }
        } else if (this->am == am_sequential) {
            _d1DConstantSequentialKer<<<gridsize_1d, blocksize_1d>>>(dev_out1D, this->am_num, this->size);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(dev_out1D);
                return -3;
            }
        } else {
            // device 端访问下标数据
            int *dev_am_data;
            cuerrcode = cudaMalloc((void**)&dev_am_data, sizeof(int) * this->size);
            if (cuerrcode != cudaSuccess) {
                cudaFree(dev_out1D);
                return -3;
            }

            cuerrcode = cudaMemcpy(dev_am_data, host_am_data, sizeof(int) * this->size, cudaMemcpyHostToDevice);
            if (cuerrcode != cudaSuccess) {
                cudaFree(dev_out1D);
                cudaFree(dev_am_data);
                return -3;
            }
            // curandDestroyGenerator(gen);

            _d1DConstantCommonKer<<<gridsize_1d, blocksize_1d>>>(dev_out1D, this->am_num, dev_am_data, this->size);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(dev_out1D);
                cudaFree(dev_am_data);
                return -3;
            }
        }
        break;
    }
    case df_2D:
    {
        DATA_TYPE *dev_out2D;
        // 计算二维数组的大小，这里重新计算的是为了方式只测试二维数组时，成员变量size
        // 没有及时更新。
        unsigned int size_2D = this->c * this->r;
        // 申请 out 数组空间
        cuerrcode = cudaMalloc((void**)&dev_out2D, sizeof(DATA_TYPE) * size_2D);
        if (cuerrcode != cudaSuccess) {
            return -1;
        }
        cuerrcode = cudaMemset((void*)dev_out2D, 0, sizeof(DATA_TYPE) * size_2D);
        if (cuerrcode != cudaSuccess) {
            cudaFree(dev_out2D);
            return -1;
        }
        // 计算线程数，设置二维网格
        // 默认 block.x为 32
        dim3 gridsize, blocksize;
        blocksize.x = DEF_BLOCK_X; // = 32
        blocksize.y = this->block_size / blocksize.x;
        gridsize.x = (this->c + blocksize.x - 1) / blocksize.x;
        gridsize.y = (this->r + blocksize.y - 1) / blocksize.y;
        if (this->am == am_sequential) {
            _d2DConstantSequentialKer<<<gridsize, blocksize>>>(dev_out2D, this->am_num, this->data2D.cols, this->data2D.rows);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(dev_out2D);
                return -3;
            }
        } else if (this->am == am_step) {
            _d2DConstantStepKer<<<gridsize, blocksize>>>(dev_out2D, this->step, this->am_num, this->data2D.cols, this->data2D.rows);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(dev_out2D);
                return -3;
            }
        } else {

            // 根据不同访问方式在核函数外生成访问下标
            // P.S. 虽然可以用curand在核函数外生成一些分布，但am_geometric分布和am_exponential分布无法生成，
            // 为了考虑性能测试统一，不使用curand。
            // 先在 host 端生成下标分布数据，然后再拷贝到 device 端。
            // device 端访问下标数据
            int *dev_am_data;
            cuerrcode = cudaMalloc((void**)&dev_am_data, sizeof(int) * this->size);
            if (cuerrcode != cudaSuccess) {
                cudaFree(dev_out2D);
                return -3;
            }

            cuerrcode = cudaMemcpy(dev_am_data, host_am_data, sizeof(int) * size_2D, cudaMemcpyHostToDevice);
            if (cuerrcode != cudaSuccess) {
                cudaFree(dev_am_data);
                cudaFree(dev_out2D);
                return -3;
            }

            _d2DConstantCommonKer<<<gridsize, blocksize>>>(dev_out2D, this->am_num, dev_am_data, this->data2D.cols, this->data2D.rows);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(dev_am_data);
                cudaFree(dev_out2D);
                return -3;
            }
        }
        break;
    }
    case df_tree:
    {
        DATA_TYPE *dev_outTree;
        cuerrcode = cudaMalloc((void**)&dev_outTree, sizeof(DATA_TYPE) * this->tree->num);
        if (cuerrcode != cudaSuccess) {
            return -1;
        }
        cuerrcode = cudaMemset((void*)dev_outTree, 0, sizeof(DATA_TYPE) * this->tree->num);
        if (cuerrcode != cudaSuccess) {
            cudaFree(dev_outTree);
            return -1;
        }
        int gridsize_1d, blocksize_1d;
        blocksize_1d = this->block_size;
        gridsize_1d = (this->thread_num + blocksize_1d - 1) / blocksize_1d;
        // 核函数
        if (this->am == am_sequential) {
            _treeConstantSequentialKer<<<gridsize_1d, blocksize_1d>>>(this->size, this->am_num, dev_outTree);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(dev_outTree);
                return -3;
            }
        } else if (this->am == am_step) {
            _treeConstantStepKer<<<gridsize_1d, blocksize_1d>>>(this->size, this->step, this->am_num, dev_outTree);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(dev_outTree);
                return -3;
            }
        } else {
            // device 端访问下标数据
            int *dev_am_data;
            cuerrcode = cudaMalloc((void**)&dev_am_data, sizeof(int) * this->size);
            if (cuerrcode != cudaSuccess) {
                cudaFree(dev_outTree);
                return -3;
            }

            cuerrcode = cudaMemcpy(dev_am_data, host_am_data, sizeof(int) * this->size, cudaMemcpyHostToDevice);
            if (cuerrcode != cudaSuccess) {
                cudaFree(dev_am_data);
                cudaFree(dev_outTree);
                return -3;
            }

            _treeConstantCommonKer<<<gridsize_1d, blocksize_1d>>>(this->size, this->am_num, dev_outTree, dev_am_data);
            if (cudaGetLastError() != cudaSuccess) {
                cudaFree(dev_am_data);
                cudaFree(dev_outTree);
                return -3;
            }
        }
        break;
    }
    }
    return 0;
}

#include "Common.h"

string EnumToString(enum data_form df)
{
    switch (df)
    {
    case df_1D:
        return "df_1D";
    case df_2D:
        return "df_2D";
    case df_tree:
        return "df_tree";
    }
    return "";
}
string EnumToString(enum access_mode am)
{
    switch (am)
    {
    case am_sequential:
        return "am_sequential";
    case am_step:
        return "am_step";
    case am_random:
        return "am_random";
    case am_standard_normal:
        return "am_standard_normal";
    case am_poisson:
        return "am_poisson";
    case am_geometric:
        return "am_geometric";
    case am_exponential:
        return "am_exponential";
    }
    return "";
}
string EnumToString(enum data_content dc)
{
    switch (dc)
    {
    case dc_random:
        return "dc_random";
    case dc_standard_normal:
        return "dc_standard_normal";
    case dc_poisson:
        return "dc_poisson";
    case dc_uniform:
        return "dc_uniform";
    case dc_geometric:
        return "dc_geometric";
    case dc_exponential:
        return "dc_exponential";
    }
    return "";
}

void print(DATA_TYPE* data_1D, int size)
{
    for (int i = 0; i < size; i++)
    {
        cout << (float)data_1D[i] << " ";
    }
    cout << endl;
}

__global__ void
vectorAdd(const float *A, const float *B, float *C, int numElements)
{
    int i = blockDim.x * blockIdx.x + threadIdx.x;

    if (i < numElements)
        C[i] = A[i] + B[i];
}

// warmup 函数，用于计时时 warmup GPU，实际是一个 vector 相加
void warmup()
{
    int numElements = 1024;
    size_t size = numElements * sizeof(float);

    float *h_A = (float *)malloc(size);
    float *h_B = (float *)malloc(size);
    float *h_C = (float *)malloc(size);

    for (int i = 0; i < numElements; ++i)
    {
        h_A[i] = rand()/(float)RAND_MAX;
        h_B[i] = rand()/(float)RAND_MAX;
    }

    float *d_A = NULL;
    cudaMalloc((void **)&d_A, size);

    float *d_B = NULL;
    cudaMalloc((void **)&d_B, size);

    float *d_C = NULL;
    cudaMalloc((void **)&d_C, size);

    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);

    cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);

    int threadsPerBlock = 32;
    int blocksPerGrid =(numElements + threadsPerBlock - 1) / threadsPerBlock;
    vectorAdd<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, numElements);

    cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    free(h_A);
    free(h_B);
    free(h_C);

}


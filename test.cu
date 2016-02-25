#include <iostream>
#include <stdio.h>
using namespace std;

/* 树节点 */ 
class Node
{
public:
    Node* left;
    Node* right;
    DATA_TYPE data;
};

__global__ void testKer()
{
    printf("Node's size in GPU: %d", sizeof(Node));
}

int main()
{
    cout << "Node's size in CPU:" << sizeof(Node) << endl;

    testKer<<<1, 1>>>();

    cudaDeviceReset();
    return 0;
}
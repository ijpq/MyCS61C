#include <cstdlib>
#include <cstdio>
// perform matrix multipliation at M,N * N,K
#define M 3
#define N 3
#define K 1

int main(void) {
    int a[] = {1,2,3,4,5,6,7,8,9};
    int b[] = {1,1,1};
    int *c = (int *)malloc(sizeof(int)*M*K);
    
    for (int i =0; i < M; i++) {
        for (int j =0; j < K;j++) {
            int rval = 0;
            for (int k = 0; k < N;k++) {
                rval += *(a+i*N+k) * *(b+j+k*K);
                
            }
            *(c+i*K+j) = rval;
        }
    }

    for (int i =0; i < M*K; i++)
        printf("%d ", c[i]);
    printf("\n");

    
    return 0;
}

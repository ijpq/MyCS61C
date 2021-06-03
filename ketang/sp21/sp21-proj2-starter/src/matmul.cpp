#include <cstdlib>
#include <cstdio>

int main(void) {
    int a[] = {1,2,3,4,5,6};
    int b[] = {4,5,6,7,8,9};
    int *c = (int *)malloc(sizeof(int)*9);
    
    for (int i =0; i < 3; i++) {
        for (int j =0; j < 3;j++) {
            int rval = 0;
            for (int k = 0; k < 2;k++) {
                rval += *(a+i*2+k) * *(b+j+k*3);
                
            }
            *(c+i*3+j) = rval;
        }
    }

    for (int i =0; i < 9; i++)
        printf("%d ", c[i]);
    printf("\n");

    
    return 0;
}

#include <cstdio>
#include <cstdlib>

int main(void) {
    FILE *fp = fopen("test_input.bin", "r");
    int rval;
    int *a = (int *)malloc(sizeof(int));
    while ((rval=fread(a, 4, 1, fp) == 1)) {
        printf("%d\n", *a);
    }
    printf("eof\n");
    return 0;
}

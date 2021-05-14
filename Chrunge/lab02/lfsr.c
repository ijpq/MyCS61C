#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "lfsr.h"

void lfsr_calculate(uint16_t *reg) {
    int copy = *reg;
    int a = copy & 1;
    int b = (copy>>2) & 1;
    int c = (copy>>3) & 1;
    int d = (copy>>5) & 1;
    int e = ((a^b)^c)^d;
    e = e << 15;
    *reg = (*reg >> 1) | e;
}


/************************************************************************
**
** NAME:        imageloader.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Dan Garcia  -  University of California at Berkeley
**              Copyright (C) Dan Garcia, 2020. All rights reserved.
**              Justin Yokota - Starter Code
**				YOUR NAME HERE
**
**
** DATE:        2020-08-15
**
**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <string.h>
#include "imageloader.h"

#define MALLOC_CHK(ptr) if(!ptr) exit(-1)
//Opens a .ppm P3 image file, and constructs an Image object. 
//You may find the function fscanf useful.
//Make sure that you close the file with fclose before returning.

int mypow(int base, int exp) {
    if (!exp){
        return 1;
    }
    return base * mypow(base, exp-1);
}

void ReadNum(FILE *fp, uint32_t *p) {
    int sumv = 0;
    int cnt = 0;
    char ch;
    char o[100];
    memset(o, 0, sizeof(o));
    while (1) {
        fscanf(fp, "%c", &ch);
        if (ch == '\n')
            break;
        if (ch == ' ') {
            if (cnt) {
                break;
            }
            continue;
        }
        o[cnt++] = ch;
    }
    for (int i =0; i < cnt; i++) {
        sumv += (int)(o[i]-'0') * (int)(mypow(10,(cnt-i-1)));
    }
    *p = sumv;
    return;
}

//TODO check function with range_max and all pixel
int Read3Nums(FILE *fp, uint32_t *p) {
    int sumv = 0;
    int cnt = 0;
    char ch;
    char o[3];
    int ret;
    while ((ret = fscanf(fp, "%c", &ch))) {
        if (ret == EOF) // end of file
            return 0;
        if (ch == '\n') //end of line
            break;
        if (ch == ' ') {//space 
            if (cnt) {
                break;
            } 
            continue;
        }
        o[cnt++] = ch;
    }
    for (int i =0;i <cnt;i++) {
        sumv += (int)(o[i]-'0')*(int)(mypow(10,(cnt-i-1)));
    }
    *p = sumv;
    
    return 1;
}

Image *readData(char *filename) 
{
    static Image obj;
	//YOUR CODE HERE
    FILE *fp = fopen(filename, "r");
    char f1, f2;
    fscanf(fp, "%c%c \n", &f1, &f2);
    uint32_t w,h;
    ReadNum(fp, &w);
    ReadNum(fp, &h);
    uint32_t range_max;
    ReadNum(fp, &range_max);

    Color **head = (Color **)malloc(sizeof(Color *)*h);
    for (int i =0; i < h; i++) {
        head[i] = (Color *)malloc(sizeof(Color)*w);
    }
    int cnt = 0;
    int ret;
    for (int i = 0;i < h;i++) {
        for (int j = 0;j<w;j++) {
            uint32_t val = 0;
            if(!(ret = Read3Nums(fp, &val)))
                break;
            head[i][j].R = (uint8_t)val;
            if(!(ret = Read3Nums(fp, &val)))
                break;
            head[i][j].G = (uint8_t)val;
            if(!(ret = Read3Nums(fp, &val)))
                break;
            head[i][j].B = (uint8_t)val;
            cnt++;
        }
    }
    
    obj.rows = h;
    obj.cols = w;
    obj.image = head;
    fclose(fp);
    return &obj;

}

//Given an image, prints to stdout (e.g. with printf) a .ppm P3 file with the image's data.
void writeData(Image *image)
{
	//YOUR CODE HERE
    printf("P3\n");
    printf("%u %u\n", image->cols, image->rows);
    printf("255\n");
    
    Color **head = image->image;
    uint32_t h = image->rows, w = image->cols;
    for (int i =0; i <h; i++) {
        for (int j =0; j < w;j++) {
            printf("%3hhu %3hhu %3hhu", head[i][j].R, head[i][j].G, head[i][j].B); 
            if (j!=w-1)
                printf("   ");
        }
        printf("\n");
    }
        return ;
}

//Frees an image
void freeImage(Image *image)
{
    uint32_t h = image->rows;
    Color **head = image->image;
    for (int i = h-1; i >= 0; i--) {
        free(head[i]);
    }
    free(head);
    
    return ;
	//YOUR CODE HERE
}

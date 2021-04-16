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



Image *readData(char *filename) 
{
	//YOUR CODE HERE
    FILE *fp = fopen(filename, "r");
    char *format = NULL;
    fscanf(fp, "%s", format);
    uint32_t w,h;
    fscanf(fp, "%u %u", &w, &h);
    int range_max;
    fscanf(fp, "%d", &range_max);

    uint8_t r,g,b;
    Color *ptr = (Color *)malloc(sizeof(Color));
    MALLOC_CHK(ptr);
    Color **c_head = NULL;
    *c_head = ptr;
    while (scanf("%hhu %hhu %hhu", &r, &g, &b)==3) {
        ptr->R = r;
        ptr->G = g;
        ptr->B = b;
        Color *new_ptr = (Color *)malloc(sizeof(Color));
        MALLOC_CHK(new_ptr);
        ptr->next = new_ptr;
        ptr = new_ptr;
    }
    
    Image *image_ptr = (Image *)malloc(sizeof(Image));
    image_ptr->image = c_head;
    image_ptr->rows = h;
    image_ptr->cols = w;
    fclose(fp);
    return image_ptr;
}

//Given an image, prints to stdout (e.g. with printf) a .ppm P3 file with the image's data.
void writeData(Image *image)
{
	//YOUR CODE HERE
    //printf("P3\n");
    //printf("%u %u\n", image->cols, image->rows);
    //printf("255\n");
    //
    //Color **tmp = image->image;
    //Color *ptr = *tmp;
    //uint8_t widcnt = 0;
    //while (ptr) {
    //    printf("%hhu %hhu %hhu", ptr->R, ptr->G, ptr->B);
    //    widcnt++;
    //    if (widcnt == image->cols) {
    //        widcnt = 0;
    //        printf("\n");
    //    } else {
    //        printf("   ");
    //    }
    //    ptr = ptr->next;
    //}
    //printf("\n");
    return ;
}

//Frees an image
void freeImage(Image *image)
{
    Color **tmp = image->image;
    Color *ptr = *tmp;
    Color *nextptr = ptr->next;
    while (ptr) {
        free(ptr);
        ptr = nextptr;
        nextptr = ptr->next;
    }
    return ;
	//YOUR CODE HERE
}

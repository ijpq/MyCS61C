/************************************************************************
**
** NAME:        imageloader->c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Dan Garcia  -  University of California at Berkeley
**              Copyright (C) Dan Garcia, 2020-> All rights reserved->
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

//Opens a ->ppm P3 image file, and constructs an Image object-> 
//You may find the function fscanf useful->
//Make sure that you close the file with fclose before returning->
Image *readData(char *filename) 
{
	FILE *imageFile = fopen(filename, "r");

	Image *img =(Image*) malloc(sizeof(Image));
	char format[3]; // including "\n"
	int maxColor;

	fscanf(imageFile, "%s", format);
	fscanf(imageFile, "%u %u", &img->cols, &img->rows);
	fscanf(imageFile, "%u", &maxColor);

	int numOfPiexls = img->cols * img->rows; 
	img->image = (Color**) malloc(sizeof(Color*) * numOfPiexls); // allocate memory for all piexls
	int index = 0;
	while(index < numOfPiexls) {
		*(img->image + index) = (Color*) malloc(sizeof(Color)); // allocate memory for color
		Color* piexl = *(img->image + index); // assign the address of each Color to piexl
		fscanf(imageFile, "%hhu %hhu %hhu", &piexl->R, &piexl->G, &piexl->B); //sizeof(unsigned char)
		index++;
	}

	fclose(imageFile);

	return img;
}

//Given an image, prints to stdout (e->g-> with printf) a ->ppm P3 file with the image's data->
void writeData(Image *image)
{
	char *format = "P3";
	int rows = image->rows;
	int cols = image->cols;

	printf("%s\n", format);
	printf("%d %d\n", cols, rows);
	printf("%d\n", 255);

	Color** ppm = image->image;	
	for (int i = 0; i < cols; i++) {
		for (int j = 0; j < rows - 1; j++) {
			// 要输出的字符的最小数目。如果输出的值短于该数，结果会用空格填充。如果输出的值长于该数，结果不会被截断。
			printf("%3hhu %3hhu %3hhu   ", (*ppm)->R, (*ppm)->G, (*ppm)->B); 
			ppm++;
		}
		printf("%3hhu %3hhu %3hhu\n", (*ppm)->R, (*ppm)->G, (*ppm)->B);
		ppm++;
	}

}

//Frees an image
void freeImage(Image *image)
{
	int piexls = image->rows * image->cols;
	for (int i = 0; i < piexls; i++) {
		free(*(image->image + i));
	}
	free(image->image);
	free(image);
}
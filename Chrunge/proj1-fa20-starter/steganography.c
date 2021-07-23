/************************************************************************
**
** NAME:        steganography.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Dan Garcia  -  University of California at Berkeley
**              Copyright (C) Dan Garcia, 2020. All rights reserved.
**				Justin Yokota - Starter Code
**				YOUR NAME HERE
**
** DATE:        2020-08-23
**
**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include "imageloader.h"

//Determines what color the cell at the given row/col should be. This should not affect Image, and should allocate space for a new Color.
Color *evaluateOnePixel(Image *image, int row, int col)
{
	Color* color = (Color*) malloc(sizeof(Color));
	int num = col + row * (image->cols); //Caution
	
	char LSB = image->image[num]->B & 1;
	color->R = color->G = color->B = LSB * 255;
	return color;
}

//Given an image, creates a new image extracting the LSB of the B channel.
Image *steganography(Image *image)
{
	Image *newImg = (Image*) malloc(sizeof(Image));
	int rows = image->rows;
	int cols = image->cols;

	newImg->cols = cols;
	newImg->rows = rows;
	newImg->image = (Color**) malloc(rows * cols * sizeof(Color*)); //为Color*分配内存，不是Color
	Color** piexls = newImg->image;
	for (int row = 0; row < rows; row++){
		for (int col = 0; col < cols; col++) {
			*piexls = evaluateOnePixel(image, row, col);
			piexls++;
		}
	}
	return newImg;
}

/*
Loads a file of ppm P3 format from a file, and prints to stdout (e.g. with printf) a new image, 
where each pixel is black if the LSB of the B channel is 0, 
and white if the LSB of the B channel is 1.

argc stores the number of arguments.
argv stores a list of arguments. Here is the expected input:
argv[0] will store the name of the program (this happens automatically).
argv[1] should contain a filename, containing a file of ppm P3 format (not necessarily with .ppm file extension).
If the input is not correct, a malloc fails, or any other error occurs, you should exit with code -1.
Otherwise, you should return from main with code 0.
Make sure to free all memory before returning!
*/
int main(int argc, char **argv)
{
	if (argc != 2) {
		printf("Something wrong in your argument %s", argv[1]);
		return -1;
	}
	Image* img = readData(argv[1]);
	Image* decoded = steganography(img);

	writeData(decoded);
	freeImage(img);
	freeImage(decoded);
	return 0;
}

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
    Color pixel = image->image[row][col];
    static Color ret_pixel;
    // Color *ret_pixel = malloc(sizeof(Color));
    int rightmostbit = pixel.B & 0x01;
    int val = 0;
    if (rightmostbit)
        val = 255;
    ret_pixel.R = val;
    ret_pixel.B = val;
    ret_pixel.B = val;
    return &ret_pixel;
	//YOUR CODE HERE
}

//Given an image, creates a new image extracting the LSB of the B channel.
Image *steganography(Image *image)
{
    static Image newimg;
    int row = image->rows;
    int col = image->cols;
    Color **head = malloc(sizeof(Color *)*row);
    for (int i =0; i < row;i++)
        head[i] = malloc(sizeof(Color)*col);

    for (int i =0; i < row;i++) {
        for (int j =0; j< col;j++) {
            head[i][j] = *(evaluateOnePixel(image, i, j)); 
        }
    }

    newimg.image = head;
    newimg.rows=row;
    newimg.cols=col;
    
    freeImage(image); // free the space of old image
    return &newimg;
	//YOUR CODE HERE
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
    if (argc != 2)
        exit(-1);
    char *filename = argv[1];
    FILE *fp = fopen(filename, "r");
    if (!fp)
        exit(-1);
    Image *ori_img = readData(filename);
    Image *new_img = steganography(ori_img);
    writeData(new_img);
    freeImage(new_img); // free new image
    return 0;
	//YOUR CODE HERE
}

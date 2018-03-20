// Raz Shenkman, 311130777

/*
 * i created macros instead of using functions, since it saves running time (more efficient than functions).
 */
#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))
#define calcIndex(i, j, n) ((i)*(n)+(j))
#define nineTimes(a)    (((a) << 3) + (a))

typedef struct {
    unsigned char red;
    unsigned char green;
    unsigned char blue;
} pixel;

/**
 *  This function blurs the image. I don't need to pass any more values since I know the kernel scale for
 *  this function and also the kernel size.
 * @param image- inputted image to blur.
 */
void applyBlurKernel(Image *image) {
    int i, j, iMinusOne, redSum, greenSum, blueSum, alloc, dim;
    // the local pixel we will use to store values.
    pixel current_pixel;

    dim = m - 1;
    // Saves time by remembering m*n*3 in a local value.
    alloc = m * n * 3;
    pixel *dst = malloc(alloc);
    /**
     *  Casting the image data to pixel* instead of using the given functions, the Image has a field data which is
     *  char* (in readBMP.h so I cast the char* to pixel*).
     */
    pixel *src = (pixel *) image->data;
    // Copying the bits 1 by 1 by memcpy.
    memcpy(dst, src, alloc);

    /**
     * Scanning the picture like a two-dimensional array. the picture is an array of pixels (which also can be viewed
     * as lines and after the first line starts all the elements in the line are appearing).
     * (starting from the second line to the one before last column).
     */
    for (i = 1; i < dim; ++i) {
        iMinusOne = i - 1;
        for (j = 1; j < dim; j++) {
            /**
             * Creating the 3x3 matrix so I can calculate all the elements inside it.
             */
            // first line in the matrix
            pixel *pixel1 = &dst[calcIndex(iMinusOne, j - 1, m)];
            pixel *pixel2 = pixel1 + 1;
            pixel *pixel3 = pixel1 + 2;
            // second line in the matrix
            pixel *pixel4 = pixel1 + m;
            pixel *pixel5 = pixel4 + 1;
            pixel *pixel6 = pixel4 + 2;
            // third line in the matrix
            pixel *pixel7 = pixel4 + m;
            pixel *pixel8 = pixel7 + 1;
            pixel *pixel9 = pixel7 + 2;

            /**
             * Summing of all the fields of the 3x3 matrix, in blurring we multiply every element by 1
             */
            redSum = ((int) pixel1->red + (int) pixel2->red + (int) pixel3->red + (int) pixel4->red +
                      (int) pixel5->red + (int) pixel6->red + (int) pixel7->red + (int) pixel8->red +
                      (int) pixel9->red);
            greenSum = ((int) pixel1->green + (int) pixel2->green + (int) pixel3->green + (int) pixel4->green +
                        (int) pixel5->green + (int) pixel6->green + (int) pixel7->green + (int) pixel8->green +
                        (int) pixel9->green);
            blueSum = ((int) pixel1->blue + (int) pixel2->blue + (int) pixel3->blue + (int) pixel4->blue +
                       (int) pixel5->blue + (int) pixel6->blue + (int) pixel7->blue + (int) pixel8->blue +
                       (int) pixel9->blue);

            /**
             * I don't need to calculate max between the sum and 0 since in blur all multiplications are positive,
             * I can just pick the minimum value to make sure the pixel color doesn't go higher than 255.
             */
            current_pixel.red = (unsigned char) (min(redSum / 9, 255));
            current_pixel.green = (unsigned char) (min(greenSum / 9, 255));
            current_pixel.blue = (unsigned char) (min(blueSum / 9, 255));
            // Replace the original pixel with the new blurred pixel.
            src[calcIndex(i, j, m)] = current_pixel;
        }
    }
    free(dst);
}


/**
 *  This function sharps the image. I don't need to pass any more values since I know the kernel scale for
 *  this function and also the kernel size.
 * @param image- inputted image to blur.
 */
void applySharpenKernel(Image *image) {
    int i, j, iMinusOne, iPlusOne, redSum, greenSum, blueSum, alloc, dim;
    // the local pixel we will use to store values.
    pixel current_pixel;

    dim = m - 1;
    // Saves time by remembering m*n*3 in a local value.
    alloc = m * n * 3;
    pixel *dst = malloc(alloc);
    pixel *src = (pixel *) image->data;
    /**
     *  Casting the image data to pixel* instead of using the given functions, the Image has a field data which is
     *  char* (in readBMP.h so I cast the char* to pixel*).
     */
    memcpy(dst, src, alloc);

    /**
     * Scanning the picture like a two-dimensional array. the picture is an array of pixels (which also can be viewed
     * as lines and after the first line starts all the elements in the line are appearing).
     * (starting from the second line to the one before last column).
     */
    for (i = 1; i < dim; ++i) {
        iMinusOne = i - 1;
        iPlusOne = i + 1;
        for (j = 1; j < dim; ++j) {
            /**
             * Creating the 3x3 matrix so I can calculate all the elements inside it.
             */
            // first line in the matrix
            pixel *pixel1 = &dst[calcIndex(iMinusOne, j - 1, m)];
            pixel *pixel2 = pixel1 + 1;
            pixel *pixel3 = pixel1 + 2;
            // second line in the matrix
            pixel *pixel4 = pixel1 + m;
            pixel *pixel5 = pixel4 + 1;
            pixel *pixel6 = pixel4 + 2;
            // third line in the matrix
            pixel *pixel7 = pixel4 + m;
            pixel *pixel8 = pixel7 + 1;
            pixel *pixel9 = pixel7 + 2;

            /**
             * Summing of all the fields of the 3x3 matrix, in sharping we multiply index [2][2] by 9 and all
             * the others by (-1).
             */
            redSum = (int) nineTimes(pixel5->red) + (-1) * ((int) pixel1->red + (int) pixel2->red + (int) pixel3->red +
                                                            (int) pixel4->red + (int) pixel6->red + (int) pixel7->red +
                                                            (int) pixel8->red + (int) pixel9->red);

            greenSum = (int) nineTimes(pixel5->green) + (-1) * ((int) pixel1->green + (int) pixel2->green +
                                                                (int) pixel3->green + (int) pixel4->green +
                                                                (int) pixel6->green + (int) pixel7->green +
                                                                (int) pixel8->green + (int) pixel9->green);

            blueSum = (int) nineTimes(pixel5->blue) + (-1) * ((int) pixel1->blue + (int) pixel2->blue +
                                                              (int) pixel3->blue + (int) pixel4->blue +
                                                              (int) pixel6->blue + (int) pixel7->blue +
                                                              (int) pixel8->blue + (int) pixel9->blue);

            current_pixel.red = (unsigned char) min(max(redSum, 0), 255);
            current_pixel.green = (unsigned char) min(max(greenSum, 0), 255);
            current_pixel.blue = (unsigned char) min(max(blueSum, 0), 255);
            // Replace the original pixel with the new blurred pixel.
            src[calcIndex(i, j, m)] = current_pixel;
        }
    }
    free(dst);
}


void myfunction(Image *image, char *srcImgpName, char *blurRsltImgName, char *sharpRsltImgName) {
    /**
     * I combined all the functions of creating a copy of the image and blurring it into one function.
     * Since passing arguments between functions takes time and space.
     */
    applyBlurKernel(image);

    // write result image to file
    writeBMP(image, srcImgpName, blurRsltImgName);

    /**
     * I combined all the functions of creating a copy of the image and sharping it into one function.
     * Since passing arguments between functions takes time and space.
     */
    applySharpenKernel(image);

    // write result image to file
    writeBMP(image, srcImgpName, sharpRsltImgName);
}

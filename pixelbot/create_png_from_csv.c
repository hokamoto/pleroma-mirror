// CSV to PNG, based on:
/*
 * A simple libpng example program
 * http://zarb.org/~gc/html/libpng.html
 *
 * Modified by Yoshimasa Niwa to make it much simpler
 * and support all defined color_type.
 *
 * To build, use the next instruction on OS X.
 * $ brew install libpng
 * $ clang -lz -lpng15 libpng_test.c
 *
 * Copyright 2002-2010 Guillaume Cottenceau.
 *
 * This software may be freely redistributed under the terms
 * of the X11 license.
 *
 */
// This code Copyright 2017 Wim Vanderbauwhede
#include <stdlib.h>
#include <stdio.h>
#include <png.h>

int width, height;
png_byte color_type;
png_byte bit_depth;
png_bytep *row_pointers;

void prepare_png(int* width, int* height) {

// Allocate space 
  row_pointers = (png_bytep*)malloc(sizeof(png_bytep) * (*height));
  for(int y = 0; y < (*height); y++) {
    row_pointers[y] = (png_byte*)malloc(sizeof(png_bytep) * (*width) * 4 ); // XXX RGBA XXX
  }

}


void  read_csv_file(const char* filename, unsigned char csv_store[],int* ncols, int* nrows) {
    FILE * fp;
    int c='*';

    fp=fopen (filename,"r");
    if (fp==NULL) {
        perror ("Error opening file");
    } else {
        int i=0;
        (*nrows)++;
        do {
            c = fgetc(fp);
            if (c=='\n') {
                *ncols=0;
                (*nrows)++;
            }
            if (c != ',' && c!= '\n' && c!=EOF) {
                //printf("%d %d\n",i,c);
                csv_store[i]=c;
                i++;
                (*ncols)++;
            }
        } while (c != EOF);
        
        fclose (fp);
    }
}


void write_png_file(const char *filename) {

  FILE *fp = fopen(filename, "wb");
  if(!fp) abort();

  png_structp png = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
  if (!png) abort();

  png_infop info = png_create_info_struct(png);
  if (!info) abort();

  if (setjmp(png_jmpbuf(png))) abort();

  png_init_io(png, fp);

  // Output is 8bit depth, RGBA format.
  png_set_IHDR(
    png,
    info,
    width, height,
    8,
    PNG_COLOR_TYPE_RGBA,
    PNG_INTERLACE_NONE,
    PNG_COMPRESSION_TYPE_DEFAULT,
    PNG_FILTER_TYPE_DEFAULT
  );
  png_write_info(png, info);

  // To remove the alpha channel for PNG_COLOR_TYPE_RGB format,
  // Use png_set_filler().
  //png_set_filler(png, 0, PNG_FILLER_AFTER);

  png_write_image(png, row_pointers);
  png_write_end(png, NULL);

  for(int y = 0; y < height; y++) {
    free(row_pointers[y]);
  }
  free(row_pointers);

  fclose(fp);
}

void populate_png_from_csv(int* ncols, int* nrows, unsigned char* csv_store) {
    for(int i=0;i<*nrows;i++) {
        for(int j=0;j<*ncols;j++) {
            int color = csv_store[j+*ncols*i] - 48; // now this has to go to 0 or 255 for R/G/B and 255 for A
            //printf("%d %d %d\n",i,j,color);
            row_pointers[j][i*4+0]=255*(color & 4);
            row_pointers[j][i*4+1]=255*(color & 2);
            row_pointers[j][i*4+2]=255*(color & 1);
            row_pointers[j][i*4+3]=255;
        }
    }
    //free(csv_store);
}

void populate_scaled_png_from_csv(int* ncols, int* nrows, int width, int height, unsigned char* csv_store) {
    for(int i=0;i<*nrows;i++) {
      for(int ii =0;ii<height/(*nrows);ii++) {
        for(int j=0;j<*ncols;j++) {
            int color = csv_store[j+*ncols*i] - 48; // now this has to go to 0 or 255 for R/G/B and 255 for A
            //printf("%d %d %d\n",i,j,color);
            for(int jj=0;jj<width/(*ncols);jj++){
            //printf("%d %d %d\n",i*width/(*ncols)+ii,j*height/(*nrows)+jj,color);
            row_pointers[j*height/(*nrows)+jj][(i*width/(*ncols)+ii)*4+0]=255*(color & 4);
            row_pointers[j*height/(*nrows)+jj][(i*width/(*ncols)+ii)*4+1]=255*(color & 2);
            row_pointers[j*height/(*nrows)+jj][(i*width/(*ncols)+ii)*4+2]=255*(color & 1);
            row_pointers[j*height/(*nrows)+jj][(i*width/(*ncols)+ii)*4+3]=255*(color );
            }
        }
    }
    }
}

int main(int argc, char *argv[]) {

  const char* csv_file=CSV_PATH;//"/home/pleroma/pleroma/pixelbot/canvas.csv";
  const char* png_file=PNG_PATH;//"/home/pleroma/pleroma/priv/static/pixelbot/canvas.png";
  const char* png512_file=PNG512_PATH;//"/home/pleroma/pleroma/priv/static/pixelbot/canvas_512x512.png";

  unsigned char* csv_store=(unsigned char*)malloc(512*512) ; // XXX could be better XXX
  int ncols[1]={0};
  int nrows[1]={0};
  read_csv_file(csv_file,csv_store,ncols,nrows);
  //printf("%d %d\n",*nrows,*ncols);
  width = *ncols;
  height = *nrows;
  prepare_png(&width,&height);
  populate_png_from_csv(ncols,nrows,csv_store);
  write_png_file(png_file);

  width=512;
  height=512;
  prepare_png(&width,&height);
  populate_scaled_png_from_csv(ncols,nrows,width,height,csv_store);
  write_png_file(png512_file);

  free(csv_store);

  return 0;
}

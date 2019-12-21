#include<stdio.h>
#include<opencv2/core/core.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<iostream>

#define T 16
#define VISIBILITY 70 // watermark transparency level

using namespace cv;
using namespace std;

__global__ void addwatermark(unsigned char *pic, unsigned char *mark, int h_pic, int w_pic, int h_mark, int w_mark){
	//as each global threadid number
	int x = blockIdx.x * blockDim.x + threadIdx.x;
	int y = blockIdx.y * blockDim.y + threadIdx.y;

	//finding each thread pixel to calculation
	int in_m = y * w_mark + x;
	//prevent pixel of thread that out of mark boundary to calculate
	int in_p = (h_pic - h_mark + y) * w_pic + x;

	//if that pixel is in watermark boundary
	if((x<w_mark)&&(y<h_mark))
	{
		if(mark[in_m*3]==0 && mark[in_m*3+1]==0 && mark[in_m*3+2]==0)
		{
			//do nothing png will be transparent
		}
		else
		{	//if there is color inside finding each B,G,R and blend it with picture that we want
			//*0.01 to convert 100% that multiply back to normal range
			pic[in_p*3] = ((pic[in_p*3]*VISIBILITY)+(mark[in_m*3]*(100-VISIBILITY)))*0.01;
			pic[in_p*3+1] = ((pic[in_p*3+1]*VISIBILITY)+(mark[in_m*3+1]*(100-VISIBILITY)))*0.01;
			pic[in_p*3+2] = ((pic[in_p*3+2]*VISIBILITY)+(mark[in_m*3+2]*(100-VISIBILITY)))*0.01;
		}
	}
}

int main(int argc, char* argv[]){
	// load both image and watermark
	Mat img_pic = imread(argv[1], IMREAD_COLOR);
	Mat img_mark = imread(argv[2], IMREAD_COLOR);

	//checking for prevent that watermrk will be bigger and can't fit in
	if(img_pic.rows < img_mark.rows || img_pic.cols < img_mark.cols )
	{
		cout <<  "Size of watermark is bigger than wallpaper" << endl;
        	return -1;
	}

	// show Original Image
	//imshow("Original", img_pic);

	// convert datatype of image from Mat to unsigned char
	unsigned char *in_pic = (unsigned char*)(img_pic.data);
	unsigned char *in_mark = (unsigned char*)(img_mark.data);

	// allocate global memory space in GPU for using according to rows and column
	int size_pic = sizeof(char) * 3 * img_pic.rows * img_pic.cols;
	int size_mark = sizeof(char) * 3 * img_mark.rows * img_mark.cols;

	unsigned char *dev_pic, *dev_mark;
	
	cudaMalloc( (void**)&dev_pic, size_pic);
	cudaMalloc( (void**)&dev_mark, size_mark);

	// copy data from cpu to gpu
	cudaMemcpy( dev_pic, in_pic, size_pic, cudaMemcpyHostToDevice);
	cudaMemcpy( dev_mark, in_mark, size_mark, cudaMemcpyHostToDevice);

	// set number of thread and block to use
	dim3 dimblock(T, T);
	dim3 dimgrid((img_mark.cols + dimblock.x - 1)/dimblock.x, (img_mark.rows + dimblock.y - 1)/dimblock.y);

	// call kernel routine send row column and pic
	addwatermark<<<dimgrid, dimblock>>>(dev_pic, dev_mark, img_pic.rows, img_pic.cols, img_mark.rows, img_mark.cols);

	// copy back after calculation from GPU to CPU
	cudaMemcpy( in_pic, dev_pic, size_pic, cudaMemcpyDeviceToHost);

	// convert datatype back to print out unsigned char to Mat
	Mat out =  Mat(img_pic.rows, img_pic.cols, CV_8UC3, in_pic);

	// free memory space in GPU
	cudaFree(dev_pic);
	cudaFree(dev_mark);

	// write image
	imwrite("output.jpg", out);
	//imshow("Modified", img_output);

	//displays the image for specified milliseconds
	waitKey();

	return 0;
}
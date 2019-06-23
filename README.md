# SIFT
Pure Matlab implementation of SIFT keypoint Detection, Extraction and Matching

# Usage:
% load image<br/>
I = imread('cameraman.tif');

% extract SIFT frames and descriptor<br/>
[f, d] = SIFT(I);

% plot frames<br/>
plot_descriptor(I, f)

 ![SIFT_frames](SIFT_frames.jpg)

# Recommendation: 
A deep explantion about SIFT can be found on<br/>
Anatomy of the SIFT Method "http://www.ipol.im/pub/art/2014/82/article.pdf"

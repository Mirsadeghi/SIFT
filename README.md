# SIFT
Pure Matlab implementation of SIFT keypoint Detection, Extraction and Matching

# Usage:
I = imread('cameraman.tif');
[f, d] = SIFT(I);
plot_descriptor(I, f)

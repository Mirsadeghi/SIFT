# SIFT
Pure Matlab implementation of SIFT keypoint Detection, Extraction and Matching

# Usage:

% load image
I = imread('cameraman.tif');

% extract SIFT frames and descriptor
[f, d] = SIFT(I);

% plot frames
plot_descriptor(I, f)

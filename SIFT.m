function [f,d] = SIFT(I)
%SIFT extract SIFT from input image
% This function accept doubled format image and return SIFT frame and
% descriptor in the output. SIFT extraction is done by pre-defined
% parameters according to the G.D.Lowe SIFT paper.
% 
% Add address of SIFT extraction functions to the MATLAB search path.
% 
% addpath(genpath([pwd '\SIFT\']))
% addpath(genpath([pwd '\Other\']))
% addpath(genpath([pwd '\Visualization\']))
% 
% usage:
%       [f,d] = SIFT(I)
% input:
%       I - input image (rgb or graysacel)
% outputs:
%       f - frame in format [x y scale orientation]
%       d - 128-d sift descriptor
% example:
%       I = imread('cameraman.tif');
%       [f, d] = SIFT(I);
%       plot_descriptor(I, f)

%% Scale Space analysis parameters
% -------------------------------------------------------------------------
% number of scales in each octaves
param.s = 3;
% initial standard deviation for first octave
param.sigma0 = 1;
% standard deviation of gaussian kernel
param.sigma = 1.6;
% 1st octave index. nagative value means up-ampled image for first octave
param.stOct = 0;
% number of octaves
param.numOct = 4;
% Kernel size of gaussian smoothing function for scale space analysis
param.KernelSz = [15 15];

%% Orientation Assignment parameters
% -------------------------------------------------------------------------
% number of bins for computing dominate orientation
param.nbin = 36;

% control flag to fit parabola into dominate orientation histogram for
% better accuracy
param.AccurateAngle = 'true';

% extracting method for computing dominate orientation
% circular window is very time consuming but it results is very similar to
% rectangular window
% param.WinType = 'circ';
param.WinType = 'rect';

% control flag to find multiple keypoint with different orientation in
% single location.
param.dupKey = 'true';

%% Parameters for Rejecting Unstable keypoints
% -------------------------------------------------------------------------
% threshold for rejecting low contrast keypoints in the DoG domain
param.DoGTresh = 0.007;

% Threshold for eliminating keypoints which are located on the edges.
r = 10;
param.EdgeTresh = ((r+1)^2)/r;

%% Descriptor extarction parameters
% -------------------------------------------------------------------------
% size of descriptor
param.CellSize = 4;

% X : number of blocks
X = 2;
param.WinSize = (param.CellSize*X)*2;

% Gaussian weighting function for building decsriptor
param.DescKernel = BuildKernel(param.WinSize/2,[param.WinSize param.WinSize]+1);

% number of bins for computing descriptor of each block
param.hbin = 8;

%% Other
% -------------------------------------------------------------------------
% show results
param.show = 'true';

if size(I,3)>1
    I = rgb2gray(I);
end

%% Extract SIFT
% -------------------------------------------------------------------------
% normalize intensity of image into range [0,1]
I = double(I);
I = I/max(I(:));

% extract SIFT feature from input image
[temp,~] = SIFT_Extractor(I,param);
f = temp.frame([2 1 3 4], :);
d = temp.desc;

end
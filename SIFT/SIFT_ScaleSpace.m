function SS = SIFT_ScaleSpace(I,param)
%Do Scale SPace analysis on the input image
% This function is written to apply Scale-Space analysis into input image.
% Scale-Space analysis is consist of smoothing input image incrementaly
% with gaussian filter and compute difference of gaussian image by simple
% subtraction.
% All the steps are followed by original SIFT paper "Distinctive Image Features
% from Scale-Invariant Keypoints" by David G. Lowe, International Journal
% of Computer Vision, 2004.
%
%
% Syntax:
%         SS = SIFT_ScaleSpace(I,param)
% Inputs:
%         I     - doubled format 2-dimensional image
%         param - parameter for Scale-Space analysis
%                 param.s           : parameter which define "numScale" and "k"
%                 param.numOct      : number of octaves
%                 param.stOct       : index of first octave
%                 param.sigma       : initial standard deviation of gaussian kernels
%                 param.kernelSz    : size of gaussian kernels
%                 param.show        : show process images
% Outputs:
%          SS   - processed images
%                 SS.GuS    : Gaussian filtered images
%                 SS.DoG    : Difference of Gaussian images
%                 SS.GuSimg : All Gaussian images in single images
%                 SS.DoGimg : All DoG images in single images
%
% Example:
%       I = imread('cameraman.tif');
%       I = double(I);
%       param.s = 2;
%       param.sigma = 1.6;
%       param.stOct = -1;
%       param.numOct = 4;
%       param.show = 'true';
%       param.KernelSz = [15 15];
%       SS = ScaleSpace(I,param);
%
% -------------------------------
% Written by : S.Ehsan Mirsadeghi
% Date       : April 2015

% input image must have double format data

% parameter which define "numScale" and "k"
s = param.s;

% number of scales in each octave
numScale = s + 3;

% number of octaves
numOctave = param.numOct;

% first octave
startOctave = param.stOct;

% initial standard deviation of gaussian kernels
sigma = param.sigma;

% power of standard deviation coefficient "k"
co = 0 : numScale-1;

% differences in scale
k = 2 .^ (co/s);

% size of gaussian kernels
KernelSize = param.KernelSz;

% pre-allocation
DoGimg = cell(numOctave,numScale-1);
GuSimg = cell(1,numScale-1);
kGuS = cell(numOctave,numScale);
It = cell(1,numOctave);

% build image of fisrt octave
It{1} = imresize(I,2^abs(startOctave));
% Pre-smoothing image of first octave by "sigma0"
k0 = BuildKernel(param.sigma0,KernelSize);
It{1} = imfilter(It{1},k0,'same');

% It{1} = imfilter(It{1},BuildKernel(0.5,[15 15]),'same');

% sigma2 = sigma * 2.^(0:numOctave-1);
sigma1 = (sigma * 2.^(0:numOctave-1))'*k;

for i = 1 : numOctave
    for j = 1 : numScale
        
        % Build DoG kernel
        % sigma2 = sigma*k(j-1);
        % kDoG = BuildKernel(sigma1,KernelSize) - BuildKernel(sigma2,KernelSize);
        % kDoG = kDoG ./ (sum(kDoG(:) + eps));
        % Compute Difference of Gaussian images
        % DoGimg{i,j-1} =  imfilter(I{i},kDoG,'same');
        
        % Build Gaussian Kernel
        % sigma1 = sigma*k(j);
        kGuS{i,j} = BuildKernel(sigma1(i,j),KernelSize);
        
        % Compute smoothed image with gaussian kernels
        GuSimg{i,j} = imfilter(It{i},kGuS{i,j},'same');
        
        % Compute DoG images by simple subtraction
        if j > 1
            DoGimg{i,j-1} =  GuSimg{i,j} - GuSimg{i,j-1};
        end
    end
    % resample image for next Octave by taking every second pixel in each
    % row and column.
    if i < numOctave
        % It{i+1} = imresize(It{i},0.5);
        It{i+1} = It{i}(1:2:end,1:2:end);
    end
end

% store data in the structured variable
SS.GuS = GuSimg;
SS.DoG = DoGimg;
SS.kGuS = kGuS;
SS.I = It;

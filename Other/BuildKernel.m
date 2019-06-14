function k = BuildKernel(Sigma,KernelSize)
% This is a local function to build guassian kernels with specified 
% Sigma and Kernel Size.
%
% Syntax:
%         k = BuildKernel(Sigma,KernelSize)
% Inputs:
%         Sigma      - standard deviation of gaussian kernel
%         KernelSize - size of gaussian kernels
%
% Outputs:
%         k          - Gaussian Kernel
%
% -------------------------------
% Written by : S.Ehsan Mirsadeghi
% Date       : April 2015

K = KernelSize / 2;
co = 2*(Sigma^2);

% Build grid for gaussian kernel
[XX,YY] = meshgrid(-floor(K(1)):floor(K(1)),...
                   -floor(K(2)):floor(K(2)));

% apply gaussian function to the grid               
k = (1 / (pi*co) )*(exp(-((XX.^2) + (YY.^2) ) / co));

% normalize values to have "sum(k) = 1".
k = k./(sum(k(:))+eps);
end
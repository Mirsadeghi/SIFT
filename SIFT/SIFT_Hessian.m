function H = SIFT_Hessian(I)
%Hessian criteria for removing unsatable Keypoints
% This function is written to compute Hessian matrix of input image.
%
% Syntax:
%         H = SIFT_Hessian(I)
% Inputs:
%         I     - doubled format 2-dimensional image
% Outputs:
%         H     - structured variable which contains
%                 H.Dxx : 2nd order derv in x-direction
%                 H.Dyy : 2nd order derv in y-direction
%                 H.Dxy : 2nd order derv in xy-direction
% 
% -------------------------------
% Written by : S.Ehsan Mirsadeghi
% Date       : April 2015

% Length of pixel shift
L = 1;

% Left       shfited image
Il  = [I(:,L+1:end) I(:,1:L)];

% 2 pixel - Left       shfited image
I2l  = [I(:,L+2:end) I(:,1:L+1)];

% Up      shfited image
Iu  = [I(L+1:end,:);I(1:L,:)];

% 2 pixel - Up      shfited image
I2u  = [I(L+2:end,:);I(1:L+1,:)];

% Second order derivative in x and y axis
% 1D kernel = [1 -2 1];
H.Dxx = I - 2*Il + I2l;
H.Dyy = I - 2*Iu + I2u;

% first order derivative in x axis
% 1D kernel = [-1 1];
Dx = Il - I;

% Down shifted 'Dx' for computing Dxy
Dxd  = [Dx(end-L+1:end,:);Dx(1:end-L,:)];
H.Dxy = Dxd - Dx;
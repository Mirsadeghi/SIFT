function [GradMag,GradAngle] = compute_gradient(I)
% This is a local function to compute gradient magnitude and orientation of
% input image. This function use following approximation:
% Approximate image derivation as:
%           dI/dx = dI(x+1) - dI(x-1)
%           Equivalent Derivative Kernel : [-1  0 +1]
%
% Syntax:
%         [GradMag,GradAngle] = compute_gradient(I)
% Inputs:
%         I         - Input image (double format)
%
% Outputs:
%         GradMag   - Gradient magnitude 
%         GradAngle - Gradient angle
%
% -------------------------------
% Written by : S.Ehsan Mirsadeghi
% Date       : April 2015

% Build Shifted Images.
Il = [I(:,2:end) I(:,1)];     % Left  shfited image
%Ir = [I(:,end) I(:,1:end-1)]; % Right shfited image
Iu = [I(2:end,:);I(1,:)];     % Up    shfited image
%Id = [I(end,:);I(1:end-1,:)]; % Down  shfited image

% Compute difference
Dx = (Il - I);
Dy = (Iu - I);

% Compute magnitude of gradient.
GradMag = sqrt((Dx).^2 + (Dy).^2);

% Compute orientation of gradient in the range [0-360]
GradAngle = atan2d(Dx,Dy)+180;
end
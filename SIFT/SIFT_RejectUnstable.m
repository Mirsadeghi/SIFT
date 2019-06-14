function Idx = SIFT_RejectUnstable(DoGimg,Idx,param)
%Apply all filters for rejecting unstable Keypoints
% This function is written to filter unstable keypoints by rejecting low
% contrast candidate in the DoG domain and edge keypoints by Hessian
% matrix.
%
% Syntax:
%         Idx = SIFT_RejectUnstable(DoGimg,Idx,param)
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

%
% -------------------------------------------------------------------------
% Reject low contrast keypoints by thresholding DoG value
% against defined threshold and pass other keypoints
% -------------------------------------------------------------------------
Idx1 = abs(DoGimg) >= param.DoGTresh;

% -------------------------------------------------------------------------
% Eliminate edge response by Hessian matrix
% -------------------------------------------------------------------------
H = SIFT_Hessian(DoGimg);
temp = (H.Dxx + H.Dyy).^2 ./ ((H.Dxx.*H.Dyy - (H.Dxy).^2) + eps);
Idx0 = temp < param.EdgeTresh;

% Discard keypoint near the edge of images
Idx2 = (Idx*0) ;
Idx2(param.WinSize+1:end-param.WinSize,...
    param.WinSize+1:end-param.WinSize) = 1;

% Apply all filters to the initial detected keypoints
% Idx  --> exterema detector
% Idx0 --> Edge eliminator (Eigenvalue of Hessian matrix criteria)
% Idx1 --> Low contrast DoG detector
% Idx2 --> near border keypoint detector

Idx = Idx & Idx0 & Idx1 & logical(Idx2);
end
function D = SIFT_Descriptor(Grad,frame,param)
%SIFT Descriptor Extraction
% This function is written to extract SIFT descriptor of Keypoint. SIFT
% Descriptor is a rectangular window centered at the keypoint location.
%
% Syntax:
%         D = SIFT_Descriptor(Grad,frame,param)
% Inputs:
%         Grad  - Gradient image
%                 Grad.Mag   : Gradient Magnitude
%                 Grad.Angle : Gradient Orientation
%         frame - frame of SIFT keypoint : [x,y,scale,orientation]
%         param - parameter for Descriptor
%                 param.DescKernel : Gaussian Weight kernel
%                 param.WinSize    : size of descriptor window
%                 param.CellSize   : size of each cell in the window
%                 param.hbin       : number of bins for local histogram
% Outputs:
%         D     - 128-d Descriptor for each Keypoint
%
% -------------------------------
% Written by : S.Ehsan Mirsadeghi
% Date       : April 2015

% round location of keypoints
frame(1:2,:) = round(frame(1:2,:));
numKey = size(frame,2);

% Extract gradient magnitude and orientation
GradMag = Grad.Mag;
GradAngle = Grad.Angle;

WinSize = (param.WinSize/2);
kGuS = param.DescKernel;
NumLocalHist = (param.WinSize/param.CellSize)^2;

% Pre-allocation
HistOri = zeros(param.hbin,NumLocalHist);
D = zeros(param.hbin*NumLocalHist,numKey);

% build index for fast histogram calculation
OriIdx = repmat(0:360/param.hbin:360,param.CellSize^2,1);

% loop over all keypoints in the current octave and scale
for i = 1 : numKey
    
    % extract pixel index around current Keypoint
    % Rectangle window
    %{
        
        tempImg = GuSimg(frame(1,i)-WinSize-Pad:frame(1,i)+WinSize+Pad,...
            frame(2,i)-WinSize-Pad:frame(2,i)+WinSize+Pad);
        
        % Rotate each keypoint relative to it's dominate orientation
        tempImg = imrotate(tempImg,-frame(4,i));
        [tempMag,tempAngle] = compute_gradient(tempImg);
                cent = ceil(size(tempAngle,1)/2);
        tempMag = tempMag(cent-WinSize:cent+WinSize,...
                             cent-WinSize:cent+WinSize);
        KeyAngle = tempAngle(cent-WinSize:cent+WinSize,...
                             cent-WinSize:cent+WinSize);
        KeyGrad = kGuS.*tempMag;
    %}
    
    % Extract Gradient magnitude around current Keypoint
    tempMag = GradMag(frame(1,i)-WinSize:frame(1,i)+WinSize,...
        frame(2,i)-WinSize:frame(2,i)+WinSize);
    
    % Weight gradient magnitude by gaussian weight kernel
    KeyGrad = kGuS.*tempMag;
    
    % Extract Gradient Angle around current Keypoint
    KeyAngle = GradAngle(frame(1,i)-WinSize:frame(1,i)+WinSize,...
        frame(2,i)-WinSize:frame(2,i)+WinSize);
    
    % Rotate coordinate of the descriptor relative to the keypoint dominate
    % orientation. This is equal to subtracting all gradient orientation
    % aroudn each keypoint by it's diminate orientation.
    
    % This make SIFT Descriptor to be rotation invariant
    % Simple but Clever method!
    KeyAngle = KeyAngle - frame(4,i);
    
    % convert all negative angles into positive
    KeyAngle(KeyAngle < 0) = KeyAngle(KeyAngle < 0) + 360;
    % KeyAngle(KeyAngle==360) = 0;
    
    % Weight orientation gradient by gradient magnitude
    WeightedAngles = KeyGrad.*KeyAngle;
    
    % Discard row and column pixels of keypoint
    WeightedAngles(1+(param.WinSize/2),:) = [];
    WeightedAngles(:,1+(param.WinSize/2)) = [];
    KeyAngle(1+(param.WinSize/2),:) = [];
    KeyAngle(:,1+(param.WinSize/2)) = [];
    
    % reshape local patch for easier computation
    WeightedAngles = reshape(WeightedAngles,param.CellSize,NumLocalHist*param.CellSize);
    KeyAngle = reshape(KeyAngle,param.CellSize,NumLocalHist*param.CellSize);
    
    % build orientation histogram
    for j = 1 : NumLocalHist
        
        % find orientation in the range of current bin
        Patch = KeyAngle(:,(j-1)*param.CellSize+1:(j)*param.CellSize);
        LocalOri = WeightedAngles(:,(j-1)*param.CellSize+1:(j)*param.CellSize);
        
        % compy element for fast calculation
        Patch = repmat(Patch(:),1,param.hbin);
        LocalOri = repmat(LocalOri(:),1,param.hbin);
        
        % compare orientation value for build histogram bins
        Idd = (Patch>=OriIdx(:,1:end-1)) & (Patch<OriIdx(:,2:end));
        
        % sum element of current bin (weighted version of angle)
        HistOri(:,j) = sum(Idd.*LocalOri);
        %HistOri(:,j) = sum(Idd);
    end
    
    % concatenate local histograms to form final Descriptor
    D(:,i) = HistOri(:);
    
    % 1st normalization for descriptor to have "sum(D) = 1"
    D(:,i) = D(:,i)./(sum(D(:,i))+eps);
    
    % Truncation
    D(D(:,i) > 0.2,i) = 0.2;
    
    % 2nd normalization for descriptor to have "sum(D) = 1"    
    D(:,i) = D(:,i)./(sum(D(:,i))+eps);
end
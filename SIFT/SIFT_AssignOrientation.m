function Ori = SIFT_AssignOrientation(Grad,xLoc,yLoc,KeyLoc,param)
% SIFT Orientation Assignment
% This function is written to assign dominate orientation to the Keypoints.
% It accept Gradient magnitude and orientation in the current Octave, Grid
% of image and Keypoint location and return dominate orientation of
% Keypoint. Maximum 4 orientation can be assgined to each Keypoint.
%
%
% Syntax:
%         Ori = SIFT_AssignOrientation(Grad,xLoc,yLoc,KeyLoc,param)
% Inputs:
%         Grad   - Gradient image
%                  Grad.Mag   : Gradient Magnitude
%                  Grad.Angle : Gradient Orientation
%         xLoc   - Grid of x-axis
%         yLoc   - Grid of y-axis
%         KeyLoc - Location Keypoints [x,y]
%         param  - parameter for Assigning Orientation
%                  param.WinType   : type of sampling around Keypoint
%                                    'rect' --> rectangular window
%                                    'circ' --> circular window
%                  param.nbin      : number of bins for histogram
%                  param.kernelSz  : size of gaussian kernels
%
% Outputs:
%         Ori    - Orientation of each Keypoint in the range [0-360]
%
% -------------------------------
% Written by : S.Ehsan Mirsadeghi
% Date       : April 2015

% Extract gradient magnitude and orientation
GradMag = Grad.Mag;
GradAngle = Grad.Angle;

% Number of keypoint in the current octave
numKey = size(KeyLoc,2);

% round location of keypoint
KeyLoc(1:2) = round(KeyLoc(1:2));

% Pre-allocation
Ksize = param.KernelSz;
Ori = zeros(4,numKey);
HistOri = zeros(1,param.nbin);
DupKeypoint = zeros(1,numKey);

% this variables is used in the circular window manner
Rad = param.KernelSz(1);
ZerosImg = (xLoc*0);

% Build gaussian weight kernel with a sigma that is 1.5 time that of
% the scale of the keypoint.
kGuS = BuildKernel(1.5*KeyLoc(3,1),Ksize);

% step size for accurate finding of dominate orientation
ln = 0.1;
AngleCo = 360/param.nbin;

% loop over all keypoints in the current octave and scale
for i = 1 : numKey
    
    % extract pixel index around current Keypoint
    % we compute dominate orientation of keypoint in a circle with radius
    % equal to scale of keypoint around it.
    
    if strcmpi(param.WinType,'circ')
        % Circular window
        Index = (xLoc-KeyLoc(1,i)).^2 + (yLoc-KeyLoc(2,i)).^2 <= Rad;
        
        GusKernel = ZerosImg;
        GusKernel(KeyLoc(1,i)-floor(Ksize(1)/2):KeyLoc(1,i)+floor(Ksize(1)/2),...
            KeyLoc(2,i)-floor(Ksize(2)/2):KeyLoc(2,i)+floor(Ksize(2)/2)) = kGuS;
        
        % Weight Magnitude of Gradient by gaussian window
        tempMag = GusKernel .* GradMag;
        
        % Weight Orientation of Gradient by Magnitude of Gradient weight
        KeyGrad = tempMag(Index);
        KeyAngle = GradAngle(Index);
        
    elseif strcmpi(param.WinType,'rect')
        % Rectangle window
        tempMag = GradMag(KeyLoc(1,i)-floor(Ksize(1)/2):KeyLoc(1,i)+floor(Ksize(1)/2),...
            KeyLoc(2,i)-floor(Ksize(2)/2):KeyLoc(2,i)+floor(Ksize(2)/2));
        KeyGrad = kGuS(:).*tempMag(:);
        KeyAngle = GradAngle(KeyLoc(1,i)-floor(Ksize(1)/2):KeyLoc(1,i)+floor(Ksize(1)/2),...
            KeyLoc(2,i)-floor(Ksize(2)/2):KeyLoc(2,i)+floor(Ksize(2)/2));
        KeyAngle = KeyAngle(:);
    end
    
    % Weight orientation gradient by gradient magnitude
    WeightedAngles = KeyGrad.*KeyAngle;
    
    % build orientation histogram
    for j = 1 : param.nbin
        
        % find orientation in the range of current bin
        Id = (KeyAngle >= (j-1)*AngleCo) & (KeyAngle < (j)*AngleCo);
        
        % sum element of current bin (weighted version of angle)
        HistOri(j) = sum(WeightedAngles(Id));
    end
    
    % Find peak of orientation histogram
    [val,idx] = max(HistOri);
    
    if strcmpi(param.AccurateAngle,'true')
        % Fit a parabola into samples around maximum element of histogram for
        % better accuracy
        if idx == param.nbin
            l = [idx-1 , idx];
            p = polyfit(l,HistOri(l),2);
            Xdur = l(1):ln:l(end);
        elseif idx == 1
            l = [idx , idx+1];
            p = polyfit(l,HistOri(l),2);
            Xdur = l(1):ln:l(end);
        else
            p = polyfit([idx-1 , idx , idx+1],HistOri([idx-1 , idx , idx+1]),2);
            Xdur = idx-1:0.1:idx+1;
        end
        pt = polyval(p,Xdur);
        [~,id] = max(pt);
        Ori(1,i) = Xdur(id)*AngleCo;
    else
        Ori(1,i) = idx*AngleCo;
    end
    
    % find bins of orientation histogram which are higher than 80% of peak.
    % this bins must have at least 2 bins farther than peak.
    
    NextMaxIdx = HistOri >= (0.8*val);
    id = zeros(1,3);
    if sum(NextMaxIdx) > 1
        DupKeypoint(i) = min(sum(NextMaxIdx)-1,3);
        id(1) = idx;
        
        for k = 1 :DupKeypoint(i)
            HistOri(id(k)) = 0;
            [~,temp] = max(HistOri);
            id(k+1) = temp;
            
            % reject next max which is next to peak
            if abs(id(2)-idx)~=1 && abs(id(3)-idx)~=1 && abs(id(2)-id(3))~=1
                Ori(k+1,i) = temp*AngleCo;
            end
        end
    end
end

end


function [SIFTKey,SS] = SIFT_Extractor(I,param)
%Do all steps for SIFT Keypoint extraction and description
% This function is written to extract SIFT feature 
%
% Syntax:
%         [SIFTKey,SS] = SIFT_Extractor(I,param)
% Inputs:
%         DoGimg  - doubled format 2-dimensional image
%         param   - parameters
%                   param.
% Outputs:
%
%
% -------------------------------
% Written by : S.Ehsan Mirsadeghi
% Date       : April 2015


% 1- Scale-Space analysis
SS = SIFT_ScaleSpace(I,param);

% initialization

DoGimg = SS.DoG;
GuSimg = SS.GuS;
[row,col] = size(DoGimg{1,1});
% define number of scales in each octaves
numScale = param.s + 3;

% Pre-allocation
Ix = cell(1,param.numOct);

% length of pixel neighbours
L = 1;

% power of standard deviation coefficient "k"
co = 0 : numScale-1;

% differences in scale
K = 2 .^ (co/param.s);
KeyScale = (param.sigma * 2.^(0:param.numOct-1))'*K;

% build coefficient 'co' for converting coordinates of octaves to the
% reference octave.
OctaveRange = param.stOct:param.stOct+param.numOct;
co = 2.^(-OctaveRange);

MaxNumKey = ceil(numel(GuSimg{abs(param.stOct)+1,1})/5);
Index = 0;
frame = zeros(4,MaxNumKey);
%desc = zeros(param.hbin*(param.WinSize/param.CellSize)^2,MaxNumKey);
desc = zeros((param.hbin*(param.WinSize/param.CellSize)^2),MaxNumKey);
Sc = zeros(1,MaxNumKey);
Oct = zeros(1,MaxNumKey);


%% Main loop over all octaves and scales

for i = 1:param.numOct
    
    for j = 1 :numScale-1
        % comparing pixels which located on the 3*3 window in 3 consecutive
        % scales by shifting images with 1 pixel in all directions
        temp = ShiftImg(DoGimg{i,j},L,'all');
        Ix{i}(:,(9*j)-8:9*j) = temp;
        
        if j > 2
            
            % find exterama in all 3*3 neighbourhood
            [~,Imax] = max(abs(Ix{i}(:,(9*(j-2))-8:9*(j))),[],2);
            
            % -------------------------------------------------------------
            % 1-2- Local extrema Detection
            % -------------------------------------------------------------
            % find index of exterema pixels which locate on the center of
            % each 3*3 window in 3 consecutive scales
            Idx = Imax == 14;
            [r,c] = size(DoGimg{i,j});
            Idx = reshape(Idx,[r,c]);
            
            % -------------------------------------------------------------
            % 2- Accurate Keypoint Localization
            % -------------------------------------------------------------
            
            
            % -------------------------------------------------------------
            % 2-1- Reject unstable and near border keypoints
            % -------------------------------------------------------------
            Idx = SIFT_RejectUnstable(DoGimg{i,j},Idx,param);
            
            if sum(Idx(:)) ~= 0
                
                % find location of keypoints in the reference spatial domain
                [yy,xx] = meshgrid(1:size(Idx,2),1:size(Idx,1));
                xtemp = xx(Idx)';
                ytemp = yy(Idx)';
                
                % Build Index for storage
                Index = Index + size(xtemp,2);
                Sitemp = repmat(KeyScale(i,j),1,size(xtemp,2));
                tempFrame = [xtemp;ytemp;Sitemp];
                Oct(Index-size(xtemp,2)+1:Index) = repmat(i,1,size(xtemp,2));
                Sc(Index-size(xtemp,2)+1:Index)  = repmat(j,1,size(xtemp,2));
                
                [Grad.Mag,Grad.Angle] = compute_gradient(GuSimg{i,j-1});
                
                % ---------------------------------------------------------
                % 3- Orientation Assignment
                % ---------------------------------------------------------
                tempOri = SIFT_AssignOrientation(Grad,xx,yy,tempFrame,param);
                
                % send coordinate of keypoint in the curren tscale and
                % octave to the reference image coordinate by "co" variable
                stIdx = Index-size(xtemp,2)+1;
                frame(:,Index-size(xtemp,2)+1:Index) = ...
                    [xtemp/co(i);ytemp/co(i);Sitemp;tempOri(1,:)];
                xx = xtemp/co(i);
                yy = ytemp/co(i);
                % copy duplicate keypoint into frame for those who has more
                % than one dominate orientation.
                if strcmpi(param.dupKey,'true')
                    if sum(tempOri(:)>0) > size(tempOri,2)
                        for k = 2:4
                            tIdx = tempOri(k,:) > 0;
                            frame(:,Index+1:Index+sum(tIdx)) = ...
                                [xtemp(tIdx)/co(i);ytemp(tIdx)/co(i);Sitemp(tIdx);tempOri(k,tIdx)];
                            Index = Index + sum(tIdx);
                            xx = [xx xtemp(tIdx)/co(i)];
                            yy = [yy ytemp(tIdx)/co(i)];
                        end
                    end
                end
                endIdx = Index;
                
                % 4- Descriptor Representation
                tframe = frame(:,stIdx:endIdx);
                tframe(1:2,:) = tframe(1:2,:)*co(i);
                ttemp = SIFT_Descriptor(Grad,tframe,param);
                % ttemp = [ttemp;0.2*xx/row;0.2*yy/col];
                desc(:,stIdx:endIdx) = ttemp;
            end
        end
    end
end

%% Store SIFT frames

% Remove empty elements
frame(:,Index+1:end) = [];
desc(:,Index+1:end) = [];
Oct(Index+1:end) = [];
Sc(Index+1:end) = [];
SIFTKey.desc = desc;
SIFTKey.frame = frame;
SIFTKey.OctaveIdx = Oct;
SIFTKey.ScaleIdx = Sc;
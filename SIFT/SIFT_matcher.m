function [Idx,d1,Idxx] = SIFT_matcher(X,Y,ratio)
%Match two set of SIFT descriptor
% This function compute pairwise distance between two set of
% observations. columns of X , Y correspond to observations.
%
% Syntax :
%           [Idx,Idxx] = SIFT_matcher(X,Y,ratio)
% Inputs:
%           X,Y    : measurements
%           method : (1) Euclidean distance
%                    (2) Chi Squared distance
%
% -------------------------------
% Written by : S.Ehsan Mirsadeghi
% Date       : March 2015

[~,n] = size(X);
[~,m] = size(Y);
% if ~isequal(r1,r2)
%     error('input matrix X , Y should have equal rows')
% end
% pre-allocation
d1 = zeros(m,n);
d2 = zeros(m,n);

for i = 1 : n
%     for j = 1 : m
        % compute euclidian distance between two vectors
        
        Xp = repmat(X(:,i),1,m);
        temp = (Xp-Y).^2;
        % d2(j,i) = sqrt(sum((X(:,i)-Y(:,j)).^2));
%         d1(j,i) = sum(  ((X(:,i)-Y(:,j)).^2) ./ ((X(:,i)+Y(:,j))+eps) );
        d1(:,i) = sum(  (temp) ./ ((Xp+Y)+eps) );
        d2(:,i) = sqrt(sum((temp).^2));
%     end
end

% SIFT Keypoint matching

%
% find nearest neighbour
[v1,Idx1] = min(d1);
for k = 1 : n
    d1(Idx1(k),k) = nan;
end
% find next nearest neighbour
[v2,~] = min(d1);

% compute distance ratio
criteria = v1./v2;
Id = criteria<=ratio;
temp1 = 1 : n;
Idx = [temp1(Id);Idx1(Id)];

% sort matched descriptor in the ascending order
[~,IX] = sort(criteria(Id));
Idx = [Idx(:,IX);criteria(Id)];

%
[v11,Idx11] = min(d2);
for k = 1 : n
    d2(Idx11(k),k) = nan;
end
% find next nearest neighbour
[v22,~] = min(d2);

% compute distance ratio
criteria2 = v11./v22;
Id2 = criteria2<=ratio;
temp2 = 1 : n;
Idxx = [temp2(Id2);Idx11(Id2)];

% sort matched descriptor in the ascending order
[~,IXX] = sort(criteria2(Id2));
Idxx = [Idxx(:,IXX);criteria2(Id2)];
%}
%}
%         for i = 1 : n
%             % Yt = repmat(Y(:,i),1,size(X,2));
%             % compute chi squared distance between two vectors
%             % Note : Add epsilon to denumerator to avoid divide by zeros
%             % d(:,i) = sum(  ((X-Yt).^2) ./ ((X+Yt)+eps) );
%             for j = 1 : m
%                 % compute euclidian distance between two vectors
%                 d(j,i) = sum(  ((X(:,j)-Y(:,i)).^2) ./ ((X(:,j)+Y(:,i))+eps) );
%             end
%         end
end

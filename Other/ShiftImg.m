function Is = ShiftImg(I,L,NumShift)
% This function is written to compare pixels in the local neighbourhood.

if strcmpi(NumShift,'4x4')
    
    %  4 neighbour in 2*2 window
    %  -----------
    % |  1  |  2  |
    % |-----|-----|
    % |  4  |  3  |
    %  -----------
    
    % Left       shfited image
    Il  = [I(:,L+1:end) I(:,1:L)];
    
    % Up      shfited image
    Iu  = [I(L+1:end,:);I(1:L,:)];
    
    % Up-Left    shfited image
    Iul = [Il(L+1:end,:);Il(1:L,:)];
    
    Is(:,1) = I(:);
    Is(:,2) = Il(:);
    Is(:,3) = Iul(:);
    Is(:,4) = Iu(:);
    
elseif strcmpi(NumShift,'all')
    %  9 neighbour in 3*3 window
    %  -----------------
    % |  1  |  2  |  3  |
    % |-----|-----|-----|
    % |  4  |  5  |  6  |
    % |-----|-----|-----|
    % |  7  |  8  |  9  |
    %  -----------------
    
    % Left       shfited image
    Il  = [I(:,L+1:end) I(:,1:L)];
    
    % Right      shfited image
    Ir  = [I(:,end-L+1:end) I(:,1:end-L)];
    
    % Up      shfited image
    Iu  = [I(L+1:end,:);I(1:L,:)];
    
    % Down      shfited image
    Id  = [I(end-L+1:end,:);I(1:end-L,:)];
    
    % Up-Left    shfited image
    Iul = [Il(L+1:end,:);Il(1:L,:)];
    
    % Up-Right   shfited image
    Iur = [Ir(L+1:end,:);Ir(1:L,:)];
    
    % Down-Left  shfited image
    Idl = [Il(end-L+1:end,:);Il(1:end-L,:)];
    
    % Down-Right shfited image
    Idr = [Ir(end-L+1:end,:);Ir(1:end-L,:)];
    
    Is(:,1) = Idr(:);
    Is(:,2) = Id(:);
    Is(:,3) = Idl(:);
    Is(:,4) = Ir(:);
    Is(:,5) = I(:);
    Is(:,6) = Il(:);
    Is(:,7) = Iur(:);
    Is(:,8) = Iu(:);
    Is(:,9) = Iul(:);
end


% Idx = Iref*0;
% for i = 1 : 8
%    temp = Iref > Is(:,:,i);
%    Idx = Idx + temp;
% end
% Idx = Idx == 8;
end
function plot_descriptor(I,frame)
% plot images with SIFT Keypoints

% show image
imshow(I,[])
hold on
% plot dominate orientation and keypoints on the center of circle
for i = 1:size(frame,2)
    scatter(frame(1,i),...
        frame(2,i),...
        5.^(frame(3,i)),'r','LineWidth',2)
    line([frame(1,i),frame(3,i)*cosd(frame(4,i))+frame(1,i)],...
        [frame(2,i),frame(3,i)*sind(frame(4,i))+frame(2,i)],'LineWidth',2);
end
title(sprintf('Number of detected Keypoints: %d',size(frame,2)))
end
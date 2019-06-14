function show_match(I1,I2,f1,f2,Idx,TopKeyNum)
Ir{1} = I1;
Ir{2} = I2;

if isempty(TopKeyNum)
    TopKeyNum = size(Idx,2);
end


f1 = f1(:,Idx(1,:));
f2 = f2(:,Idx(2,:));
[r1,c1] = size(Ir{1});
[r2,c2] = size(Ir{2});

row = [r1 r2];
col = [c1 c2];

[~,rowId] = sort(row);
[~,colId] = sort(col);

% Ir{1} = 
% if r1*c1>r2*c2
%    I2 = imresize(I2,[r1,c1]);
% end

I = [I1 I2];
Lcolor = colormap(hsv(TopKeyNum));
imshow(I)
hold on
for idd = 1 : TopKeyNum
    line([f1(2,(idd)),f2(2,(idd))+c1],...
        [f1(1,(idd)),f2(1,(idd))],'LineWidth',1.5,'Color',Lcolor(idd,:));
end
scatter(f1(2,1:TopKeyNum),f1(1,1:TopKeyNum),f1(3,1:TopKeyNum),Lcolor,'d','LineWidth',1.5)
scatter(f2(2,1:TopKeyNum)+c1,f2(1,1:TopKeyNum),f2(3,1:TopKeyNum),Lcolor,'d','LineWidth',1.5)
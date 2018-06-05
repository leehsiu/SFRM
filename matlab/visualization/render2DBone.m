function render2DBone(p3d,lineWidth,lineType)
bone_color= [
    255.0,     0.0,    85.0;
    255.0,     0.0,     0.0;
    255.0,    85.0,     0.0;
    255.0,   170.0,     0.0;
    255.0,   255.0,     0.0;
    170.0,   255.0,     0.0;
    85.0,   255.0,     0.0;
    0.0,   255.0,     0.0;
    0.0,   255.0,    85.0;
    0.0,   255.0,   170.0;
    0.0,   255.0,   255.0;
    0.0,   170.0,   255.0;
    0.0,    85.0,   255.0;
    0.0,     0.0,   255.0;
    255.0,     0.0,   170.0;
    170.0,     0.0,   255.0;
    255.0,     0.0,   255.0;
    85.0,     0.0,   255.0;
    ];
boneList=[1,2,   1,5,   2,3,   3,4,   5,6,   6,7,   1,8,   8,9,   9,10,  1,11,  11,12,  12,13, 0,1];
boneList = boneList+1;
boneList = reshape(boneList,[2,length(boneList)/2]);

hold on;
grid on;
for j=1:length(boneList)
    plot3(p3d(1,boneList(:,j)),p3d(2,boneList(:,j)),[1 1],'Color',bone_color(boneList(2,j),:)./255,'LineWidth',lineWidth,'LineStyle',lineType);
    
end
end


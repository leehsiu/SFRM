function render3DBone( p3d )
%RENDER3DBONE Summary of this function goes here
%   Detailed explanation goes here
global minBone3DCov;

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
bone_pair=[1,2,   1,5,   2,3,   3,4,   5,6,   6,7,   1,8,   8,9,   9,10,  1,11,  11,12, 12,13,  1,0];
bone_pair = reshape(bone_pair,[2,length(bone_pair)/2]);
hold on;
grid on;
axis equal;

for j=1:1:length(bone_pair)   
        plot3(p3d(1,bone_pair(:,j)+1),p3d(2,bone_pair(:,j)+1),p3d(3,bone_pair(:,j)+1),'Color',bone_color(bone_pair(2,j)+1,:)./255,'LineWidth',2);

end


end


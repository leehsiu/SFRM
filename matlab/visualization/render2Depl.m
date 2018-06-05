function render2Depl(epl,p3d)
%RENDER3DBONE Summary of this function goes here
%   Detailed explanation goes here
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
hold on;
grid on;
axis equal;

for j=1:length(epl)
    if(p3d(3,j)>0)
        plot([-5 5],[(-epl(3,j)+5*epl(1,j))/epl(2,j) (-epl(3,j)-5*epl(1,j))/epl(2,j)],'LineStyle',':','Color',bone_color(j,:)./255,'LineWidth',2);
    end
    
end

axis ij;

end


function render2DRigidPart(rigidPart,p3d )
hold on;
grid on;
axis equal;
for j=1:length(rigidPart)
    
    plot(p3d(1,rigidPart(j)),p3d(2,rigidPart(j)),'ro','MarkerSize',8);
    
    
end
axis ij;
end


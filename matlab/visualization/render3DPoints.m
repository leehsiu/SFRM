function render3DPoints( x3d,mtype )
%RENDER2DPOINTS Summary of this function goes here
%   Detailed explanation goes here
hold on;
nP = size(x3d,2);
cm = jet(nP);
for i=1:nP
    plot3(x3d(1,i),x3d(2,i),x3d(3,i),mtype,'Color',cm(i,:));
end


end


function render2DPoints( x2d,mtype )
%RENDER2DPOINTS Summary of this function goes here
%   Detailed explanation goes here
hold on;
nP = size(x2d,2);
cm = jet(nP);
for i=1:nP
    plot(x2d(1,i),x2d(2,i),mtype,'Color',cm(i,:));
end


end


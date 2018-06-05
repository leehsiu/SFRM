WORK_DIR = '~/databag/SFRM/pano0';
load(fullfile(WORK_DIR,'allKps3DGt.mat'));

nPts = size(ptsAll3D,2);
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
nFrames = size(ptsAll3D,1)/3;




c3Dw = zeros(nFrames*3,15);
idList = zeros(nFrames,1);
j = 1;
for i=1:nFrames
    c3D = ptsAll3D(i*3-2:i*3,:);
    if(max(abs(c3D(3,:)))==0)
        continue;
    end
    if(max(c3D(3,:)<0))
        c3D = -c3D;
    end
    cJointL = norm(c3D(:,1)-c3D(:,3));
    c3D = c3D./cJointL;
    
    c3Dw(j*3-2:j*3,:) = c3D;
    idList(j) = i;
    j = j+1;
    
end


c3Dw = c3Dw(1:(j-1)*3,:);
idList = idList(1:j-1);
j



allX = c3Dw(1:3:end,:);
allY = c3Dw(2:3:end,:);
allZ = c3Dw(3:3:end,:);
hold on;
for j=1:14
    plot3(allX(:,j),allY(:,j),allZ(:,j),'-','Color',bone_color(j,:)./255);
end
axis equal;
grid on;
daspect([1 1 1]);

fid= fopen(fullfile(WORK_DIR,'skeletonsGt.txt'),'w');
for i=1:size(c3Dw,1)/3
    fprintf(fid,'%d\n',idList(i));
    fprintf(fid,'%f %f %f\n',[allX(i,:);allY(i,:);allZ(i,:)]);
end
fclose(fid);


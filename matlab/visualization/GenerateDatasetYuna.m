WORK_DIR = '~/databag/SFRM/Yuna';
load(fullfile(WORK_DIR,'allKps3D.mat'));
load(fullfile(WORK_DIR,'allKps.mat'));

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




c3Dw = zeros(nFrames*3,14);
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
    
    
    %nose and nect reletive
    
    
    
    c2D = allKps(i*3-2:i*3,:);
    
    c3Drep = c3D./repmat(c3D(3,:),[3 1]);
    repErr = sum(sqrt(diag((c2D - c3Drep)'*(c2D-c3Drep))));
    cJointL = norm(c3D(:,2)-c3D(:,9))+norm(c3D(:,2)-c3D(:,12));
    c3D = c3D./cJointL;
    if(repErr<0.35)
        xyzDist = max(c3D,[],2) -min(c3D,[],2);
        if(norm(xyzDist)>3)
            continue;
        end
        
        
        
        meanD = mean(c3D(3,:));
        flipD = 2*meanD - c3D(3,:);
        c3D(3,:) = flipD;
        c3Dw(j*3-2:j*3,:) = c3D;
        idList(j) = i;
        j = j+1;
    end
    %     if(c3D(3,1)>c3D(3,2))
    %         meanD = mean(c3D(3,:));
    %         flipD = 2*meanD - c3D(3,:);
    %         c3D(3,:) = flipD;
    %     end
    %     c3Dw(j*3-2:j*3,:) = c3D;
    %     idList(j) = i;
    %     j = j+1;
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

fid= fopen(fullfile(WORK_DIR,'skeletonsNoiseFlip.txt'),'w');
for i=1:size(c3Dw,1)/3
    fprintf(fid,'%d\n',idList(i));
    fprintf(fid,'%f %f %f\n',[allX(i,:);allY(i,:);allZ(i,:)]);
end
fclose(fid);


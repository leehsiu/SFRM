
WORK_DIR = '~/databag/SFRM/walk0';
load(fullfile(WORK_DIR,'allKps3D.mat'));
load(fullfile(WORK_DIR,'allKps.mat'));
rawPoses = dlmread(fullfile(WORK_DIR,'camposes.txt'), ' ', 4, 0);


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
allId = rawPoses(:,1);
allId = allId+1;



nPose = length(allId);
allPose = rawPoses(:,2:17);
allPose =  reshape(allPose',[4 4 nPose]);

allT = allPose(1:3,4,:);
allT = reshape(allT,[3 nPose 1]);


asp = 0.35;

[~,idx]=ismember(allKpsList,allId);

sId = find(idx>0,1,'first');

c3Dw = zeros(length(idx)*3,14);
idList = zeros(length(idx),1);
j = 1;
for i=sId:length(idx)
    c3D = ptsAll3D(i*3-2:i*3,:);
    if(max(c3D(3,:)<0))
        c3D = -c3D;
    end
    
    %Do the flip if revease
    
    
    %nose and nect reletive
    if(c3D(3,1)>c3D(3,2))
        meanD = mean(c3D(3,:));
        flipD = 2*meanD - c3D(3,:);
        c3D(3,:) = flipD;
    end
    
    
    
    
    
    %     if(max(c3D(3,:))<0)
    %         vec = mean(c3D,2);
    %         c3Dflip = c3D;
    %         c3Dflip(3,:) = -c3D(3,:);
    %
    %     else
    %
    %     end
    
    c2D = allKps(i*3-2:i*3,:);
    
    c3Drep = c3D./repmat(c3D(3,:),[3 1]);
    repErr = sum(sqrt(diag((c2D - c3Drep)'*(c2D-c3Drep))));
    cJointL = norm(c3D(:,2)-c3D(:,9))+norm(c3D(:,2)-c3D(:,12));
    c3D = asp*c3D./cJointL;
    if(repErr<0.2)
        if(c3D(3,1)>c3D(3,2))
            meanD = mean(c3D(3,:));
            flipD = 2*meanD - c3D(3,:);
            c3D(3,:) = flipD;
        end
        c3Dw(j*3-2:j*3,:) = allPose(1:3,1:3,idx(i))*c3D + repmat(allPose(1:3,4,idx(i)),[1 14]);
        idList(j) = idx(i);
        j = j+1;
    end
end



c3Dw = c3Dw(1:(j-1)*3,:);
idList = idList(1:j-1);
j;
% numWorld = j-1;
% for i=1:numWorld
%
% end







plot3(allT(1,:),allT(2,:),allT(3,:),'r-','LineWidth',3);
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
%
fid= fopen(fullfile(WORK_DIR,'skeletonsNoise.txt'),'w');
for i=1:size(c3Dw,1)/3
    fprintf(fid,'%d\n',idList(i));
    fprintf(fid,'%f %f %f\n',[allX(i,:);allY(i,:);allZ(i,:)]);
end
fclose(fid);


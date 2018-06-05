function [ reprojErr ] = getGroupForFrame(allJson,allImage,allPose,K,t1)
%GROUPTRIANGULATION Summary of this function goes here
%   Detailed explanation goes here
global NO_GUI;
global KpsWeight;
global KpsWeightTH;
NO_GUI=1;
nFrames = length(allJson);
if min([length(allJson),length(allImage),length(allPose)])~= max([length(allJson),length(allImage),length(allPose)])
    error('keypoints file, image file and poses file dont match');
end

if ~NO_GUI
    img1 = imread(fullfile(allImage(t1).folder,allImage(t1).name));
end

kps1 = getKpsfromJson(fullfile(allJson(t1).folder,allJson(t1).name));

reprojErr = zeros(nFrames,1);
nKps = length(kps1);

for t2 = 1:1:nFrames
    if(t2==t1)
        reprojErr(t2)=0;
    else
        pairPose = allPose([t1 t2],:);
        
        kps2 = getKpsfromJson(fullfile(allJson(t2).folder,allJson(t2).name));
        cur_err = zeros(nKps,1);
        cur_kps = zeros(nKps,3);
        for kpsId=1:nKps
            pairKps = [kps1(:,kpsId) kps2(:,kpsId)];
            
            p4d=calTriangulation(pairPose,pairKps,K);
            cur_kps(kpsId,:) = p4d(1:3);
            cur_err(kpsId) = p4d(4);
        end
        reprojErr(t2) = max(cur_err);
        
        if~NO_GUI
            checkFrames(pairPose,allImage([t1 t2]),allJson([t1 t2]),K);
            pause
            img2 = imread(fullfile(allImage(t2).folder,allImage(t2).name));
            figure(1);
            subplot(1,2,1);
            imshow(img1);
            hold on;
            pose1 = allPose(t1,:);
            pose1 = reshape(pose1,4,4);
            p3d1 = inv(pose1)*[p4d(1:3);1];
            p3d1 = K*p3d1(1:3);
            p3d1 = p3d1(1:2)./p3d1(3);
            plot(p3d1(1),p3d1(2),'ro','markers',5);
            
            subplot(1,2,2);
            imshow(img2);
            hold on;
            pose2 = allPose(t2,:);
            pose2 = reshape(pose2,4,4);
            p3d2 = inv(pose2)*[p4d(1:3);1];
            p3d2 = K*p3d2(1:3);
            p3d2 = p3d2(1:2)./p3d2(3);
            plot(p3d2(1),p3d2(2),'ro','markers',5);
            pause
        end
        
    end
    
end

end


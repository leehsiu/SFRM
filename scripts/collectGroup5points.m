%load all data
global bone_color;
bone_color = [
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
K = zeros(3,3);
K(1,1) = 7.005836945361845e+02;
K(2,2) = 7.005836945361845e+02;
K(1,3) = 7.577392339646816e+02;
K(2,3) = 3.667215676837498e+02;
K(3,3) = 1;
invK = inv(K);
global GOOD_PAIR_TH;
global GUI_SHOW;
global FILM_DIS_TH;
global WRITE_OBJ;
global GROUP_TH;
GOOD_PAIR_TH = 0.3;
GUI_SHOW = 0;
WRITE_OBJ = 0;
GROUP_TH = 0.4;

TorsoId = [1 2 5 8 11]; %neck is virtual /%The trunk of body which should always be usesd
TorsoId = TorsoId+1;

NearId = [0 3 6 9 12];
NearId = NearId+1;

FarId = [4 7 10 13];
FarId = FarId+1;

UseId = [TorsoId NearId FarId];


%WORK_DIR='/home/xiul/databag/chinese_dancing';
WORK_DIR='/home/xiul/databag/chinese_dancing';
allJson = dir(fullfile(WORK_DIR,'/image_skeleton_origin','*.json'));
allImage = dir(fullfile(WORK_DIR,'/image_skeleton_origin','*.png'));

nFrames = length(allJson);
%load all kps
% allKps = zeros(3*nFrames,18);
% allCropImage = cell(nFrames,1);
% fprintf('Pre load all data');
% for idx=1:nFrames
%     allKps(idx*3-2:idx*3,:) = getKpsfromJson(fullfile(allJson(idx).folder,allJson(idx).name));
%     img = imread(fullfile(allImage(idx).folder,allImage(idx).name));
%     allCropImage{idx} = imcrop(img,cropKps(allKps(idx*3-2:idx*3,:)));
%     idx
% end
% fprintf('Loaded');
load('allData.mat');


allGroups = zeros(length(allJson),length(allJson));
groupNum = 1;
allGroups(1,1) = 1;




if WRITE_OBJ
writerObj = VideoWriter(fullfile(WORK_DIR,'collectResi.avi')); % Name it.
writerObj.FrameRate = 24; % How many frames per second.
open(writerObj); 
end
fig = figure(1);
set(fig,'units','normalized','outerposition',[0 0 1 1]); 
GroupSign = zeros(length(allJson),1);
%max length
for t1=1:length(allJson)
%for t1=1:300
    curk1 =  allKps(t1*3-2:t1*3,:);
    
    for groupId=1:groupNum
        curGroupIndex = allGroups(groupId,:)>0;
        groupLength = sum(curGroupIndex);
        curGroupVec = allGroups(groupId,randperm(groupLength));
        curLength = min(groupLength,3);
        curGroupResi = zeros(curLength,1);
        
        for tk=1:curLength
            curkk = allKps(curGroupVec(tk)*3-2:curGroupVec(tk)*3,:);
            %function [retE,retP,retResi,retRigid,retType] = cal2poseResidual_v5(kps1,kps2,K)
            niceId = curk1(3,UseId)>GOOD_PAIR_TH&curkk(3,UseId)>GOOD_PAIR_TH;
            [~,~,retResi,retRigid,~] = cal2poseResidual_v5(curk1,curkk,K);
            resiH = retResi(end);
            resiHE = retResi(end-1);
            resirigidMax = max(retResi(retRigid));           
            resigoodMax = max(retResi(UseId(niceId)));
            resiuseMean = mean(retResi(UseId));
            resVec = [resiH resiHE resirigidMax resigoodMax resiuseMean];
            curGroupResi(tk) = prod(exp(-resVec));
            if(curGroupResi(tk)<GROUP_TH)
               continue;
            end            
        end
        if(min(curGroupResi)>GROUP_TH)
            GroupSign(t1) = groupId;
            allGroups(groupId,groupLength+1) = t1;
            break;
        end        
    end
    if(GroupSign(t1)==0)
        GroupSign(t1) = groupNum+1;
        allGroups(groupNum+1,1) = t1;
        groupNum = groupNum+1;
    end
    GroupSize = zeros(groupNum,1);
    for groupId=1:groupNum
        GroupSize(groupId) = sum(allGroups(groupId,:)>0);
    end
    
    
    subplot(2,10,[1 2 3 4]);
    imshow(allCropImage{t1});    
    subplot(2,10,[5 6 7]);
    plot(GroupSign,'b-');    
    subplot(2,10,[8 9 10]);
    bar(1:length(GroupSize),GroupSize,'b');
    hold on;
    bar(GroupSign(t1),GroupSize(GroupSign(t1)),'r');
    curSign = GroupSign(t1);
    curSize = GroupSize(curSign);
    curVec = allGroups(curSign,randperm(curSize));
    for jj=1:min(curSize,5)                
        timg = curVec(jj);        
        subplot(2,10,[jj*2-1+10 jj*2-1+11]);
        imshow(allCropImage{timg});
    end
    if WRITE_OBJ         
    frame = getframe(fig); % 'gcf' can handle if you zoom in to take a movie.
    writeVideo(writerObj, frame);    
    end
    
end
if WRITE_OBJ
close(writerObj);
end
%end

function roiRec=cropKps(kps_)

activeId = kps_(3,:)>1e-1;
activeKps = kps_(:,activeId);
xmin = min(activeKps(1,:));
ymin = min(activeKps(2,:));
xw = max(activeKps(1,:)) - min(activeKps(1,:));
yh = max(activeKps(2,:)) - min(activeKps(2,:));
roiRec = [xmin-20 ymin-20 xw+40 yh+40];
end

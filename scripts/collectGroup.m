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
GOOD_PAIR_TH = 0.25;
GUI_SHOW = 0;
WRITE_OBJ = 1;
GROUP_TH = 0.05;
FILM_DIS_TH = 3.0/K(1,1);

WORK_DIR='/home/xiul/databag/chinese_dancing';
%WORK_DIR='/home/xiul/databag/dancing';
allJson = dir(fullfile(WORK_DIR,'/image_skeleton_origin','*.json'));
allImage = dir(fullfile(WORK_DIR,'/image_skeleton_origin','*.png'));

HomoPart = [1 2 5 8 11];
HomoPart = HomoPart+1;

%nonHomoPart = [0 3 4 6 7 9 10 12 13];
nonHomoPart = [3 4 6 7 9 10 12 13];
nonHomoPart = nonHomoPart+1;

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
    curk1 = getKpsfromJson(fullfile(allJson(t1).folder,allJson(t1).name));    
    for groupId=1:groupNum
        curGroupIndex = allGroups(groupId,:)>0;
        groupLength = sum(curGroupIndex);
        curGroupVec = allGroups(groupId,randperm(groupLength));
        curLength = min(groupLength,5);
        curGroupResi = zeros(curLength,1);
        
        for tk=1:curLength
            curkk = getKpsfromJson(fullfile(allJson(curGroupVec(tk)).folder,allJson(curGroupVec(tk)).name));
            [~,resefow,~] = cal2poseResidual_new(curk1,curkk,K);
            curGroupResi(tk) = resefow;
        end
        if(max(curGroupResi)<GROUP_TH)
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
    
    clf(fig);
    img1 = imread(fullfile(allImage(t1).folder,allImage(t1).name));
    kps1 = getKpsfromJson(fullfile(allJson(t1).folder,allJson(t1).name));
    fig = figure(1);
    subplot(2,10,[1 2 3 4 ]);
    img1 = imcrop(img1,cropKps(kps1));
    imshow(img1);    
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
        img = imread(fullfile(allImage(timg).folder,allImage(timg).name));
        kps = getKpsfromJson(fullfile(allJson(timg).folder,allJson(timg).name));
        img = imcrop(img,cropKps(kps));
        subplot(2,10,[jj*2-1+10 jj*2-1+11]);
        imshow(img);
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

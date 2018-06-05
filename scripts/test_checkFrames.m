clear all;
%load all data
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
global GOOD_PAIR_TH;
global FILM_DIS_TH;
global maxResi;
GOOD_PAIR_TH = 0.5;
FILM_DIS_TH = 0.01;
global GUI_SHOW;
GUI_SHOW = 0;
W = [0 -1 0;1 0 0;0 0 1];
WORK_DIR='/home/xiul/databag/chinese_dancing';
K = zeros(3,3);
% K(1,1) = 329.275;
% K(2,2) = 336.733;
% K(1,3) = 356.072;
% K(2,3) = 176.231;
% K(3,3) = 1;
K(1,1) = 7.005836945361845e+02;
K(2,2) = 7.005836945361845e+02;
K(1,3) = 7.577392339646816e+02;
K(2,3) = 3.667215676837498e+02;
K(3,3) = 1;
allJson = dir(fullfile(WORK_DIR,'/image_skeleton_origin','*.json'));
allP2d = dir(fullfile(WORK_DIR,'/image_skeleton_origin','*.p2d'));
allImage = dir(fullfile(WORK_DIR,'/image_skeleton_origin','*.png'));



t1 = 715/5+1;
t1 = 1;
allAs = zeros(length(allJson),1);
% t1 = 1;
% t2 = 5;


for t2 = 1:length(allJson)   

Kps1=getKpsfromJson(fullfile(WORK_DIR,'image_skeleton_origin',allJson(t1).name));
Kps2=getKpsfromJson(fullfile(WORK_DIR,'image_skeleton_origin',allJson(t2).name));
fig = figure(1);
clf(fig);
img1 = imread(fullfile(WORK_DIR,'image_skeleton_origin',allImage(t1).name));
img2 = imread(fullfile(WORK_DIR,'image_skeleton_origin',allImage(t2).name));
subplot(2,2,1);
imshow(img1);
subplot(2,2,2);
imshow(img2);


[Essential,residual,resultType] = cal2poseResidual_v5(Kps1, Kps2, K);


end


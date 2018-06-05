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
global dist2prob;
global fig;
GOOD_PAIR_TH = 0.25;
GUI_SHOW = 1;
WRITE_OBJ = 1;

FILM_DIS_TH = 3.0/K(1,1);
dist2prob = 0.5;

%WORK_DIR='/home/xiul/databag/10-14-5';
WORK_DIR='/home/xiul/databag/dancing';
allJson = dir(fullfile(WORK_DIR,'/image_skeleton_origin','*.json'));
allImage = dir(fullfile(WORK_DIR,'/image_skeleton_origin','*.png'));


h = 748;
HomoPart = [1 2 5 8 11];
HomoPart = HomoPart+1;

%nonHomoPart = [0 3 4 6 7 9 10 12 13];
nonHomoPart = [3 4 6 7 9 10 12 13];
nonHomoPart = nonHomoPart+1;

t1 =144;


res = zeros(length(allJson),1);

img1 = imread(fullfile(allImage(t1).folder,allImage(t1).name));
    
% for t1=101:1:300
%     t1
if WRITE_OBJ
writerObj = VideoWriter(fullfile(WORK_DIR,'out1.avi')); % Name it.
writerObj.FrameRate = 60; % How many frames per second.
open(writerObj); 
end
curk1 = getKpsfromJson(fullfile(allJson(t1).folder,allJson(t1).name));
fig = figure(1);
set(fig,'units','normalized','outerposition',[0 0 1 1]); 

for t2=1:length(allJson)
    img2 = imread(fullfile(allImage(t2).folder,allImage(t2).name));
    clf(fig);
    figure(fig);
    subplot(2,2,1);
    imshow(img1);
    subplot(2,2,3);
    imshow(img2);
    curk2 = getKpsfromJson(fullfile(allJson(t2).folder,allJson(t2).name));
    [~,resefow,~] = cal2poseResidual(curk1,curk2,K);
    
    res(t2) = (resefow);
    figure(fig);
    subplot(2,2,4);
    plot(res);
    ylim manual;    
   if WRITE_OBJ 
    frame = getframe(fig); % 'gcf' can handle if you zoom in to take a movie.
    writeVideo(writerObj, frame);    
   end
end
if WRITE_OBJ
close(writerObj);
end
%end
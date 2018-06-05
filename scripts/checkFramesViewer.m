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
global WRITE_OBJ;
global GUI_SHOW;
GOOD_PAIR_TH = 0.5;
FILM_DIS_TH = 0.01;
GUI_SHOW = 0;
WRITE_OBJ = 0;
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



t1 = 35;
fMat = sprintf('%s/vec_result/vec_%04d.mat',WORK_DIR,t1);
load(fMat);


[~,nid] = sort(sum(allAsall,2));
%nid = 1:length(allAs);
% t1 = 1;
% t2 = 5;

if WRITE_OBJ
writerObj = VideoWriter(fullfile(WORK_DIR,'groupResi.avi')); % Name it.
writerObj.FrameRate = 24; % How many frames per second.
open(writerObj); 
end
fig = figure(1);
set(fig,'units','normalized','outerposition',[0 0 1 1]); 
subplot(1,2,1);

img1 = imread(fullfile(WORK_DIR,'image_skeleton_origin',allImage(t1).name));
kps1 = getKpsfromJson(fullfile(WORK_DIR,'image_skeleton_origin',allJson(t1).name));


for t2 = 1:1:length(nid)   
    kps2 = getKpsfromJson(fullfile(WORK_DIR,'image_skeleton_origin',allJson(nid(t2)).name));
    img2 = imread(fullfile(WORK_DIR,'image_skeleton_origin',allImage(nid(t2)).name));
    
    subplot(2,2,1);    
    imshow(img1);  
    subplot(2,2,3);        
    plot(allAsall(nid(t2),:));
    ylim([0 2.5]);
    subplot(2,2,2);
    imshow(img2);        
    subplot(2,2,4);
    ylim([0 2.5]);
    plot(allAsall(nid(t2),:));
    pause(0.1);
    if WRITE_OBJ 
    frame = getframe(fig); % 'gcf' can handle if you zoom in to take a movie.
    writeVideo(writerObj, frame);    
    end         
end
if WRITE_OBJ
close(writerObj);
end


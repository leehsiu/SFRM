%main test file for visualSLAP

%1 setting up global variables
%SHOW GUI

global SHOW_GUI;
global hFigcImage;
global hFigcModel;
hFigcImage = figure(1);
hFigcModel = figure(2);


WORK_DIR='/home/xiul/databag/chinese_dancing';


%step-2 load all data
allJson = dir(fullfile(WORK_DIR,'/image_skeleton_origin','*.json'));
allImage = dir(fullfile(WORK_DIR,'/image_skeleton_origin','*.png'));
nFrames = length(allJson);


K = zeros(3,3);
K(1,1) = 7.005836945361845e+02;
K(2,2) = 7.005836945361845e+02;
K(1,3) = 7.577392339646816e+02;
K(2,3) = 3.667215676837498e+02;
K(3,3) = 1;

% allKps = zeros(3*nFrames,18);
% allCropImage = cell(nFrames,1);
% 
% tic;
% for idx=1:nFrames
%     allKps(idx*3-2:idx*3,:) = getKpsfromJson(fullfile(allJson(idx).folder,allJson(idx).name));
%     img = imread(fullfile(allImage(idx).folder,allImage(idx).name));
%     allCropImage{idx} = imcrop(img,cropKps(allKps(idx*3-2:idx*3,:)));
% end
% toc;
% save('kpsAndImage.mat','allKps','allCropImage');
load('kpsAndImage.mat');
allGroups = zeros(nFrames,nFrames);

GroupNum = 1;
allGroups(1,1) = 1;

refKps = allKps(1:3,:);
%step-3 start the system
%Whore System
for idx=1:nFrames
    %get current Kps
    figure(hFigcImage);
    imshow(allCropImage{idx});
    
    curKps = allKps(idx*3-2:idx*3,:);
    [retE,retP,retResi,retRigid,retType] = cal2poseResidual_v5(curKps, refKps, K);
    
    %2.
end

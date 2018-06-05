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
VEC_DIR = [WORK_DIR '/vec_result'];
mkdir(VEC_DIR);
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





% t1 = 1;
% t2 = 5;
TorsoId = [1 2 5 8 11]; %neck is virtual /%The trunk of body which should always be usesd
TorsoId = TorsoId+1;

NearId = [3 6 9 12];
NearId = NearId+1;

FarId = [4 7 10 13];
FarId = FarId+1;

useId = [TorsoId NearId FarId];

t1 = 1;
t2 = 20;


Kps1=getKpsfromJson(fullfile(WORK_DIR,'image_skeleton_origin',allJson(t1).name));
Kps2=getKpsfromJson(fullfile(WORK_DIR,'image_skeleton_origin',allJson(t2).name));
img1 = imread(fullfile(WORK_DIR,'image_skeleton_origin',allImage(t1).name));
img2 = imread(fullfile(WORK_DIR,'image_skeleton_origin',allImage(t2).name));
figure(1);
subplot(1,3,1);
imshow(img1);
subplot(1,3,2);
imshow(img2);
subplot(1,3,3);
imshow(img1-img2);
[retE,retP,retResi,retRigid,retType] = cal2poseResidual_v5(Kps1, Kps2, K);
Kps1Score = Kps1(3,:);
Kps1(3,:) = 1;
Kps2(3,:) = 1;
Kps1 = K\Kps1;
Kps2 = K\Kps2;

dall = zeros(14,2);
for i=1:14
    if(Kps1Score(i)>1e-1)
    p1 = Kps1(:,i);
    v1 = p1;
    p2 = Kps2(:,i);    
    v2 = -retP(1:3,1:3)*p2;
    h = retP(1:3,4);
    A = [v1 v2];
    dall(i,:) = pinv(A)*h;
    end
end
p3d = Kps1(:,1:14).*repmat(dall(:,1)',[3,1]);
figure(2);

for i=1:14
    if(p3d(3,i)>0)
    plot3(p3d(1,i),p3d(2,i),p3d(3,i),'o','Color',bone_color(i,:)./255);
    end
hold on;
end
daspect([1 1 1]);

% for t1=1:1:length(allJson)
%     
%     allAsall = zeros(length(allJson),18);
%     for t2 = 1:1:length(allJson)
%         Kps1=getKpsfromJson(fullfile(WORK_DIR,'image_skeleton_origin',allJson(t1).name));
%         Kps2=getKpsfromJson(fullfile(WORK_DIR,'image_skeleton_origin',allJson(t2).name));
%     
%         
%         [retE,retP,retResi,retRigid,retType] = cal2poseResidual_v5(Kps1, Kps2, K);
%     
%         allAsall(t2,:) =retResi;
%     end
%     matName = sprintf('%s/vec_%04d.mat',VEC_DIR,t1);
%     save(matName,'allAsall');
% end
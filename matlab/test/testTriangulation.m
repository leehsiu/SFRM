K = zeros(3,3);
K(1,1) = 7.005836945361845e+02;
K(2,2) = 7.005836945361845e+02;
K(1,3) = 7.577392339646816e+02;
K(2,3) = 3.667215676837498e+02;
K(3,3) = 1;

SLAPsetup();
WORK_DIR = '/home/xiul/databag/dancing/';
allImages = dir(fullfile(WORK_DIR,'image_skeleton_origin','*.png'));

load(fullfile(WORK_DIR,'allKps.mat'));

load(fullfile(WORK_DIR,'n_cut_dEdH.mat'));

gp = finalId{1};


g1 = 1;
g2 = 30;
t1 = allKpsList(gp(g1));
t2 = allKpsList(gp(g2));
figure(1);
subplot(1,2,1);
img = imread(fullfile(WORK_DIR,'image_skeleton_origin',allImages(t1).name));
imshow(img);
subplot(1,2,2);
img = imread(fullfile(WORK_DIR,'image_skeleton_origin',allImages(t2).name));
imshow(img);

kps1 = allKps(gp(g1)*3-2:gp(g1)*3,:);
kps2 = allKps(gp(g2)*3-2:gp(g2)*3,:);
E_all = calEssentialEightPoints(kps1,kps2);
%nE = length(E_all);
nE = 1;
figure(2);
for i=1:nE
    subplot(3,nE,i);
    epl1 = E_all*kps1;
    render2DBone(kps2,3,'-');
    render2Depl(epl1,kps1);
    axis image;
    xlim([-1 1]);
    ylim([-0.5 0.5]);
    subplot(3,nE,i+nE);
    epl2 = E_all'*kps2;
    render2DBone(kps1,3,'-');
    render2Depl(epl2,kps2);
    axis image;
    xlim([-1 1]);
    ylim([-0.5 0.5]);
    
    
    subplot(3,nE,i+2*nE);
    [R1,R2,t] = EmatDecomposition(E_all);
    drawCam([eye(3) zeros(3,1)],3,':');
    drawCam([R1 t],3,'-');
    drawCam([R2 t],3,'-');
    grid on;
    axis equal;
end


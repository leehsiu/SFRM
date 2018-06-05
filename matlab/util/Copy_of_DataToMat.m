K = zeros(3,3);
K(1,1) = 7.005836945361845e+02;
K(2,2) = 7.005836945361845e+02;
K(1,3) = 7.577392339646816e+02;
K(2,3) = 3.667215676837498e+02;
K(3,3) = 1;

WORK_DIR='/home/xiul/databag/SFRM/walk0';
allJson = dir(fullfile(WORK_DIR,'/image_skeleton_origin','*.json'));
nFrames = length(allJson);
skipFrame = 23;

allKps = zeros(3*nFrames,14);
allKpsList = zeros(nFrames,1);
j=0;
for i=1:nFrames
    curKps = getKpsfromJson(fullfile(WORK_DIR,'image_skeleton_origin',allJson(i).name));
    validId = curKps(3,1:14)>0.1;    
    if(sum(validId)<14||i<=skipFrame)
        continue;
    end    
    j=j+1;    
    curKps(3,:) = 1;
    curKps = K\curKps;    
    allKps(j*3-2:j*3,:) = curKps(:,1:14);   
    allKpsList(j) = i;
end
allKps = allKps(1:3*j,:);
allKpsList = allKpsList(1:j);
save(fullfile(WORK_DIR,'allKps.mat'),'allKps','allKpsList');
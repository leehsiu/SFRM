WORK_DIR = '~/databag/';
load(fullfile(WORK_DIR,'AllLeftHand_160224.mat'));
K = zeros(3,3);
K(1,1) =1632.8;
K(2,2) = 1628.61;
K(1,3) = 943.554;
K(2,3) = 555.893;
K(3,3) = 1;
allKps = allLeftHand{3};
nFrames = size(allKps,1)/3;
allKpsList = 1:nFrames;
for i=1:nFrames
    allKps(i*3,:) = 1;
    allKps(i*3-2:i*3,:) = K\allKps(i*3-2:i*3,:);
end
mkdir([WORK_DIR 'hand_3']);
save(fullfile(WORK_DIR,'hand_3','allKps.mat'),'allKps','allKpsList');

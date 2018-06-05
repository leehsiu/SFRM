WORK_DIR = '~/databag/SFRM/pano0';

load(fullfile(WORK_DIR,'panoData.mat'));

nFramesRaw = length(poseId);
nCamRaw = length(allpose2d);

setCamId = [0 3 5 7 8 9 11 12 14 15 16 18 20 21 22 24 25 26 27 29];
setCamId = setCamId+1;

nCamFake = length(setCamId);


sampleStart = 1500;
stdNum = 900;
nKps = size(allpose2d{1}{1},2);


%%

sampleFrame = sampleStart:sampleStart+stdNum-1;


fackCam = 1:stdNum;

fackCam = mod(fackCam,nCamFake)+1;

allKps = zeros(stdNum*3,nKps);


for i=1:stdNum
    c3D = allpose2d{setCamId(fackCam(i))}{sampleFrame(i)};
    c3D = c3D./repmat(c3D(3,:),[3 1]);
    
    allKps(i*3-2:i*3,:) = c3D;
    
end
allKpsList = sampleFrame;


save(fullfile(WORK_DIR,'allKps.mat'),'allKps','allKpsList');

ImageDir = '/home/xiul/workspace/panoptic-toolbox/scripts/150821_dance1/hdImgs/00_00';
allImages = dir(fullfile(ImageDir,'*.jpg'));

for i=1:900
    ImgId = poseId(allKpsList(i));
    curImageName = sprintf('00_00_%08d.jpg',ImgId);
    targImageName = sprintf('pano_%06d.jpg',i);
    copyfile(fullfile(ImageDir,curImageName),fullfile(WORK_DIR,'skeletons',targImageName));
end

%
%
% cKps = load(fullfile(WORK_DIR,'projections',allProj(1).name));
% nKps = length(cKps);
% allKps = zeros(3*nProj,nKps);
% allKpsList = zeros(nProj,nKps);
% for i=1:nProj
%     cKps = load(fullfile(WORK_DIR,'projections',allProj(i).name));
%     cKps = [cKps';ones(1,nKps)];
%     allKps(i*3-2:i*3,:) = invK*cKps;
% end
% allKpsList= 1:nProj;
% save(fullfile(WORK_DIR,'allKps.mat'),'allKps','allKpsList');

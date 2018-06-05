WORK_DIR = '~/databag/body_3';

load(fullfile(WORK_DIR,'AllBody_160224.mat'));

allKps = allBody{3};

nKps = size(allKps,2);
nFramesRaw = size(allKps,1)/3;

nCamRaw = 6;

allList = 1:nFramesRaw;

useId = mod(allList,30)<6;

%%




save(fullfile(WORK_DIR,'allKps.mat'),'allKps','allKpsList');
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

maWORK_DIR = '~/databag/human_kick2';

K = zeros(3,3);
K(1,1) = 700;
K(2,2) = 700;
K(1,3) = 960;
K(2,3) = 540;
K(3,3) = 1;
invK = inv(K);


allProj = dir(fullfile(WORK_DIR,'projections','*.txt'));

nProj = length(allProj);

cKps = load(fullfile(WORK_DIR,'projections',allProj(1).name));
nKps = length(cKps);
allKps = zeros(3*nProj,nKps);
allKpsList = zeros(nProj,nKps);
for i=1:nProj
    cKps = load(fullfile(WORK_DIR,'projections',allProj(i).name));
    cKps = [cKps';ones(1,nKps)];
    allKps(i*3-2:i*3,:) = invK*cKps;
end
allKpsList= 1:nProj;
save(fullfile(WORK_DIR,'allKps.mat'),'allKps','allKpsList');

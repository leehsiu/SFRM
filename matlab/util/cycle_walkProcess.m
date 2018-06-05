WORK_DIR = '~/databag/cycle_walk';
load(fullfile(WORK_DIR,'allKps.mat'));
allKpsList = 1:1000;
save(fullfile(WORK_DIR,'allKps.mat'),'allKps','allKpsList');
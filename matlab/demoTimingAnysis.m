WORK_DIR = '~/databag/flag2';
kpsNum = 15:2:40;
allData = load(fullfile(WORK_DIR,'allKps.mat'));
nFrames = 100;
time3 = zeros(length(kpsNum),1);

for i=1:length(kpsNum)    
    allKps = allData.allKps(1:nFrames*3,1:kpsNum(i));
    nKps = size(allKps,2);
    simMatrixE = zeros(nFrames,nFrames);
    simMatrixH = zeros(nFrames,nFrames);
    AllEmatCase = nchoosek(1:nKps,5);
    nEcase = size(AllEmatCase,1);
    nE = 10;
    ch = randperm(nEcase,nE);
    Ecase = AllEmatCase(ch,:);
    tic;    
    for t1 = 1:nFrames
        for t2=t1+1:nFrames
            %function retResi = cal2poseResidual_MultiLayer(kps1,kps2,EmatCase,nE,nkps)
            [simMatrixE(t1,t2),simMatrixH(t1,t2)] = cal2poseResidual_FiveSample(allKps(t1*3-2:t1*3,:),allKps(t2*3-2:t2*3,:),Ecase,nE,nKps);
        end
    end
    
    time3(i) = toc
end






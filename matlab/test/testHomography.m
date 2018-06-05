clear all;
%load all data
global WRITE_OBJ;
global OLD_VERSION;
WRITE_OBJ=0;
SLAPsetup();
WORK_DIR='/home/xiul/databag/walk3';

K = zeros(3,3);
K(1,1) = 7.005836945361845e+02;
K(2,2) = 7.005836945361845e+02;
K(1,3) = 7.577392339646816e+02;
K(2,3) = 3.667215676837498e+02;
K(3,3) = 1;
load(fullfile(WORK_DIR,'allKps.mat'));
[nFrames,~] = size(allKps);
nFrames = nFrames/3;
simMatrixE = zeros(nFrames,nFrames);
simMatrixH = zeros(nFrames,nFrames);
nKps = size(allKps,2);

cm = jet(nKps);
AllEmatCase = nchoosek(1:nKps,6);
nEcase = size(AllEmatCase,1);
nE = 5;
ch = randperm(nEcase,nE);
Ecase = AllEmatCase(ch,:);
while 1
    frameId = randi([1 nFrames],[2 1]);
    t1 = frameId(1);
    t2 = frameId(2);
    
    kps1  = allKps(t1*3-2:t1*3,:);
    kps2  = allKps(t2*3-2:t2*3,:);
    
    for tt=1:nE
        figure(tt);
        clf;
        Hmat = calHomographyMatrix(kps1(:,Ecase(tt,:)),kps2(:,Ecase(tt,:)));
 
        
        subplot(1,2,1);
        kps2Homo = Hmat*kps1;
        kps2Homo = kps2Homo./repmat(kps2Homo(3,:),[3 1]);
        for i=1:nKps
            plot(kps2(1,i),kps2(2,i),'*','Color',cm(i,:));
            hold on;
        end
        for i=1:nKps
            plot(kps2Homo(1,i),kps2Homo(2,i),'o','Color',cm(i,:));
            hold on;
        end
        xlim([-1 1]);
        ylim([-0.5 0.5]);
        subplot(1,2,2);
        kps1Homo = Hmat\kps2;
        kps1Homo = kps1Homo./repmat(kps1Homo(3,:),[3 1]);
        for i=1:nKps
            plot(kps1(1,i),kps1(2,i),'*','Color',cm(i,:));
            hold on;
        end
        for i=1:nKps
            plot(kps1Homo(1,i),kps1Homo(2,i),'o','Color',cm(i,:));
            hold on;
        end
        xlim([-1 1]);
        ylim([-0.5 0.5]);
        
    end
    
    
    pause;
end





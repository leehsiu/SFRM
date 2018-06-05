clear all;
%load all data
global WRITE_OBJ;
global OLD_VERSION;
WRITE_OBJ=0;
SLAPsetup();
WORK_DIR='/home/xiul/databag/walk1';

K = zeros(3,3);
K(1,1) = 7.005836945361845e+02;
K(2,2) = 7.005836945361845e+02;
K(1,3) = 7.577392339646816e+02;
K(2,3) = 3.667215676837498e+02;
K(3,3) = 1;
load(fullfile(WORK_DIR,'allKps.mat'));
load(fullfile(WORK_DIR,'n_cut_FiveSample.mat'));

[nFrames,~] = size(allKps);
nFrames = nFrames/3;
simMatrixE = zeros(nFrames,nFrames);
simMatrixH = zeros(nFrames,nFrames);
nKps = size(allKps,2);
nCluster = length(finalId);

matchId = finalId{3};
cm = jet(nKps);
t1 = 1;
for t2 = 2:length(matchId)
    kps1  = allKps(t1*3-2:t1*3,:);
    kps2  = allKps(t2*3-2:t2*3,:);
    
    pp = randperm(nKps,5);
    Ematall = solveE(kps1(:,pp),kps2(:,pp));
    %Ematall = calEssentialFivePoints(kps2,kps1,eye(3),eye(3));
    %Ematall = solveE_nister(kps1(:,2:6),kps2(:,2:6));
    nE = size(Ematall,3);
    %nE = length(Ematall);
    figure(1);
    clf;
    dE = zeros(nE,nKps);
    for j=1:nE
        Emat = Ematall(:,:,j);
        %Emat = Ematall{j};
        dE(j,:) = (calDEFinal(kps1,Emat,kps2)+calDEFinal(kps2,Emat',kps1))/2;
        subplot(nE,2,j*2-1);
        epl = Emat*kps2;
        for i=1:nKps
            plot(kps1(1,i),kps1(2,i),'*','Color',cm(i,:));
            hold on;
        end
        for i=1:nKps
            plot([-5 5],[(-epl(3,i)+5*epl(1,i))/epl(2,i) (-epl(3,i)-5*epl(1,i))/epl(2,i)],'LineStyle',':','Color',cm(i,:),'LineWidth',2);
            hold on;
        end
        
        xlim([-1 1]);
        ylim([-0.5 0.5]);
        axis ij;
        daspect([1 1 1]);
        subplot(nE,2,j*2);
        epl = Emat'*kps1;
        for i=1:nKps
            plot(kps2(1,i),kps2(2,i),'*','Color',cm(i,:));
            hold on;
        end
        for i=1:nKps
            plot([-5 5],[(-epl(3,i)+5*epl(1,i))/epl(2,i) (-epl(3,i)-5*epl(1,i))/epl(2,i)],'LineStyle',':','Color',cm(i,:),'LineWidth',2);
            hold on;
        end
        
        xlim([-1 1]);
        ylim([-0.5 0.5]);
        axis ij;
        daspect([1 1 1]);
    end
    gg = sum(dE,2)
    figure(2);
    clf;
    Hmat = calHomographyMatrix(kps1,kps2);
    [U,D,V] = svd(Hmat);
    Hmatb = calHomographyMatrix(kps2,kps1);
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
    axis ij;
    daspect([1 1 1]);
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
    axis ij;
    daspect([1 1 1]);
    
    pause;
end





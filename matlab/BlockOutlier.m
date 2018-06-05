% demoNcutClustering
WORK_DIR = '/home/xiul/databag/walk1/';
close all;
disp('Ncut Clustering viewer');
load(fullfile(WORK_DIR,'allKps.mat'));
load(fullfile(WORK_DIR,'simMatrix_FiveSample.mat'));
load(fullfile(WORK_DIR,'n_cut_FiveSample.mat'));

dE = simMatrixE+simMatrixE';
dH = simMatrixH+simMatrixH';
dete = 0.0045;
deth = 0.5;
SimWe = exp(-dE/(dete^2));
SimWh = 1-exp(-dH.^2/(deth^2));

Nc = length(finalId);
for i=1:Nc
    curId = finalId{i};
    cSimWe = SimWe(curId,curId);
    cSimWh = SimWh(curId,curId);
    cSim  = cSimWe;
    figure(1);
    clf;
    subplot(1,3,1);
    imagesc(cSimWe);
    colormap jet;
    subplot(1,3,2);
    imagesc(cSimWh);
    colormap jet;
    subplot(1,3,3);
    imagesc(cSimWe.*cSimWh);
    colormap jet;
    
    
    figure(2);
    nbCluster = 2;
    
    %nbCluster = 40;
    tic;
    [NcutDiscrete,NcutEigenvectors,NcutEigenvalues] = ncutW(cSim,nbCluster);
    disp(['The computation took ' num2str(toc) ' seconds']);        
    % display clustering result
    gId = cell(nbCluster,1);
    cluterSizeList = zeros(1,nbCluster);
    H = zeros(nD,nD);
    for j=1:nbCluster
        gId{j} = find(NcutDiscrete(:,j));       
    end            
    cidMat = cell2mat(gId);
    subplot(1,2,1);
    imagesc(cSim);
    colormap jet;
    subplot(1,2,2);
    imagesc(cSim(cidMat,cidMat));
    
    
    figure(3);
    NcNum = length(curId);    
    nRow = ceil(sqrt(NcNum));
    nCol = nRow;
    ImgOut = cell(nRow,nCol);
    
    for j=1:NcNum
        img = imread(fullfile(WORK_DIR,'image_skeleton_origin',allImages(allKpsList(curId(cidMat(j)))).name));
        ImgOut{j} = img;
    end
    for j=NcNum+1:nRow*nCol
        ImgOut{j} = uint8(zeros(iw,ih,ic));
    end
    if(NcNum>0)
        ImgOutMat = cell2mat(ImgOut);
        ImtOutResize = imresize(ImgOutMat,[iw*4 ih*4]);
        imshow(ImtOutResize);        
    end
    pause;
    
end

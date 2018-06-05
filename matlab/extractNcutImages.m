% demoNcutClustering
WORK_DIR = '/home/xiul/databag/SFRM/pano0/';

saveFolder = 'blockImages';
mkdir([WORK_DIR saveFolder]);

load(fullfile(WORK_DIR,'Ncut_better.mat'));
load(fullfile(WORK_DIR,'allKps.mat'));


allImages = dir(fullfile(WORK_DIR,'image_skeleton_origin','*.png'));
nCluster = length(sortCutIdx);

img = imread(fullfile(WORK_DIR,'image_skeleton_origin',allImages(1).name));
[iw,ih,ic] = size(img);
%pre-load image size

for i=1:nCluster
    
    blockIdx = sortCutIdx{i};   
    sizeBlock = length(blockIdx);    
    nRow = ceil(sqrt(sizeBlock));
    nCol = nRow;
    
    ImgOut = cell(nRow,nCol);
    ImgOutIdx = cell(nRow,nCol);
    for j=1:sizeBlock
        img = imread(fullfile(WORK_DIR,'image_skeleton_origin',allImages(allKpsList(blockIdx(j))).name));
        ImgOut{j} = img;
        %ImgOutIdx{j} = allKpsList(blockIdx(j));
        ImgOutIdx{j} = (blockIdx(j));
    end
    for j=sizeBlock+1:nRow*nCol
        ImgOut{j} = uint8(zeros(iw,ih,ic));
        ImgOutIdx{j} = -1;
    end
    
    if(sizeBlock>0)
        ImgOutMat = cell2mat(ImgOut);
        ImgOutResize = imresize(ImgOutMat,[iw*4 ih*4]);
        imgName = sprintf('block_%04d.jpg',i);
        imwrite(ImgOutResize,fullfile(WORK_DIR,saveFolder,imgName));
        
        idxName = sprintf('block_idx_%04d.txt',i);
        dlmwrite(fullfile(WORK_DIR,saveFolder,idxName),cell2mat(ImgOutIdx),'delimiter','\t');        
    end    
end

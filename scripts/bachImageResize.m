WORK_DIR = '/home/xiul/databag/chinese_dancing';
IMG_DIR = [WORK_DIR,'/image_skeleton_origin'];

fileList = dir(fullfile(IMG_DIR,'*.png'));
nFile = length(fileList);


for i=1:nFile
    fileName = fileList(i).name;    
    img1 = imread(fullfile(IMG_DIR,fileList(i).name));
    imwrite(img1,fullfile(IMG_DIR,[fileList(i).name(1:end-4) '.jpg']));    
    i
end
WORK_DIR = '/home/xiul/databag/dancing';
IMG_DIR = [WORK_DIR,'/image_0'];
OUT_DIR = [WORK_DIR,'/image_0_sample'];

mkdir(OUT_DIR);
i_w = 1531;
i_h = 748;

fileList = dir(fullfile(IMG_DIR,'*.jpg'));
nFile = length(fileList);
sampleF = 5;

for i=1:sampleF:nFile
    fileName = fileList(i).name;    
    copyfile(fullfile(IMG_DIR,fileList(i).name),fullfile(OUT_DIR,fileList(i).name));
    i
end
%Yuna sequence choice
WORK_DIR='~/databag/SFRM/Yuna';

Images = dir(fullfile(WORK_DIR,'skeletons','*.png'));

allFods = dir(fullfile(WORK_DIR,'screenshots'));



nFrames = length(Images);

for i=3:length(allFods)
    cId = str2num(allFods(i).name);
    copyfile(fullfile(WORK_DIR,'skeletons',Images(cId).name),fullfile(WORK_DIR,'screenshots',allFods(i).name,Images(cId).name));    
end

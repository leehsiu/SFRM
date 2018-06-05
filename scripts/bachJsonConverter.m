WORK_DIR = '/home/xiul/databag/girl_dancing';
JSON_DIR = [WORK_DIR,'/image_skeleton_origin'];

fileList = dir(fullfile(JSON_DIR,'*.json'));
nFile = length(fileList);
nKps = 18;
for i=1:nFile
    outName = [JSON_DIR '/' fileList(i).name(1:end-5) '.p2d'];
    jsonString = fileread(fullfile(fileList(i).folder,fileList(i).name));    
    jsonData = jsondecode(jsonString);
    allpeople = jsonData.people;
    [nPeople,~] = size(allpeople);
    
    fileId = fopen(outName,'w');    
    for j=1:nPeople
        Kps = allpeople(j).pose_keypoints;
        Kps = reshape(Kps,[3,18]);       
        fprintf(fileId,'%f %f %f\n',Kps);
    end
    fclose(fileId);
    if(mod(i,10)==0)
        i
    end
    
end
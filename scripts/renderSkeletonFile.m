SKL_DIR = '/home/xiul/databag/10-07_1/image_skeleton';
bone_color= [
         255.0,     0.0,    85.0;
        255.0,     0.0,     0.0;
        255.0,    85.0,     0.0;
        255.0,   170.0,     0.0;
        255.0,   255.0,     0.0;
        170.0,   255.0,     0.0;
         85.0,   255.0,     0.0;
          0.0,   255.0,     0.0;
          0.0,   255.0,    85.0;
          0.0,   255.0,   170.0;
          0.0,   255.0,   255.0;
          0.0,   170.0,   255.0;
          0.0,    85.0,   255.0;
          0.0,     0.0,   255.0;
        255.0,     0.0,   170.0;
        170.0,     0.0,   255.0;
        255.0,     0.0,   255.0;
         85.0,     0.0,   255.0;   
];
bone_pair=[1,2,   1,5,   2,3,   3,4,   5,6,   6,7,   1,8,   8,9,   9,10,  1,11,  11,12, 12,13,  1,0,   0,14, 14,16,  0,15, 15,17];
bone_pair = reshape(bone_pair,[2,length(bone_pair)/2]);
allFiles = dir(fullfile(SKL_DIR,'*.json'));
nFiles = length(allFiles);

fig = figure(1);

for i=1:1:nFiles
    jsonString = fileread(fullfile(SKL_DIR,allFiles(i).name));
    jsonData = jsondecode(jsonString);
    
    curPose = jsonData.people.pose_keypoints;
    curPose = reshape(curPose,[3,length(curPose)/3]);
    
    
    clf(fig);
    axis manual;
    hold on;
    for j=1:1:length(bone_pair) 
        if curPose(3,bone_pair(1,j)+1)>1e-16 && curPose(3,bone_pair(2,j)+1)>1e-16
            plot(curPose(1,bone_pair(:,j)+1),curPose(2,bone_pair(:,j)+1),'Color',bone_color(j,:)./255);
        end
    end        
    h = gca;
    h.YDir = 'reverse';
    xlim([1 720]);
    ylim([1 360]);  
    pbaspect([720 360 1]);
    pause(0.05);
end

close(fig);
WORK_DIR = '~/databag/hand_4';

load(fullfile(WORK_DIR,'allFace3D.mat'));

%%

nFace = length(allFace3D);
for i=1:nFace
    faceName = sprintf('face_%d.txt',i);
    
    if(~isempty(allFace3D{i}))
        fid= fopen(fullfile(WORK_DIR,faceName),'w');
        Le = size(allFace3D{i},1)/3;
        cFace = allFace3D{i};
        for id=1:Le
            fprintf(fid,'%d\n',id);
            fprintf(fid,'%f %f %f\n',cFace(id*3-2:id*3,:));
        end      
          fclose(fid);    
    end        
  
end
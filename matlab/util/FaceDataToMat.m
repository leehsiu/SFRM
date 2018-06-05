% WORK_DIR = '/media/posefs0c/panopticdb/a2/annot_3dface/160224_haggling1';
% AllJson = dir(fullfile(WORK_DIR,'*.json'));
% allFace3D = cell(1);
% for nId = 1:length(AllJson)
%     jsonString = fileread(fullfile(AllJson(nId).folder,AllJson(nId).name));
%     jsonData = jsondecode(jsonString);
%     pP = jsonData.people;
%     for jj=1:length(pP)
%         cId = pP(jj).id;
%         cId = cId+1;
%         c3d = pP(jj).face70.landmarks;
%         c3d = reshape(c3d,[3 70]);
%         if(length(allFace3D)>=cId)
%             cAllKps = allFace3D{cId};
%             cAllKps = [cAllKps;c3d];
%             allFace3D{cId} = cAllKps;
%         else
%             allFace3D{cId} = c3d;
%         end
%     end
% end




WORK_DIR = '/media/posefs0c/panopticdb/a2/annot_3dhand/170221_haggling_b1';
AllJson = dir(fullfile(WORK_DIR,'*.json'));
allFace3D = cell(1);
for nId = 1:length(AllJson)
    jsonString = fileread(fullfile(AllJson(nId).folder,AllJson(nId).name));
    jsonData = jsondecode(jsonString);
    pP = jsonData.people;
    pP
    jsonData
    
    for jj=1:length(pP)      
        if(~iscell(pP))
            cp = pP(jj);            
        else
            cp = pP{jj};
            
        end
        
        
        
        cId = cp.id;
        if(cId<0)
            continue
        end
        
        cId = cId+1;
        if(~isfield(cp,'left_hand'))
            continue;
        end        
        c3d = cp.left_hand.landmarks;
        c3d = reshape(c3d,[3 21]);
        if(length(allFace3D)>=cId)
            cAllKps = allFace3D{cId};
            cAllKps = [cAllKps;c3d];
            allFace3D{cId} = cAllKps;
        else
            allFace3D{cId} = c3d;
        end
    end
end







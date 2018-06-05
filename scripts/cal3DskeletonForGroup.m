function p4dVec = cal3DskeletonForGroup(groupJson,groupPose,K)
%CAL3DSKELETONFORGROUP Summary of this function goes here
%   Detailed explanation goes here
nFrames = length(groupJson);

KeyKps =  getKpsfromJson(fullfile(groupJson(1).folder,groupJson(1).name));

nKps = length(KeyKps);


p4dVec = zeros(4,nKps);


allKps = zeros(3,nKps,nFrames);

for frameId=1:nFrames
   allKps(:,:,frameId) = getKpsfromJson(fullfile(groupJson(frameId).folder,groupJson(frameId).name)); 
end



for kpsId=1:1:nKps
    groupKps = allKps(:,kpsId,:);
    groupKps = reshape(groupKps(:),[3,5]);
    p4dVec(:,kpsId) = calTriangulation(groupPose,groupKps,K);    
end





end
function Kps  = getFaceKpsFromJson( jsonFile )
%GETFACEKPSFROMJSON Summary of this function goes here
%   Detailed explanation goes here
jsonString = fileread(jsonFile);
    jsonData = jsondecode(jsonString);
    npeople = length(jsonData.people);
    allsize = zeros(npeople,1);    
    for i=1:npeople
        curkps = jsonData.people(i).pose_keypoints;
        curkps = reshape(curkps,[3,length(curkps)/3]);
        availb = curkps(3,:)>1e-1;                
        curkps = curkps(:,availb);
        x_max = max(curkps(1,:));
        x_min = min(curkps(1,:));        
        y_max = max(curkps(2,:));
        y_min = min(curkps(2,:));        
        allsize(i) = abs(x_max-x_min)+abs(y_max-y_min);
    end
    [~,curid] = max(allsize);
    Kps = jsonData.people(curid).pose_keypoints;
    Kps = reshape(Kps,[3,length(Kps)/3]);    

end


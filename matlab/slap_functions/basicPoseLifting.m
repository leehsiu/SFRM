function [kps_6d_] = basicPoseLifting(kps_)
%BASICLIFT Summary of this function goes here
%   Detailed explanation goes here
global TORSO_PART;
global KPS_NUM;
allDepth = ones(KPS_NUM,1);
validId = kps_(3,:)>0;

kps3d = kps_.*repmat(allDepth,[3,1]);
var3d = ones(3,18)*100;

if(sum(validId(TORSO_PART))>=5)
    
else
    
end

% normalize


end


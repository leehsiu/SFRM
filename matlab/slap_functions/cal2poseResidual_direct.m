function retResi= cal2poseResidual_direct(kps1,kps2,K_1,K_2)
%CAL2POSERESIDUAL_NEW [retE,retP,retResi,retRigid,retType] = cal2poseResidual_v5(kps1,kps2,K_1,K_2)
%   Detailed explanation goes here

global VALID_KPS_TH;

[~,nKps] = size(kps1);

goodPoll = kps1(3,:)>VALID_KPS_TH & kps2(3,:)>VALID_KPS_TH;
if(sum(goodPoll)<7)
    retResi = 2.236;
    return;
end


E_all = calEssentialFivePoints(kps1(:,goodPoll),kps2(:,goodPoll),K_1,K_2);
nE = length(E_all);
if(isempty(E_all))
    retResi = 1;
    return;
end

allResi = zeros(nE,nKps);
for i=1:nE
    fResi = calAlgebraError(kps1,E_all{i},kps2);
    bResi = calAlgebraError(kps2,E_all{i}',kps1);
    allResi(i,:) = (fResi+bResi)/2;
end
[~,nR] = max(max(allResi(:,goodPoll),[],2));
retResi = max(allResi(nR(1),goodPoll));



end
%function [retResiE,restResiH,restResiT] = cal2poseResidual_MultiLayer(kps1,kps2,EmatCase,nE,nkps)
function [retResiE,restResiH]= cal2poseResidual_FirstLayer(kps1,kps2,nKps)
%CAL2POSERESIDUAL_NEW [retE,retP,retResi,retRigid,retType] = cal2poseResidual_v5(kps1,kps2,K_1,K_2)
%   Detailed explanation goes here




E_all = calEssentialFivePoints(kps1,kps2,eye(3),eye(3));
if isempty(E_all)
    retResiE = 2.236;
    restResiH = 1;
    return;
end
nE = length(E_all);
allResi = zeros(nE,nKps);
for i=1:nE
    fResi = calDEFinal(kps2,E_all{i}, kps1);
    bResi = calDEFinal(kps1,E_all{i}',kps2);
    allResi(i,:) = (fResi+bResi)/2;
end
[~,nR] = min(sum(allResi.^2,2));


Hmat = calHomographyMatrix(kps1,kps2);
Hresi  = (calDHFinal(kps2,Hmat,kps1));

dEmax = sum(allResi(nR(1),:).^2);

dHmax = sum(Hresi);
retResiE = dEmax;
restResiH = dHmax;

end
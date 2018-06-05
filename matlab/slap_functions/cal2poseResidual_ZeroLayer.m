%function [retResiE,restResiH,restResiT] = cal2poseResidual_MultiLayer(kps1,kps2,EmatCase,nE,nkps)
function [retResiE,restResiH,restResiT]= cal2poseResidual_ZeroLayer(kps1,kps2)
%CAL2POSERESIDUAL_NEW [retE,retP,retResi,retRigid,retType] = cal2poseResidual_v5(kps1,kps2,K_1,K_2)
%   Detailed explanation goes here
E_all = calEssentialEightPoints(kps1,kps2);

fResi = calDEFinal(kps2,E_all, kps1);
bResi = calDEFinal(kps1,E_all',kps2);
allResi = (fResi+bResi)/2;

Hmat = calHomographyMatrix(kps1,kps2);
Hresi  = (calDHFinal(kps1,Hmat,kps2));
dEmax = max(allResi);
dHmax = max(Hresi);
retResiE = dEmax;
restResiH = dHmax;
restResiT = norm(E_all'*Hmat+Hmat'*E_all);
end
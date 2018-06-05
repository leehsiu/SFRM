function [retResiE,restResiH] = cal2poseResidual_MultiLayer(kps1,kps2,EmatCase,nE,nkps)
%   Detailed explanation goes here

%EMAT_MAX =  2.236;
%Pose residuals \eta = dE / dH

dE = zeros(nE,nkps);



% cac dE
for i=1:nE
    tmpPoll = EmatCase(i,:);
    Emat = solveE(kps1(:,tmpPoll),kps2(:,tmpPoll));
    sovN = size(Emat,3);
    if(sovN>0)
        tmpResi = zeros(sovN,nkps);
        for j=1:sovN
            tmpResi(j,:) = (calDEFinal(kps1,Emat(:,:,j),kps2)+calDEFinal(kps2,Emat(:,:,j)',kps1))/2;
        end
        [~,mE] = min(max(tmpResi,[],2));
        dE(i,:) = tmpResi(mE(1),:);
    end    
end
dEmax = max(max(dE,[],2));
Hmat = calHomographyMatrix(kps1,kps2);
Hresi  = calDHFinal(kps2,Hmat,kps1);
dHmax = max(Hresi);
% for i=1:nH
%     tmpPoll = HmatComb((rankH(i)),:);
%     
%     tmpResi = (calDHFinal(kps2(:,matchId),Hmat,kps1(:,matchId)) + calDHFinal(kps1(:,matchId),inv(Hmat),kps2(:,matchId)))/2;
%     (i,:) = tmpResi;
% end
% dHmin = min(max(dH,[],2));
%retResi = dEmax/(dHmin+1e-10);
retResiE = dEmax;
restResiH = dHmax;

end
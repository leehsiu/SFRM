function [dEmax,dHmax] = cal2poseResidual_FiveSample(kps1,kps2,EmatCase,nkps)
%   Detailed explanation goes here


%Pose residuals \eta = dE / dH
nE = size(EmatCase,1);
dE = zeros(nE,nkps);
% cac dE
for i=1:nE
    Emat = solveE_nister(kps1(:,EmatCase(i,:)),kps2(:,EmatCase(i,:)));
    sovN = size(Emat,3);
    if(sovN>0)
        tmpResi = zeros(sovN,nkps);
        for j=1:sovN
            tmpResi(j,:) = (calDEFinal(kps1,Emat(:,:,j),kps2)+calDEFinal(kps2,Emat(:,:,j)',kps1))/2;
        end
        [~,mE] = min(sum(tmpResi.^2,2));
        dE(i,:) = tmpResi(mE(1),:);
    end    
end

dEmax = max(sum(dE.^2,2));
Hmat = calHomographyMatrix(kps1,kps2);
Hresi  = calDHFinal(kps1,Hmat,kps2);
dHmax = sum(Hresi.^2);
end
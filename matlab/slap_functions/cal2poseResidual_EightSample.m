function [ dEmax,dHmax ] = cal2poseResidual_EightSample(kps1,kps2,EmatCase,nE,HmatCase,nH,nkps)
%CAL2POSERESIDUAL_EIGHTSAMPLE Summary of this function goes here
%   Detailed explanation goes here

dE = zeros(nE,nkps);
% cac dE
for i=1:nE    
    tmpPoll = EmatCase(i,:);
    Emat = calEssentialFivePoints(kps1(:,tmpPoll),kps2(:,tmpPoll),eye(3),eye(3));
    sovN = length(Emat);
    if(sovN>0)
        tmpResi = zeros(sovN,nkps);
        for j=1:sovN
            tmpResi(j,:) = (calDEFinal(kps2,Emat{j},kps1)+calDEFinal(kps1,Emat{j}',kps2))/2;
        end
        [~,mE] = min(sum(tmpResi.^2,2));
        dE(i,:) = tmpResi(mE(1),:);
    end
end

%dEmax = max(max(dE,[],2));
dEmax = max(sum(dE.^2,2));

dH = zeros(nH,nkps);
for i=1:nH
    tmpPoll = HmatCase(i,:);
    Hmat = calHomographyMatrix(kps1(:,tmpPoll),kps2(:,tmpPoll));
    dH(i,:) = calDHFinal(kps2,Hmat,kps1);
end

dHmax = max(sum(dH.^2,2));
end


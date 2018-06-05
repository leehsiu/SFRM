function [retE,retP,retResi,retRigid,retType] = cal2poseResidual_v6(kps1,kps2,K)
%CAL2POSERESIDUAL_NEW Summary of this function goes here
%   Detailed explanation goes here
global GOOD_PAIR_TH;
global maxResi;
wG = 1531;
hG = 748;
wG = wG/K(1,1);
hG = hG/K(2,2);
maxResi = sqrt(wG^2+hG^2);

nKps = length(kps1);
TorsoId = [1 2 5 8 11]; %neck is virtual /%The trunk of body which should always be usesd
TorsoId = TorsoId+1;

NearId = [0 3 6 9 12];
NearId = NearId+1;

FarId = [4 7 10 13];
FarId = FarId+1;



TorsoIdPair = kps1(3,TorsoId)>GOOD_PAIR_TH&kps2(3,TorsoId)>GOOD_PAIR_TH;
NearIdPair = kps1(3,NearId)>GOOD_PAIR_TH&kps2(3,NearId)>GOOD_PAIR_TH;
FarIdPair = kps1(3,FarId)>GOOD_PAIR_TH&kps2(3,FarId)>GOOD_PAIR_TH;

%The naivest method
if(sum(TorsoIdPair)<length(TorsoId))
    retE = [eye(3) eye(3)];
    retResi = zeros(1,nKps)+maxResi;
    retP = [zeros(3,4) zeros(3,4)];
    retRigid = TorsoId(TorsoIdPair);
    retType='NA';
    return;
end
%pixel plane to film plane
%Normalilze

kps1(3,:) = 1;
kps2(3,:) = 1;
kps1 = K\kps1;
kps2 = K\kps2;
K_1 = K;
K_2 = K;




Homo1x2 = calHomographyMatrix(kps1(:,TorsoId),kps2(:,TorsoId));
Homo2x1 = calHomographyMatrix(kps2(:,TorsoId),kps1(:,TorsoId));

H1H2 = Homo1x2*Homo2x1;
H2H1 = Homo2x1*Homo1x2;
if(H1H2(2,2)<0)
    resiH1H2 = norm(H1H2+eye(3));
else
    resiH1H2 = norm(H1H2-eye(3));
end
if(H2H1(2,2)<0)
    resiH2H1 = norm(H2H1+eye(3));
else
    resiH2H1 = norm(H2H1-eye(3));
end

%add troso to poll. 4 point not enough to define a Essential Matrix
rigidPoll = TorsoId;

if(sum(NearIdPair)<2)
    retE = [eye(3) eye(3)];
    retResi = zeros(1,nKps)+maxResi;
    retP = [zeros(3,4) zeros(3,4)];
    retRigid = TorsoId(TorsoIdPair);
    retType='NA';
    return;
end


%start the thread: 1 try add near
combNear = nchoosek(NearId(NearIdPair),2);
[ncombNear,~]=size(combNear);
NearResi = zeros(ncombNear,nKps);

for i=1:ncombNear
    tmpRigidPoll=[rigidPoll combNear(i,:)];
    
    [E_ini1x2,~,~,~] = calEssentialFivePoints(kps1(:,tmpRigidPoll),kps2(:,tmpRigidPoll),K_1,K_2);
    [E_ini2x1,~,~,~] = calEssentialFivePoints(kps2(:,tmpRigidPoll),kps1(:,tmpRigidPoll),K_1,K_2);
    curResi1x2 = zeros(length(E_ini1x2),length(tmpRigidPoll));
    curResi2x1 = zeros(length(E_ini2x1),length(tmpRigidPoll));
    for j=1:length(E_ini1x2)
        epl2 = E_ini1x2{j}*kps1(:,tmpRigidPoll);
        resi2 = abs(diag(epl2'*kps2(:,tmpRigidPoll)))';
        resi2 = resi2./sqrt(epl2(1,:).^2+epl2(2,:).^2);
        curResi1x2(j,:) = resi2;
    end
    
    for j=1:length(E_ini2x1)
        epl1 = E_ini2x1{j}*kps2(:,tmpRigidPoll);
        resi1 = abs(diag(epl1'*kps1(:,tmpRigidPoll)))';
        resi1 = resi1./sqrt(epl1(1,:).^2+epl1(2,:).^2);
        curResi2x1(j,:) = resi1;
    end
    
    [~,Eid1] = min(max(curResi1x2,[],2));
    [~,Eid2] = min(max(curResi2x1,[],2));
    if(~isempty(Eid1))
        cE_1x2 = E_ini1x2{Eid1};
        cE_2x1 = E_ini2x1{Eid2};
        
        epl2 = cE_1x2*kps1(:,[rigidPoll NearId(NearIdPair)]);
        resi2 = abs(diag(epl2'*kps2(:,[rigidPoll NearId(NearIdPair)])))';
        resi2 = resi2./sqrt(epl2(1,:).^2+epl2(2,:).^2);
        
        
        epl1 = cE_2x1*kps2(:,[rigidPoll NearId(NearIdPair)]);
        resi1 = abs(diag(epl1'*kps1(:,[rigidPoll NearId(NearIdPair)])))';
        resi1 = resi1./sqrt(epl1(1,:).^2+epl1(2,:).^2);
        
        NearResi(i,[rigidPoll NearId(NearIdPair)]) = (resi2+resi1)/2;
    else
        NearResi(i,[rigidPoll NearId(NearIdPair)]) = maxResi;
    end
    
end

[~,comId] = min(max(NearResi(:,rigidPoll),[],2));
rigidPollNear = [rigidPoll combNear(comId,:)];


if(sum(FarIdPair)<2)
    retE = [eye(3) eye(3)];
    retResi = zeros(1,nKps)+maxResi;
    retP = [zeros(3,4) zeros(3,4)];
    retRigid = TorsoId(TorsoIdPair);
    retType='NA';
    return;
end

combFar = nchoosek(FarId(FarIdPair),2);
[ncombFar,~]=size(combFar);
FarResi = zeros(ncombFar,nKps);
P_ini1x2 = zeros(3,4,ncombFar);
P_ini2x1 = zeros(3,4,ncombFar);
E_ret1x2 = zeros(3,3,ncombFar);
E_ret2x1 = zeros(3,3,ncombFar);
for i=1:ncombFar
    tmpRigidPoll=[rigidPollNear combFar(i,:)];
    
    [E_ini1x2,R_ini1x2,t_ini1x2,~] = calEssentialFivePoints(kps1(:,tmpRigidPoll),kps2(:,tmpRigidPoll),K_1,K_2);
    [E_ini2x1,R_ini2x1,t_ini2x1,~] = calEssentialFivePoints(kps2(:,tmpRigidPoll),kps1(:,tmpRigidPoll),K_1,K_2);
    curResi1x2 = zeros(length(E_ini1x2),length(tmpRigidPoll));
    curResi2x1 = zeros(length(E_ini2x1),length(tmpRigidPoll));
    for j=1:length(E_ini1x2)
        epl2 = E_ini1x2{j}*kps1(:,tmpRigidPoll);
        resi2 = abs(diag(epl2'*kps2(:,tmpRigidPoll)))';
        resi2 = resi2./sqrt(epl2(1,:).^2+epl2(2,:).^2);
        curResi1x2(j,:) = resi2;
    end
    for j=1:length(E_ini2x1)
        epl1 = E_ini2x1{j}*kps2(:,tmpRigidPoll);
        resi1 = abs(diag(epl1'*kps1(:,tmpRigidPoll)))';
        resi1 = resi1./sqrt(epl1(1,:).^2+epl1(2,:).^2);
        curResi2x1(j,:) = resi1;
    end
    [~,Eid1] = min(max(curResi1x2,[],2));
    [~,Eid2] = min(max(curResi2x1,[],2));
    
    if(~isempty(Eid1))
        cE_1x2 = E_ini1x2{Eid1};
        cE_2x1 = E_ini2x1{Eid2};
        P_ini1x2(:,:,i) = [R_ini1x2{Eid1} t_ini1x2{Eid1}];
        P_ini2x1(:,:,i) = [R_ini2x1{Eid2} t_ini2x1{Eid2}];
        E_ret1x2(:,:,i) = cE_1x2;
        E_ret2x1(:,:,i) = cE_2x1;
        epl2 = cE_1x2*kps1(:,[TorsoId NearId(NearIdPair) FarId(FarIdPair)]);
        resi2 = abs(diag(epl2'*kps2(:,[TorsoId NearId(NearIdPair) FarId(FarIdPair)])))';
        resi2 = resi2./sqrt(epl2(1,:).^2+epl2(2,:).^2);
        
        
        epl1 = cE_2x1*kps2(:,[TorsoId NearId(NearIdPair) FarId(FarIdPair)]);
        resi1 = abs(diag(epl1'*kps1(:,[TorsoId NearId(NearIdPair) FarId(FarIdPair)])))';
        resi1 = resi1./sqrt(epl1(1,:).^2+epl1(2,:).^2);
        
        FarResi(i,[TorsoId NearId(NearIdPair) FarId(FarIdPair)]) = resi2+resi1;
    else
        FarResi(i,[TorsoId NearId(NearIdPair) FarId(FarIdPair)]) = maxResi;
    end
    
    
end
[~,comId] = min(max(FarResi(:,rigidPollNear),[],2));
rigidPollFar = [rigidPollNear combFar(comId,:)];
retResi = zeros(1,nKps)+maxResi;
retResi([TorsoId NearId(NearIdPair) FarId(FarIdPair)]) = FarResi(comId,[TorsoId NearId(NearIdPair) FarId(FarIdPair)]);
retResi(end) = resiH1H2+resiH2H1;
resiHE1 = norm(Homo1x2'*E_ret1x2(:,:,comId)+E_ret1x2(:,:,comId)'*Homo1x2);
resiHE2 = norm(Homo2x1'*E_ret2x1(:,:,comId)+E_ret2x1(:,:,comId)'*Homo2x1);
retResi(end-1) = resiHE1+resiHE2;
retRigid = rigidPollFar;
retE = [E_ret1x2(:,:,comId) E_ret2x1(:,:,comId)];
retP = [P_ini1x2(:,:,comId) P_ini2x1(:,:,comId)];
retType = 'NORMAL';
end
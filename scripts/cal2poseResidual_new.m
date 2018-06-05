function [Essential,residual,resultType] = cal2poseResidual_new(kps1,kps2,K)
%CAL2POSERESIDUAL_NEW Summary of this function goes here
%   Detailed explanation goes here
global GOOD_PAIR_TH;
global FILM_DIS_TH;
global GUI_SHOW;
TorsoId = [2 5 8 11];
TorsoId = TorsoId+1;
nTorso = length(TorsoId);

FreeId = [3 4 6 7 9 10 12 13]; %without noses
FreeId = FreeId+1;


Torso1score = kps1(3,TorsoId);
Torso2score = kps2(3,TorsoId);
torsoPairNum = sum(Torso1score>0.5&Torso2score>0.5);
if(torsoPairNum<nTorso)
    residual = 1;
    Essential = eye(3);
    resultType = 'DEG';
    return ;
end

free1score = kps1(3,FreeId);
free2score = kps2(3,FreeId);
pairId = ((free1score.*free2score) > GOOD_PAIR_TH);
c_nh = FreeId(pairId);




[K_1,K_R1] = kpsNormalize(kps1,K);
[K_2,K_R2] = kpsNormalize(kps2,K);

kps1(3,:) = 1;
kps2(3,:) = 1;
kps1 = K\kps1;
kps2 = K\kps2;
kps1 = K_R1\kps1;
kps2 = K_R2\kps2;
kps1(1,:) = kps1(1,:)./kps1(3,:);
kps1(2,:) = kps1(2,:)./kps1(3,:);
kps1(3,:) = 1;
kps2(1,:) = kps2(1,:)./kps2(3,:);
kps2(2,:) = kps2(2,:)./kps2(3,:);
kps2(3,:) = 1;
kps1 = K_1\kps1;
kps2 = K_2\kps2;



torso1Kps = kps1(:,TorsoId);
torso2Kps = kps2(:,TorsoId);
free1Kps = kps1(:,c_nh);
free2Kps = kps2(:,c_nh);



Hmat1 = calHomographyMatrix(torso1Kps,torso2Kps);
Hmat2 = calHomographyMatrix(torso2Kps,torso1Kps);
%Hmat2 = Hmat2./Hmat2(3,3);



free1rep = Hmat2*free2Kps;
free1rep(1,:) = free1rep(1,:)./free1rep(3,:);
free1rep(2,:) = free1rep(2,:)./free1rep(3,:);
free1rep(3,:) = 1;

free2rep = Hmat1*free1Kps;
free2rep(1,:) = free2rep(1,:)./free2rep(3,:);
free2rep(2,:) = free2rep(2,:)./free2rep(3,:);
free2rep(3,:) = 1;

torso1rep = Hmat2*torso2Kps;
torso1rep(1,:) = torso1rep(1,:)./torso1rep(3,:);
torso1rep(2,:) = torso1rep(2,:)./torso1rep(3,:);
torso1rep(3,:) = 1;
torso2rep = Hmat1*torso1Kps;
torso2rep(1,:) = torso2rep(1,:)./torso2rep(3,:);
torso2rep(2,:) = torso2rep(2,:)./torso2rep(3,:);
torso2rep(3,:) = 1;





% next
activeNum = length(c_nh);

fig = figure(1);

subplot(2,2,3);

plot(free1Kps(1,:),free1Kps(2,:),'r*');
hold on;
axis ij;
plot(free1rep(1,:),free1rep(2,:),'bo');
for ii=1:length(free1Kps)
    plot([free1rep(1,ii) free1Kps(1,ii)],[free1rep(2,ii) free1Kps(2,ii)],'r:');
end
plot(torso1rep(1,:),torso1rep(2,:),'g^');
daspect([1 1 1]);
subplot(2,2,4);
plot(free2Kps(1,:),free2Kps(2,:),'r*');
hold on;
plot(free2rep(1,:),free2rep(2,:),'bo');
plot(torso2rep(1,:),torso2rep(2,:),'g^');
for ii=1:length(free2Kps)
    plot([free2rep(1,ii) free2Kps(1,ii)],[free2rep(2,ii) free2Kps(2,ii)],'r:');
end
axis ij;
daspect([1 1 1]);
pause;
HrepResi1 = (free1rep - free1Kps);
HrepResi2 = (free2rep - free2Kps);

HrepResiNorm1 = sqrt(sum(abs(HrepResi1).^2,1));
HrepResiNorm2 = sqrt(sum(abs(HrepResi2).^2,1));

%The very initial torso part
goodMask = (HrepResiNorm1>FILM_DIS_TH)&(HrepResiNorm2>FILM_DIS_TH);


usedNum = sum(goodMask);
if(usedNum==0&&activeNum>0)
    %degenerated, in a plane
    Essential = Hmat2;
    residual = 0;
    resultType = 'HOMO';
else
    %RANSAC here/ currently Linear
    % (usedNum)
    % (   2   )
    acch = 1:activeNum;
    ss = acch(goodMask);
    Comb = nchoosek(ss,2);
    
    nComb = usedNum*(usedNum-1)/2;
    allDist = zeros(nComb,1);
    for combId=1:nComb
        ll11=cross(free1rep(:,Comb(combId,1)),free1Kps(:,Comb(combId,1)));
        ll12=cross(free1rep(:,Comb(combId,2)),free1Kps(:,Comb(combId,2)));
        
        ll21 = cross(free2rep(:,Comb(combId,1)),free2Kps(:,Comb(combId,1)));
        ll22 = cross(free2rep(:,Comb(combId,2)),free2Kps(:,Comb(combId,2)));
        
        
        epipole1 = cross(ll11,ll12);
        
        epipole2 = cross(ll21,ll22);
        
        tts = setdiff(acch,Comb(combId,:));
        maxDist = zeros(length(tts),1);
        for ttsId=1:length(tts)
            
            epl1 = cross(epipole1,free1rep(:,tts(ttsId)));
            epl1c = sqrt(epl1(1)^2+epl1(2)^2);
            dist1 = abs(epl1'*free1Kps(:,tts(ttsId)))/epl1c;
            
            epl2 = cross(epipole2,free2rep(:,tts(ttsId)));
            epl2c = sqrt(epl2(1)^2+epl2(2)^2);
            dist2 = abs(epl2'*free2Kps(:,tts(ttsId)))/epl2c;
            
            meanDist = max(dist1,dist2);
            maxDist(ttsId) = meanDist;
        end
        %pb1 = exp(-ggs/dist2prob);
        %extraPower = 0.5^(9-activeNum);
        allDist(combId) = max(maxDist);
        
    end
    [residual,~] = max(allDist);
    [residual2,combId] = min(allDist);
    ll1 = cross(free1rep(:,Comb(combId,1)),free1Kps(:,Comb(combId,1)));
    ll2 = cross(free1rep(:,Comb(combId,2)),free1Kps(:,Comb(combId,2)));
    epipole1 = cross(ll1,ll2);
    epipole1N = epipole1./norm(epipole1);
    
    Essential = [0 -epipole1N(3) epipole1N(2);epipole1N(3) 0 -epipole1N(1);-epipole1N(2) epipole1N(1) 0]*Hmat2;
    resultType = 'E';
    
    if GUI_SHOW
        fig = figure();
        figure(fig);
        hold on;
        plot(free1rep(1,:),free1rep(2,:),'ro');
        plot(torso1rep(1,:),torso1rep(2,:),'go');
        plot(free1Kps(1,:),free1Kps(2,:),'b*');
        %plot(epipole1N(1)/epipole1N(3),epipole1N(2),'g^');
        
        for i=1:usedNum
            %plot([Hrep2c(1,i) Homo2c(1,i)],[Hrep2c(2,i) Homo2c(2,i)],':','LineWidth',2);
            epl = cross(epipole1N,free1rep(:,i));
            
            regard1 = zeros(3,1);
            regard1(1) = (epl(2)*(epl(2)*free1Kps(1,i)-epl(1)*free1Kps(2,i))-epl(1)*epl(3))/(epl(1)^2+epl(2)^2);
            regard1(2) = (epl(1)*(-epl(2)*free1Kps(1,i)+epl(1)*free1Kps(2,i))-epl(2)*epl(3))/(epl(1)^2+epl(2)^2);
            regard1(3) = 1.0;
            
            plot([regard1(1) free1Kps(1,i)],[regard1(2) free1Kps(2,i)],'-.');
            plot([epipole1N(1)/epipole1N(3) free1rep(1,i)],[epipole1N(2)/epipole1N(3) free1rep(2,i)],'-.');
            
        end
        axis ij;
        xlim manual;
        xlim([-2 2]);
        ylim manual;
        ylim([-2 2]);
        daspect([1 1 1])
        
    end
end
end


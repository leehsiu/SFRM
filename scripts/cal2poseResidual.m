function [Essential,residual,resultType] = cal2poseResidual(kps1,kps2,K)
%CAL2POSERESIDUAL Summary of this function goes here
%   Detailed explanation goes here
global GOOD_PAIR_TH;
global FILM_DIS_TH;
global bone_color;
global GUI_SHOW;
global dist2prob;
global fig;
HomoId = [1 2 5 8 11];
HomoId = HomoId+1;
nHomo = length(HomoId);

%nonHomoId = [0 3 4 6 7 9 10 12 13];
nonHomoId = [3 4 6 7 9 10 12 13]; %without noses
nonHomoId = nonHomoId+1;


homo1score = kps1(3,HomoId);
homo2score = kps2(3,HomoId);
homopairId = homo1score>0.5&homo2score>0.5;
if(sum(homopairId)<5)
    residual = 0;
    Essential = eye(3);
    resultType = 'DEG';
    return ;
end



kps1score = kps1(3,nonHomoId);
kps2score = kps2(3,nonHomoId);
pairId = ((kps1score.*kps2score) > GOOD_PAIR_TH);
c_nh = nonHomoId(pairId);


%calc Homography
HomoKps1= kps1;
HomoKps2= kps2;
HomoKps1(3,:) = 1;
HomoKps2(3,:) = 1;


HomoKps1 = K\HomoKps1;
HomoKps2 = K\HomoKps2;

%another nomalization
activeKps1 = HomoKps1(:,[HomoId c_nh]);
activeKps2 = HomoKps2(:,[HomoId c_nh]);

x_1 = mean(activeKps1(1,:));
y_1 = mean(activeKps1(2,:));
x_2 = mean(activeKps2(1,:));
y_2 = mean(activeKps2(2,:));

k1_theta_y = atan(x_1);
k1_theta_x = atan(y_1);

k2_theta_y = atan(x_2);
k2_theta_x = atan(y_2);
RK1 = eul2rotm([0 k1_theta_y -k1_theta_x],'ZYX');
RK2 = eul2rotm([0 k2_theta_y -k2_theta_x],'ZYX');
HomoKps1 = RK1\HomoKps1;
HomoKps2 = RK2\HomoKps2;

HomoKps1(1,[HomoId c_nh]) = HomoKps1(1,[HomoId c_nh])./HomoKps1(3,[HomoId c_nh]);
HomoKps1(2,[HomoId c_nh]) = HomoKps1(2,[HomoId c_nh])./HomoKps1(3,[HomoId c_nh]);
HomoKps2(1,[HomoId c_nh]) = HomoKps2(1,[HomoId c_nh])./HomoKps2(3,[HomoId c_nh]);
HomoKps2(2,[HomoId c_nh]) = HomoKps2(2,[HomoId c_nh])./HomoKps2(3,[HomoId c_nh]);

HomoKps1(3,[HomoId c_nh]) = 1;
HomoKps2(3,[HomoId c_nh]) = 1;

tmpKp1 = HomoKps1(1:2,[HomoId c_nh]);
tmpKp2 = HomoKps2(1:2,[HomoId c_nh]);

RK1_f = max(abs(tmpKp1(:)));
RK2_f = max(abs(tmpKp2(:)));
RK1_K = [RK1_f 0 0;0 RK1_f 0;0 0 1];
RK2_K = [RK2_f 0 0;0 RK2_f 0;0 0 1];


HomoKps1 = RK1_K\HomoKps1;
HomoKps2 = RK2_K\HomoKps2;







AHomo = zeros(nHomo*2,9);
BHomo = zeros(nHomo*2,9);
for i=1:nHomo
    AHomo(i*2-1,:)=[-HomoKps1(:,HomoId(i))' 0 0 0 HomoKps2(1,HomoId(i))*HomoKps1(:,HomoId(i))'];
    AHomo(i*2,:)= [0 0 0  -HomoKps1(:,HomoId(i))' HomoKps2(2,HomoId(i))*HomoKps1(:,HomoId(i))'];
    BHomo(i*2-1,:)=[-HomoKps2(:,HomoId(i))' 0 0 0 HomoKps1(1,HomoId(i))*HomoKps2(:,HomoId(i))'];
    BHomo(i*2,:)= [0 0 0  -HomoKps2(:,HomoId(i))' HomoKps1(2,HomoId(i))*HomoKps2(:,HomoId(i))'];
end
[~, ~, VAHomo] = svd(AHomo);
[~, ~, VBHomo] = svd(BHomo);

Hmat1 = (reshape(VAHomo(:,9),[3,3]))';
Hmat2 = (reshape(VBHomo(:,9),[3,3]))';


Hrep2 = Hmat1*HomoKps1;
Hrep2(1,:) = Hrep2(1,:)./Hrep2(3,:);
Hrep2(2,:) = Hrep2(2,:)./Hrep2(3,:);
Hrep2(3,:) = 1;



Hrep1 = Hmat2*HomoKps2;
Hrep1(1,:) = Hrep1(1,:)./Hrep1(3,:);
Hrep1(2,:) = Hrep1(2,:)./Hrep1(3,:);
Hrep1(3,:) = 1;

% next
activeNum = length(c_nh);

Hrep2c = Hrep2(:,c_nh);
Homo2c = HomoKps2(:,c_nh);

Hrep1c = Hrep1(:,c_nh);
Homo1c = HomoKps1(:,c_nh);


HrepResi1 = (Hrep1c - Homo1c);
HrepResi2 = (Hrep2c - Homo2c);


HrepResiNorm1 = sqrt(sum(abs(HrepResi1).^2,1));
HrepResiNorm2 = sqrt(sum(abs(HrepResi2).^2,1));


inPlaneMask = (HrepResiNorm1<FILM_DIS_TH)&(HrepResiNorm2<FILM_DIS_TH);
goodMask = (HrepResiNorm1>FILM_DIS_TH)&(HrepResiNorm2>FILM_DIS_TH);
wrongMask = xor(HrepResiNorm1>FILM_DIS_TH,HrepResiNorm2>FILM_DIS_TH);

usedNum = sum(goodMask);
if(usedNum==0)
    %degenerated, in a plane
    Essential = Hmat1;
    residual = 0;
    resultType = 'HOMO';
elseif(usedNum==1)
    %5-point-here
    Essential = Hmat1;
    residual = 0;
    resultType = 'HOMO';
    % elseif(usedNum==2)
    %     %6-point-here
    %     Essential = Hmat;
    %     residual = 0;
    %     resultType = 'HOMO';
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
        ll11=cross(Hrep1c(:,Comb(combId,1)),Homo1c(:,Comb(combId,1)));
        ll12=cross(Hrep1c(:,Comb(combId,2)),Homo1c(:,Comb(combId,2)));

        ll21 = cross(Hrep2c(:,Comb(combId,1)),Homo2c(:,Comb(combId,1)));
        ll22 = cross(Hrep2c(:,Comb(combId,2)),Homo2c(:,Comb(combId,2)));
 
        
        
        epipole1 = cross(ll11,ll12);
     
        epipole2 = cross(ll21,ll22);

        
        tts = setdiff(acch,Comb(combId,:));
        maxDist = zeros(length(tts),1);
        for ttsId=1:length(tts)
            
                epl1 = cross(epipole1,Hrep1c(:,tts(ttsId)));
                epl1c = sqrt(epl1(1)^2+epl1(2)^2);
                dist1 = abs(epl1'*Homo1c(:,tts(ttsId)))/epl1c;
                
                epl2 = cross(epipole2,Hrep2c(:,tts(ttsId)));
                epl2c = sqrt(epl2(1)^2+epl2(2)^2);
                dist2 = abs(epl2'*Homo2c(:,tts(ttsId)))/epl2c;
                
                meanDist = max(dist1,dist2);                
                maxDist(ttsId) = meanDist;            
        end
        %pb1 = exp(-ggs/dist2prob);
        %extraPower = 0.5^(9-activeNum);
        allDist(combId) = max(maxDist);        
        
    end        
    [residual,combId] = max(allDist);
    
    ll1 = cross(Hrep2c(:,Comb(combId,1)),Homo2c(:,Comb(combId,1)));
    ll2 = cross(Hrep2c(:,Comb(combId,2)),Homo2c(:,Comb(combId,2)));
    fc1 = sqrt(ll1(1)^2+ll1(2)^2);
    ll1 = ll1./fc1;
    fc2 = sqrt(ll2(1)^2+ll2(2)^2);
    ll2 = ll2./fc2;
    epipole1 = cross(ll1,ll2);
    epipole1N = epipole1./norm(epipole1);
    
    %     Aee = zeros(usedNum,3);
    
    %     for i=1:usedNum
    %         Aee(i,:) = cross(Hrep2c(:,(sortId(i))),Homo2c(:,(sortId(i))))';
    %         ae = Aee(i,1);
    %         be = Aee(i,2);
    %         Aee(i,:) = Aee(i,:)./(sqrt(ae^2+be^2));
    %     end
    %
    %     [~,sigAee,Vaee] = svd(Aee);
    %
    %
    %
    %     ee1 = Vaee(:,end);
    %     ee1(1) = ee1(1)/ee1(3);
    %     ee1(2) = ee1(2)/ee1(3);
    %     ee1(3) = 1;
    %     residual = max(abs(Aee*ee1));
    %
    %     resultType='E';
    Essential = [0 -epipole1N(3) epipole1N(2);epipole1N(3) 0 -epipole1N(1);-epipole1N(2) epipole1N(1) 0]*Hmat1;
    resultType = 'E';
    if GUI_SHOW
        
        figure(fig);
        subplot(2,2,2);
        hold on;
        plot(Hrep2c(1,:),Hrep2c(2,:),'ro');
        plot(Hrep2(1,HomoId),Hrep2(2,HomoId),'go');
        plot(Homo2c(1,:),Homo2c(2,:),'b*');
        plot(HomoKps2(1,HomoId),HomoKps2(2,HomoId),'g*');
        %plot(epipole1N(1)/epipole1N(3),epipole1N(2),'g^');
        
        for i=1:usedNum
            %plot([Hrep2c(1,i) Homo2c(1,i)],[Hrep2c(2,i) Homo2c(2,i)],':','LineWidth',2);
            epl = cross(epipole1N,Hrep2c(:,i));
            
            regard1 = zeros(3,1);
            regard1(1) = (epl(2)*(epl(2)*Homo2c(1,i)-epl(1)*Homo2c(2,i))-epl(1)*epl(3))/(epl(1)^2+epl(2)^2);
            regard1(2) = (epl(1)*(-epl(2)*Homo2c(1,i)+epl(1)*Homo2c(2,i))-epl(2)*epl(3))/(epl(1)^2+epl(2)^2);
            regard1(3) = 1.0;
            
            plot([regard1(1) Homo2c(1,i)],[regard1(2) Homo2c(2,i)],'-.');
            plot([epipole1N(1)/epipole1N(3) Hrep2c(1,i)],[epipole1N(2)/epipole1N(3) Hrep2c(2,i)],'-.');
            
        end
        axis ij;        
        xlim manual;
        xlim([-1 1]);
        ylim manual;
        ylim([-1 1]);
        daspect([1 1 2])
        
    end
end
end
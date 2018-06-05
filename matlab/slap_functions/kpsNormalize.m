function [K_n,K_R,kps1_norm] = kpsNormalize( kps1,K )
%KPSNORMALIZE output  K_n, K_r, Kps_norm   input kps , K
global VALID_KPS_TH;
global OLD_VERSION;
global TORSO_PART;
if(sum(kps1(3,TORSO_PART)>VALID_KPS_TH)<5)
    K_n = zeros(3,3);
    K_R = zeros(3,3);
    kps1_norm = zeros(3,18);
    kps1_norm(3,:) = -1;
    return;
end
validId = kps1(3,:)>VALID_KPS_TH;

allkps = kps1;
allkps(3,:) = 1;

activeKps = kps1(:,TORSO_PART);
activeKps(3,:) = 1;
activeKps = K\activeKps;
allkps = K\allkps;

kpsmean=mean(activeKps(1:2,:),2);
K_theta_y = atan(kpsmean(1));
K_theta_x = atan(kpsmean(2)/(sqrt(kpsmean(1)^2+1)));

if OLD_VERSION
    K_R = eul2rotm_server([0 K_theta_y -K_theta_x],'ZYX');
else   
    K_R = eul2rotm([0 K_theta_y -K_theta_x],'ZYX');
end

activeKps_rot = K_R\activeKps;
allkps_rot = K_R\allkps;
activeKps_rot(1,:) = activeKps_rot(1,:)./activeKps_rot(3,:);
activeKps_rot(2,:) = activeKps_rot(2,:)./activeKps_rot(3,:);

allkps_rot(1,:) = allkps_rot(1,:)./allkps_rot(3,:);
allkps_rot(2,:) = allkps_rot(2,:)./allkps_rot(3,:);
allkps_rot(3,:) = 1;

m_dist = max(sqrt(activeKps_rot(1,:).^2+activeKps_rot(2,:).^2));
m_f = m_dist/sqrt(2);
K_f = diag([m_f m_f 1]);

kps1_norm = K_f\allkps_rot;
kps1_norm(3,~validId)= -1;
K_n = K_f*diag([K(1,1) K(2,2) 1]);

end


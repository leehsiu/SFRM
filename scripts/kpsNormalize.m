function [K_f,K_R ] = kpsNormalize( kps1,K )
%KPSNORMALIZE Summary of this function goes here
%   Detailed explanation goes here
TorsoId = [1 2 5 8 11];
TorsoId = TorsoId+1;
activeKps = kps1(:,TorsoId);
activeKps(3,:) = 1;
activeKps = K\activeKps;
kpsmean=mean(activeKps(1:2,:),2);
K_theta_y = atan(kpsmean(1));
K_theta_x = atan(kpsmean(2)/(sqrt(kpsmean(1)^2+1)));
K_R = eul2rotm([0 K_theta_y -K_theta_x],'ZYX');
activeKps_rot = K_R\activeKps;
activeKps_rot(1,:) = activeKps_rot(1,:)./activeKps_rot(3,:);
activeKps_rot(2,:) = activeKps_rot(2,:)./activeKps_rot(3,:);
m_dist = max(sqrt(activeKps_rot(1,:).^2+activeKps_rot(2,:).^2));
m_f = m_dist/sqrt(2);
K_f = [m_f 0 0;0 m_f 0; 0 0 1];
end


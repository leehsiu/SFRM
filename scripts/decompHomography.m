function [N_all] = decompHomography( H_matrix )
%DECOMPHOMOGRAPHY Summary of this function goes here
%   Detailed explanation goes here
[~,D,V] = svd(H_matrix'*H_matrix);
sig1 = D(1,1);
sig3 = D(3,3);
v1 = V(:,1);
v2 = V(:,2);
v3 = V(:,3);
u1 = (sqrt(1-sig3)*v1+sqrt(sig1-1)*v3)/sqrt(sig1*sig3);
u2 = (sqrt(1-sig3)*v1-sqrt(sig1-1)*v3)/sqrt(sig1*sig3);
N_all{1} = cross(v2,u1);
N_all{2} = cross(v2,u2);
end


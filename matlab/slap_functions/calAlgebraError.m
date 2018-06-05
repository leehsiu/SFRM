function algNorm = calAlgebraError(kps1_,Emat,kps2_)
%CALALGEBRAERROR Summary of this function goes here
%   Detailed explanation goes here
global EMAT_MAX_ALG_ERR;
validId1 = kps1_(3,:)>0;
validId2 = kps2_(3,:)>0;
bothValid = validId1&validId2;

epl2 = Emat*kps1_;
alg = abs(diag(epl2'*kps2_))';
algNorm = alg./sqrt(epl2(1,:).^2+epl2(2,:).^2);
algNorm(~bothValid) = EMAT_MAX_ALG_ERR;
end


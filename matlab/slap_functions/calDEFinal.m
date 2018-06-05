function algNorm = calDEFinal(kps1_,Emat,kps2_)
%CALALGEBRAERROR Summary of this function goes here
%   Detailed explanation goes here
epl1 = Emat*kps2_;
alg = abs(diag(epl1'*kps1_))';
algNorm = alg./sqrt((epl1(1,:).^2+epl1(2,:).^2));
end


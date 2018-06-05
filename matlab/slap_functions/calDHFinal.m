function algNorm = calDHFinal(kps1_,Hmat,kps2_)
%CALALGEBRAERROR Summary of this function goes here
%   Detailed explanation goes here
hom1_ = Hmat*kps2_;
algNorm2 = sqrt(diag((hom1_-kps1_)'*(hom1_-kps1_)));
n1 = (sqrt(diag(kps1_'*kps1_)));
n2 = (sqrt(diag(hom1_'*hom1_)));
algNorm =2*(algNorm2)./(n1+n2);
end


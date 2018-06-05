function Fmat = calFundamental(P1,P2,K)
%CALFUNDAMENTAL Summary of this function goes here
%   Detailed explanation goes here
 Prel = inv(P1)*P2;
 Rrel = Prel(1:3,1:3);
 Trel = Prel(1:3,4);
 A = K*Rrel'*Trel;
 C = [0 -A(3) A(2); A(3) 0 -A(1);-A(2) A(1) 0];
 Fmat = (inv(K))'*Rrel*K'*C;
end


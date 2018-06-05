function [Emat,minEg] = calEssentialMatrix(kps1,K1,kps2,K2)
%CALFUNDAMENTALBYPOINTS Summary of this function goes here
%   Detailed explanation goes here
global GOOD_PAIR_TH;
GOOD_PAIR_TH=0.36;
pairId = (kps1(3,:).*kps2(3,:))>GOOD_PAIR_TH;
pairId(15:18)=0;
nPair = sum(pairId);

if(nPair<=8)
    Emat = zeros(3,3);
    minEg = 1;    
else
    A = zeros(nPair,9);
    xp = kps1(:,pairId);
    yp = kps2(:,pairId);
    xp(3,:) = 1;
    yp(3,:) = 1;
    xp = K1\xp;
    yp = K2\yp;
    
    xp(1,:) = xp(1,:)./xp(3,:);
    xp(2,:) = xp(2,:)./xp(3,:);
    xp(3,:) = 1;
    
    yp(1,:) = yp(1,:)./yp(3,:);
    yp(2,:) = yp(2,:)./yp(3,:);
    yp(3,:) = 1;
    for i=1:nPair
        cMat = xp(:,i)*yp(:,i)';
        A(i,:) = cMat(:);
    end
    
    [~,SigmaA,Va] = svd(A);
    F = Va(:,end);
    Fmat = reshape(F,[3,3]);
        [U,D,V] = svd(Fmat);
    D(3,3)=0;
          
    D(1,1) = 1;
    D(2,2) = 1;
    if(det(U*V')>0)
        Emat = U*D*V';
    else
        Emat = (U*D*(-V'));
    end
    

    minEg = SigmaA(9,9);

    
end
end

function [Epart,Hpart]=ExtractAffinityMatrix(allKps,nESample)

[nFrames,nPts] = size(allKps);
nFrames = nFrames/3;

Epart = zeros(nFrames,nFrames);
Hpart = zeros(nFrames,nFrames);

%pure 5-pt algorithm
allCombCase = nchoosek(1:nPts,5);
nCombCase = size(allCombCase,1);


allTime = (nFrames+1)*nFrames/2;

for t1 = 1:nFrames        
    for t2=t1+1:nFrames
        sampledCase = randperm(nCombCase,nESample);
        rCase = allCombCase(sampledCase,:);
        [Epart(t1,t2),Hpart(t1,t2)] = cal2poseResidual_FiveSample(allKps(t1*3-2:t1*3,:),allKps(t2*3-2:t2*3,:),rCase,nPts);            
    end    
    
    procg = (2*nFrames-t1)*(t1)/2;
    pct = round(procg/allTime*100);
    if(mod(pct,10)==0)
        disp(['progress:' num2str(pct) '%']);
    end
    
    
end
Epart = Epart+Epart';
Hpart = Hpart+Hpart';
end

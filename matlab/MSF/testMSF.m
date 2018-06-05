WORK_DIR = '~/databag/dancing';
load(fullfile(WORK_DIR,'simMatrix_ZeroLayer.mat'));

nFrames = size(simMatrixE,1);
FrameList = 1:nFrames;
wList = simMatrixE(:);
[swList,sId] = sort(wList);
stId = find(swList,1,'first');
sId = sId(stId:end);
swListc = swList(stId:end);
listL = length(sId);
midPos = fix(listL/2);
endPos = listL;

cListyPre = ceil(sId/nFrames);
cListxPre = mod(sId,nFrames);
xdiffPre = setdiff(cListyPre,FrameList);
ydiffPre = setdiff(cListyPre,FrameList);
while (endPos-midPos)>4
    cList = sId(1:midPos);
    cListy = ceil(cList/nFrames);
    cListx = mod(cList,nFrames);
    cListx(cListx==0) = nFrames;
    xyList = [cListy cListx];
    xydiff = setdiff(FrameList,xyList);
    if(~isempty(xydiff))
        midPos = ceil((midPos+endPos)/2);        
    end   
    if(isempty(xydiff))
        endPos = midPos;        
        midPos= ceil((midPos+1)/2);         
    end              
end
sId = sId(1:endPos);
cListy = ceil(sId/nFrames);
cListx = mod(sId,nFrames);
cListx(cListx==0) = nFrames;
finalESparse = sparse(cListx,cListy,swListc(1:endPos),nFrames,nFrames);
finalE = full(finalESparse);
we = finalE+finalE';
we(we==0) = 2.236;
sig = 0.075;
figure(1);
imagesc(exp(-we.^2/sig^2));
colormap jet;


weightList = swListc(1:endPos);

G = graph(cListx,cListy,weightList);
figure(2);
p = plot(G);
[T,pred] = minspantree(G,'Type','forest','Root',1);
figure(3);

nLabels = cell(1,nFrames);
for i=1:nFrames
    nLabels{i} = sprintf('%d',i);
end
plot(T,'Layout','force')

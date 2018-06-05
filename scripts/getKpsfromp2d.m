function Kps = getKpsfromp2d(p2dfile)
%GETKPFROMJSON Summary of this function goes here
%   Detailed explanation goes here
%   The biggest person
allData = load(p2dfile);
[nLine,~] = size(allData);
npeople = nLine/18;
allsize = zeros(npeople,1);
for i=1:npeople
    curkps = allData(i*18-17:i*18,:);
    curkps = curkps';
    availb = curkps(3,:)>1e-1;
    curkps = curkps(:,availb);
    x_max = max(curkps(1,:));
    x_min = min(curkps(1,:));
    y_max = max(curkps(2,:));
    y_min = min(curkps(2,:));
    allsize(i) = abs(x_max-x_min)+abs(y_max-y_min);
end
[~,curid] = max(allsize);
Kps = allData(curid*18-17:curid*18,:);
Kps = Kps';
end
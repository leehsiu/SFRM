bone_color= [
    255.0,     0.0,    85.0;
    255.0,     0.0,     0.0;
    255.0,    85.0,     0.0;
    255.0,   170.0,     0.0;
    255.0,   255.0,     0.0;
    170.0,   255.0,     0.0;
    85.0,   255.0,     0.0;
    0.0,   255.0,     0.0;
    0.0,   255.0,    85.0;
    0.0,   255.0,   170.0;
    0.0,   255.0,   255.0;
    0.0,   170.0,   255.0;
    0.0,    85.0,   255.0;
    0.0,     0.0,   255.0;
    255.0,     0.0,   170.0;
    170.0,     0.0,   255.0;
    255.0,     0.0,   255.0;
    85.0,     0.0,   255.0;
    ];

WORK_DIR = '~/databag/SFRM/Yuna';
load(fullfile(WORK_DIR,'allKps3D.mat'));
load(fullfile(WORK_DIR,'allKps.mat'));
load(fullfile(WORK_DIR,'Ncut_better.mat'));

%
% for i=1:length(sortCutIdx)
%     blockId = sortCutIdx{i};
%     for j=1:1
%         figure(1);
%         clf;
%         render3DBone(ptsAll3D(blockId(j)*3-2:blockId(j)*3,:));
%         pause;
%     end
%     i
% end
%




n = size(ptsAll3D,1)/3;
asp = 1;
j = 1;
c3Dw = zeros(n*3,14);


repErr = zeros(n,1)+10;
for i=1:n
    c2D = allKps(i*3-2:i*3,:);
    c3D = ptsAll3D(i*3-2:i*3,:);
    c3Drep = c3D./repmat(c3D(3,:),[3 1]);
    
    
    repErr(i) = sum(sqrt(diag((c2D - c3Drep)'*(c2D-c3Drep))));
    cJointL = norm(c3D(:,1)-c3D(:,3));
    c3D = asp*c3D./cJointL;
   
    c3Dw(i*3-2:i*3,:) = c3D;
end
figure(2);
plot(repErr);


figure(3);
OKID = repErr<0.1;


allX = c3Dw(1:3:end,:);
allY = c3Dw(2:3:end,:);
allZ = c3Dw(3:3:end,:);
hold on;
for j=1:14
    plot3(allX(OKID,j),allY(OKID,j),allZ(OKID,j),'-','Color',bone_color(j,:)./255);
end
axis equal;
grid on;
daspect([1 1 1]);


fid= fopen(fullfile(WORK_DIR,'allTrajects.txt'),'w');
for i=1:size(OKID,1)
    if(OKID(i))
        fprintf(fid,'%d\n',i);
        fprintf(fid,'%f %f %f\n',[allX(i,:);allY(i,:);allZ(i,:)]);
    end
end
fclose(fid);
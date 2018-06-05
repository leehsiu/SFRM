clear all;
%load all data
SLAPsetup();
WORK_DIR='/home/xiul/databag/flag_sample';
load(fullfile(WORK_DIR,'allKps.mat'));
load(fullfile(WORK_DIR,'n_cut_zero.mat'));
matchId = finalId{1};
load('pose2.mat');
load('pt2.mat');
fout = fopen(fullfile(WORK_DIR,'hand_problem.txt'),'w');
nKps = size(allKps,2);
nc = height(camPoses);
fprintf(fout,'%d %d %d\n',nc,nKps,nc*nKps);
for i = 1:nc
    camId = zeros(1,nKps)+i-1;
    kpsId = 1:nKps;
    tid = camPoses.ViewId(i);
    t1 = matchId(tid);
    cKps = allKps(t1*3-2:t1*3,:);
    fprintf(fout,'%d %d %f %f\n',[camId;kpsId-1;cKps(1:2,:)]);    
end
for i=1:nc
   or = camPoses.Orientation{i};
   R = rotm2eul(or);
   t = camPoses.Location{i};
   pr = [R';t'];
   fprintf(fout,'%f\n',pr);
end
xyz = xyzPoints'
for i=1:nKps
    fprintf(fout,'%f\n',xyz(:));
end


fclose(fout);


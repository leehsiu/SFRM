WORK_DIR = '~/databag/SFRM/flag2';

GT = load(fullfile(WORK_DIR,'gt_global.mat'));
SFRM = load('./paper_figure/Flag_result/SFRM.mat');
DLH = load('./paper_figure/Flag_result/NRSFM-DLH_result/DLH_out_proj_K12/Aligned_BMM.mat');
IJAR = load('./paper_figure/Flag_result/flag_ijar_result/aligned_proj.mat');

nKps = size(GT.gt,2);
nFrames = size(GT.gt,1)/3;


Er = zeros(3,nFrames);

p1All = zeros(nFrames*3,nKps);
p2All = zeros(nFrames*3,nKps);
p3All = zeros(nFrames*3,nKps);

for i=1:nFrames
    
    c3gt = GT.gt(i*3-2:i*3,:);
    p1 = SFRM.SFRM_3D(i*3-2:i*3,:);
    p2 = DLH.Aligned_BMM(i*3-2:i*3,:);
    p3 = IJAR.aligned_proj(i*3-2:i*3,:);
    
    
    [R,t]=rigid_transform_3D(p1',c3gt');
    p1All(i*3-2:i*3,:) = R*p1+t;
    
    [R,t]=rigid_transform_3D(p2',c3gt');
    p2All(i*3-2:i*3,:) = R*p2+t;
    [R,t]=rigid_transform_3D(p3',c3gt');
    p3All(i*3-2:i*3,:) = R*p3+t;
       
    
    
    
    Er(1,i) = mean(sqrt(diag((p1All(i*3-2:i*3,:) - c3gt)'*(p1All(i*3-2:i*3,:) - c3gt))));
    Er(2,i) = mean(sqrt(diag((p2All(i*3-2:i*3,:) - c3gt)'*(p2All(i*3-2:i*3,:) - c3gt))));
    Er(3,i) = mean(sqrt(diag((p3All(i*3-2:i*3,:) - c3gt)'*(p3All(i*3-2:i*3,:) - c3gt))));

end
colorm = hsv(3);
LineNum = 900;
figure(1);
hold on;
pd = {};

x = 0:0.001:0.6;

meanErr = mean(Er,2);
for i=1:3
    pd{i} = fitdist(Er(i,:)','Normal');
    yi = pdf(pd{i},x);
    plot(x,yi,'LineWidth',2,'Color',colorm(i,:))
end


lgd = legend('SFRM(ours): \mu=0.0849','DLH:             \mu=0.1742','DCT:             \mu=0.2379');
lgd.FontSize = 12;
lgd.FontWeight = 'bold';
ax = gca;
ax.XAxis.FontSize = 12;
ax.XAxis.FontWeight = 'bold';
ax.YAxis.FontSize = 12;
ax.YAxis.FontWeight = 'bold';
ax.YTickLabel = [];


grid on;




fidG= fopen(fullfile(WORK_DIR,'flagGt.txt'),'w');
fidS = fopen(fullfile(WORK_DIR,'flagS.txt'),'w');
fidH = fopen(fullfile(WORK_DIR,'flagH.txt'),'w');
fidY = fopen(fullfile(WORK_DIR,'flagY.txt'),'w');
for i=1:nFrames
    c3gt = GT.gt(i*3-2:i*3,:);
    p1 = p1All(i*3-2:i*3,:);
    p2 = p2All(i*3-2:i*3,:);
    p3 = p3All(i*3-2:i*3,:);
    
    fprintf(fidG,'%d\n',i);
    fprintf(fidS,'%d\n',i);
    fprintf(fidH,'%d\n',i);    
    fprintf(fidY,'%d\n',i);
    
    fprintf(fidG,'%f %f %f\n',c3gt);
    fprintf(fidS,'%f %f %f\n',p1);
    fprintf(fidH,'%f %f %f\n',p2);
    fprintf(fidY,'%f %f %f\n',p3);
end
fclose(fidG);
fclose(fidS);
fclose(fidH);
fclose(fidY);



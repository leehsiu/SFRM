WORK_DIR = '~/databag/SFRM/flag2';

GT = load(fullfile(WORK_DIR,'gt_view.mat'));
SFRM = load('./Flag_result/SFRM.mat');
DLH = load('./Flag_result/NRSFM-DLH_result/DLH_out_proj_K12/Aligned_BMM.mat');
IJAR = load('./Flag_result/flag_ijar_result/aligned_proj.mat');

DLH_OTH = load('./Flag_result/NRSFM-DLH_result/DLH_out_orth_K12/Aligned_BMM_orth.mat');
IJAR_OTH = load('./Flag_result/flag_ijar_result/aligned_orth.mat');
nKps = size(GT.gt_view,2);
nFrames = size(GT.gt_view,1)/3;


Er = zeros(3,nFrames);
for i=1:nFrames
    
    c3gt = GT.gt_view(i*3-2:i*3,:);
    p1 = SFRM.SFRM_3D(i*3-2:i*3,:);
    p2 = DLH.Aligned_BMM(i*3-2:i*3,:);
    p3 = IJAR.aligned_proj(i*3-2:i*3,:);
    p4 = DLH_OTH.Aligned_BMM_orth(i*3-2:i*3,:);
    p5 = IJAR_OTH.aligned_orth(i*3-2:i*3,:);
    
    
    Er(1,i) = mean(sqrt(diag((p1 - c3gt)'*(p1 - c3gt))));
    Er(2,i) = mean(sqrt(diag((p2 - c3gt)'*(p2 - c3gt))));
    Er(3,i) = mean(sqrt(diag((p3 - c3gt)'*(p3 - c3gt))));
%     Er(4,i) = mean(sqrt(diag((p4 - c3gt)'*(p4 - c3gt))));
%     Er(5,i) = mean(sqrt(diag((p5 - c3gt)'*(p5 - c3gt))));
end
colorm = hsv(3);
LineNum = 900;
figure(1);
hold on;
nBin = 600;
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
%allKpsAlingn
%
%
% yyaxis right;
% xlabel('Pixel uncertainty');
%
% plot(xe,mean(recErr')/nkps,'-o','LineWidth',3);
% ylabel('Reconstruction Error');
%
% hold on;
% yyaxis left;
%
% plot(xe,validNum/300,'-^','LineWidth',3);
% ylabel('Reconstruction Ratio');
% grid on;
% lgd = legend('Reconstruction Ratio','Reconstruction Error');
% lgd.FontSize = 12;
% lgd.FontWeight = 'bold';
% ax = gca;
% ax.XAxis.FontSize = 12;
% ax.XAxis.FontWeight = 'bold';
% ax.YAxis(1).FontSize = 12;
% ax.YAxis(1).FontWeight = 'bold';
% ax.YAxis(2).FontSize = 12;
% ax.YAxis(2).FontWeight = 'bold';
%
% %xlim([1 10]);
% % fid= fopen(fullfile(WORK_DIR,'allTraject.txt'),'w');
% % for i=1:size(OKID,1)
% %     if(OKID(i))
% %         fprintf(fid,'%d\n',i);
% %         fprintf(fid,'%f %f %f\n',[allX(i,:);allY(i,:);allZ(i,:)]);
% %     end
% % end
% % fclose(fid);
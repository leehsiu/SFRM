WORK_DIR = '~/databag/flag2';

GT = load(fullfile(WORK_DIR,'gt_view.mat'));
SFRM = load('./Flag_result/SFRM.mat');
DLH = load('./Flag_result/NRSFM-DLH_result/DLH_out_proj_K12/Aligned_BMM.mat');
IJAR = load('./Flag_result/flag_ijar_result/aligned_proj.mat');

DLH_OTH = load('./Flag_result/NRSFM-DLH_result/DLH_out_orth_K12/Aligned_BMM_orth.mat');
IJAR_OTH = load('./Flag_result/flag_ijar_result/aligned_orth.mat');
nKps = size(GT.gt_view,2);
nFrames = size(GT.gt_view,1)/3;

ObjTmpLine = {};
tmpFile = fopen('./objfile/flag_001.tmplate');
linNum = 1;
while ~feof(tmpFile)
    ObjTmpLine{linNum} = fgets(tmpFile);
    linNum = linNum+1;
end
fclose(tmpFile);


mtlName = {'plaid0','plaid1','plaid2','plaid3','plaid4','plaid5'};
mtlLibName = {'plaid0.mtl','plaid1.mtl','plaid2.mtl','plaid3.mtl','plaid4.mtl','plaid5.mtl'};

%%
for i=1:nFrames
    
    p0 = GT.gt_view(i*3-2:i*3,:);    
    p1 = SFRM.allKpsAlign(i*3-2:i*3,:);
    p2 = DLH.Aligned_BMM(i*3-2:i*3,:);
    p3 = IJAR.aligned_proj(i*3-2:i*3,:);
    p4 = DLH_OTH.Aligned_BMM_orth(i*3-2:i*3,:);
    p5 = IJAR_OTH.aligned_orth(i*3-2:i*3,:);
    fileName = sprintf('Flag_%04d.obj',i);
    
    file0 = fopen(fullfile('./objfile/p0',fileName),'w');
    file1 = fopen(fullfile('./objfile/p1',fileName),'w');
    file2 = fopen(fullfile('./objfile/p2',fileName),'w');
    file3 = fopen(fullfile('./objfile/p3',fileName),'w');
    file4 = fopen(fullfile('./objfile/p4',fileName),'w');
    file5 = fopen(fullfile('./objfile/p5',fileName),'w');
    
    for lin=1:4
        fprintf(file0,'%s',ObjTmpLine{lin});
        fprintf(file1,'%s',ObjTmpLine{lin});
        fprintf(file2,'%s',ObjTmpLine{lin});
        fprintf(file3,'%s',ObjTmpLine{lin});
        fprintf(file4,'%s',ObjTmpLine{lin});
        fprintf(file5,'%s',ObjTmpLine{lin});        
    end
    fprintf(file0,'mtllib plaid0.mtl\n');
    fprintf(file1,'mtllib plaid1.mtl\n');
    fprintf(file2,'mtllib plaid2.mtl\n');
    fprintf(file3,'mtllib plaid3.mtl\n');
    fprintf(file4,'mtllib plaid4.mtl\n');
    fprintf(file5,'mtllib plaid5.mtl\n');
    
    fprintf(file0,'v %f %f %f\n',p0);
    fprintf(file1,'v %f %f %f\n',p1);
    fprintf(file2,'v %f %f %f\n',p2);
    fprintf(file3,'v %f %f %f\n',p3);
    fprintf(file4,'v %f %f %f\n',p4);
    fprintf(file5,'v %f %f %f\n',p5);
    
%     for lin=5:48
%     
%     end
     for lin=49:93
        fprintf(file0,'%s',ObjTmpLine{lin});
        fprintf(file1,'%s',ObjTmpLine{lin});
        fprintf(file2,'%s',ObjTmpLine{lin});
        fprintf(file3,'%s',ObjTmpLine{lin});
        fprintf(file4,'%s',ObjTmpLine{lin});
        fprintf(file5,'%s',ObjTmpLine{lin});        
     end
    fprintf(file0,'usemtl plaid0\n');
    fprintf(file1,'usemtl plaid1\n');
    fprintf(file2,'usemtl plaid2\n');
    fprintf(file3,'usemtl plaid3\n');
    fprintf(file4,'usemtl plaid4\n');
    fprintf(file5,'usemtl plaid5\n');
    for lin=95:linNum-1
        fprintf(file0,'%s',ObjTmpLine{lin});
        fprintf(file1,'%s',ObjTmpLine{lin});
        fprintf(file2,'%s',ObjTmpLine{lin});
        fprintf(file3,'%s',ObjTmpLine{lin});
        fprintf(file4,'%s',ObjTmpLine{lin});
        fprintf(file5,'%s',ObjTmpLine{lin});   
    end
    fclose(file0);    
    fclose(file1);
    fclose(file2);
    fclose(file3);
    fclose(file4);
    fclose(file5);                           
end



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
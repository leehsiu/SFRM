% demoNcutClustering
% 
% demo for NcutClustering
% also initialize matlab paths to subfolders
% Timothee Cour, Stella Yu, Jianbo Shi, 2004.

fpt1 = load('./simMatrix_diff_case/period.mat');
fpt2 = load('./simMatrix_diff_case/recurrent.mat');
fpt3 = load('./simMatrix_diff_case/rigid.mat');

E1 = fpt1.simMatrixE+fpt1.simMatrixE';
E2 = fpt2.simMatrixE+fpt2.simMatrixE';
E3 = fpt3.simMatrixE+fpt3.simMatrixE';
H3 = fpt3.simMatrixH+fpt3.simMatrixH';

sige1 = 0.05;
sige2 = 0.2;
sige3 = 0.05;
sigh3 = 0.03;

SimE1 = exp(-E1/(sige1^2));
SimE2 = exp(-E2/(sige2^2));
SimE3 = exp(-E3/(sige3^2));
SimH3 = exp(-H3/(sigh3^2));

selId = 200:400;

figure(1);
imagesc(SimE1(selId,selId));
colormap jet;
axis image;
ax = gca;
ax.XAxisLocation = 'top';
ax.YAxisLocation = 'left';
ax.XAxis.FontSize = 12;
ax.XAxis.FontWeight = 'bold';
ax.YAxis.FontSize = 12;
ax.YAxis.FontWeight = 'bold';
ax.XTickLabel = [];
ax.YTickLabel = [];
export_fig peroid.png


figure(2);

imagesc(SimE2(selId,selId));
colormap jet;
axis image;
ax = gca;
ax.XAxisLocation = 'top';
ax.YAxisLocation = 'left';
ax.XAxis.FontSize = 12;
ax.XAxis.FontWeight = 'bold';
ax.YAxis.FontSize = 12;
ax.YAxis.FontWeight = 'bold';
ax.XTickLabel = [];
ax.YTickLabel = [];
export_fig reccurent.png



Sim3 = SimE3.*(1-SimH3);
figure(3);
imagesc(Sim3(selId,selId));
colormap jet;
axis image;
ax = gca;
ax.XAxisLocation = 'top';
ax.YAxisLocation = 'left';
ax.XAxis.FontSize = 12;
ax.XAxis.FontWeight = 'bold';
ax.YAxis.FontSize = 12;
ax.YAxis.FontWeight = 'bold';
ax.XTickLabel = [];
ax.YTickLabel = [];
export_fig rigid.png
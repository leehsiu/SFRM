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

sige1 = 0.035;
sige2 = 0.25;
sige3 = 0.05;
sigh3 = 0.03;

SimE1 = exp(-E1/(sige1^2));
SimE2 = exp(-E2/(sige2^2));
SimE3 = exp(-E3/(sige3^2));
SimH3 = exp(-H3/(sigh3^2));

selId = 200:400;

SimE1 = SimE1(selId,selId);
% figure(1);
% subplot(1,3,1);
% imagesc(SimE1);
% colormap jet;
% axis image;
% ax = gca;
% ax.XAxisLocation = 'top';
% ax.YAxisLocation = 'left';
% ax.XAxis.FontSize = 12;
% ax.XAxis.FontWeight = 'bold';
% ax.YAxis.FontSize = 12;
% ax.YAxis.FontWeight = 'bold';


nbCluster = 40;
tic;
[NcutDiscrete,NcutEigenvectors,NcutEigenvalues] = ncutW(SimE1,nbCluster);
disp(['The computation took ' num2str(toc) ' seconds']);

% display clustering result
id = cell(nbCluster,1);
finalId = cell(nbCluster,1);
cluterSizeList = zeros(1,nbCluster);
CC1 = zeros(200,200);
for j=1:nbCluster       
    id{j} = find(NcutDiscrete(:,j));
    cluterSizeList(j) = length(id{j});   
     CC1(id{j},id{j}) = j+100;
end
[~,sortc] = sort(cluterSizeList,'descend');
for j=1:nbCluster       
    finalId{j} = id{sortc(j)};    
end
cMat1 = cell2mat(finalId);
% 
% subplot(1,3,2);
% imagesc(SimE1(cMat1,cMat1));
% colormap jet;
% axis image;
% ax = gca;
% ax.XAxisLocation = 'top';
% ax.YAxisLocation = 'left';
% ax.XAxis.FontSize = 12;
% ax.XAxis.FontWeight = 'bold';
% ax.YAxis.FontSize = 12;
% ax.YAxis.FontWeight = 'bold';

% subplot(1,3,3);
% imagesc(CC1(cMat1,cMat1));
% colormap jet;
% axis image;
% ax = gca;
% ax.XAxisLocation = 'top';
% ax.YAxisLocation = 'left';
% ax.XAxis.FontSize = 12;
% ax.XAxis.FontWeight = 'bold';
% ax.YAxis.FontSize = 12;
% ax.YAxis.FontWeight = 'bold';

figure(1);
clf;
imagesc(SimE1(cMat1,cMat1));
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
export_fig fig3-peroid-block.png

figure(1);
clf;
imagesc(CC1(cMat1,cMat1));
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
export_fig fig3-peroid-cluster.png



SimE2 = SimE2(selId,selId);
% 
% figure(2);
% subplot(1,3,1);
% imagesc(SimE2);
% colormap jet;
% axis image;
% ax = gca;
% ax.XAxisLocation = 'top';
% ax.YAxisLocation = 'left';
% ax.XAxis.FontSize = 12;
% ax.XAxis.FontWeight = 'bold';
% ax.YAxis.FontSize = 12;
% ax.YAxis.FontWeight = 'bold';

nbCluster = 15;
tic;
[NcutDiscrete,NcutEigenvectors,NcutEigenvalues] = ncutW(SimE2,nbCluster);
disp(['The computation took ' num2str(toc) ' seconds']);

% display clustering result
id = cell(nbCluster,1);
finalId = cell(nbCluster,1);
cluterSizeList = zeros(1,nbCluster);
CC2 = zeros(200,200);
for j=1:nbCluster       
    id{j} = find(NcutDiscrete(:,j));
    cluterSizeList(j) = length(id{j});   
     CC2(id{j},id{j}) = j+100;
end
[~,sortc] = sort(cluterSizeList,'descend');
for j=1:nbCluster       
    finalId{j} = id{sortc(j)};    
end
cMat1 = cell2mat(finalId);

% subplot(1,3,2);
figure(2);
clf;
imagesc(SimE2(cMat1,cMat1));
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
export_fig fig3-recc-block.png

figure(2);
clf;
% subplot(1,3,3);
imagesc(CC2(cMat1,cMat1));
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
export_fig fig3-recc-cluster.png









figure(3);
Sim3 = SimE3.*(1-SimH3);
Sim3 = Sim3(selId,selId);
subplot(1,3,1);
imagesc(Sim3);
colormap jet;
axis image;
ax = gca;
ax.XAxisLocation = 'top';
ax.YAxisLocation = 'left';
ax.XAxis.FontSize = 12;
ax.XAxis.FontWeight = 'bold';
ax.YAxis.FontSize = 12;
ax.YAxis.FontWeight = 'bold';


nbCluster = 2;
tic;
[NcutDiscrete,NcutEigenvectors,NcutEigenvalues] = ncutW(Sim3,nbCluster);
disp(['The computation took ' num2str(toc) ' seconds']);

% display clustering result
id = cell(nbCluster,1);
finalId = cell(nbCluster,1);
cluterSizeList = zeros(1,nbCluster);
CC3 = zeros(200,200);
for j=1:nbCluster       
    id{j} = find(NcutDiscrete(:,j));
    cluterSizeList(j) = length(id{j});   
     CC3(id{j},id{j}) = j+100;
end
[~,sortc] = sort(cluterSizeList,'descend');
for j=1:nbCluster       
    finalId{j} = id{sortc(j)};    
end
cMat1 = cell2mat(finalId);

subplot(1,3,2);
imagesc(Sim3(cMat1,cMat1));
colormap jet;
axis image;
ax = gca;
ax.XAxisLocation = 'top';
ax.YAxisLocation = 'left';
ax.XAxis.FontSize = 12;
ax.XAxis.FontWeight = 'bold';
ax.YAxis.FontSize = 12;
ax.YAxis.FontWeight = 'bold';

subplot(1,3,3);
imagesc(CC3(cMat1,cMat1));
colormap jet;
axis image;
ax = gca;
ax.XAxisLocation = 'top';
ax.YAxisLocation = 'left';
ax.XAxis.FontSize = 12;
ax.XAxis.FontWeight = 'bold';
ax.YAxis.FontSize = 12;
ax.YAxis.FontWeight = 'bold';





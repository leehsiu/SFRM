% Ncut for Pmat or Affinity matrix extracted from non-rigid sequence
WORK_DIR = '~/databag/SFRM/pano0';

Pmat = load(fullfile(WORK_DIR,'Pmat_better.mat'));

simE = Pmat.simMatrixE;
simH = Pmat.simMatrixH;
nFrames = size(simE,1);


dete = 0.325;
deth = 0.15;


simWe = exp(-simE/(dete^2));
simWe(simWe<0.75) = 0;
simWh = exp(-simH/(deth^2));

figure(1);
subplot(1,3,1);
imagesc(simWe);
colormap jet;
axis image;
ax = gca;
ax.XAxisLocation = 'top';
ax.YAxisLocation = 'left';


subplot(1,3,2);
imagesc(simWh);
colormap jet;
axis image;
ax = gca;
ax.XAxisLocation = 'top';
ax.YAxisLocation = 'left';

Amatrix = simWe.*(1-simWh);
Amatrix(logical(eye(nFrames))) = 1;
subplot(1,3,3);
imagesc(Amatrix);
colormap jet;
axis image;
ax = gca;
ax.XAxisLocation = 'top';
ax.YAxisLocation = 'left';
%%
%Ncut 
nbCluster = 40;
[NcutDiscrete,~,~] = ncutW(Amatrix,nbCluster);

cutIdx = cell(nbCluster,1);
sortCutIdx = cell(nbCluster,1);
cutSizeList = zeros(1,nbCluster);
H = zeros(nFrames,nFrames);
for j=1:nbCluster       
    cutIdx{j} = find(NcutDiscrete(:,j));
    cutSizeList(j) = length(cutIdx{j});   
     H(cutIdx{j},cutIdx{j}) = j+100;
end
[~,sortc] = sort(cutSizeList,'descend');
for j=1:nbCluster       
    sortCutIdx{j} = cutIdx{sortc(j)};    
end
figure(2);
subplot(1,2,1);
imagesc(Amatrix(cell2mat(cutIdx),cell2mat(cutIdx)));
axis image;
subplot(1,2,2);
imagesc(Amatrix(cell2mat(sortCutIdx),cell2mat(sortCutIdx)));
axis image;
colormap jet;

%%
%
save(fullfile(WORK_DIR,'Ncut_better.mat'),'sortCutIdx','Amatrix');
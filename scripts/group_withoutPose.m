%load all data
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
global GOOD_PAIR_TH;
GOOD_PAIR_TH = 0.3;

WORK_DIR='/home/xiul/databag/10-07_1';
K = zeros(3,3);
% K(1,1) = 329.275;
% K(2,2) = 336.733;
% K(1,3) = 356.072;
% K(2,3) = 176.231;
% K(3,3) = 1;
K(1,1) = 7.005836945361845e+02;
K(2,2) = 7.005836945361845e+02;
K(1,3) = 7.577392339646816e+02;
K(2,3) = 3.667215676837498e+02;
K(3,3) = 1;
invK = inv(K);
allJson = dir(fullfile(WORK_DIR,'/image_skeleton_origin','*.json'));
allImage = dir(fullfile(WORK_DIR,'/image_skeleton_origin','*.png'));



resampleFactor = 1;

newId = 1:resampleFactor:length(allJson);

Eigvec = zeros(length(newId),length(newId));
RepVec = zeros(length(newId),length(newId));

ii = 1;
jj = 1;
h = 748;

for t1=1:resampleFactor:length(allJson)
    jj = 1;
    t1
    for t2=1:resampleFactor:length(allJson)
        Kps1=getKpsfromJson(fullfile(allJson(t1).folder,allJson(t1).name));
        Kps2=getKpsfromJson(fullfile(allJson(t2).folder,allJson(t2).name));
        
        
        %img1= imread(fullfile(allImage(t1).folder,allImage(t1).name));
        %img2= imread(fullfile(allImage(t2).folder,allImage(t2).name));
    
        
        %[Emat,minEng] = calEssentialMatrix(Kps1,Kps2,K);
        [Emat,minEng] = calEssentialMatrixProg(Kps1,Kps2,K);        
        Eigvec(ii,jj) = minEng;

        jj = jj+1;
    end
    if((mod(ii,5))==0)
        dvecT1 = Eigvec(ii,:);
        [dvecT1sort,sortId] = sort(dvecT1);
        figure(1);
        
        img1= imread(fullfile(allImage(t1).folder,allImage(t1).name));
        imshow(img1);
        curk1 = getKpsfromJson(fullfile(allJson(t1).folder,allJson(t1).name));
        figure(2);
        for tt=1:1:9
            subplot(3,3,tt);
            t2 = (sortId(tt)-1)*resampleFactor+1;
            img2= imread(fullfile(allImage(t2).folder,allImage(t2).name));
            imshow(img2);
            tName = sprintf('%04d',t2);            
            title(tName);
            curk2 = getKpsfromJson(fullfile(allJson(t2).folder,allJson(t2).name));            
            [Emat,minEng] = calEssentialMatrixProg(curk1,curk2,K);
            Fmat = invK'*Emat*invK;
            curk2(3,:) = 1;
            curEpl = (Fmat*curk2)';
            hold on;
            for gg=1:18
             plot([-curEpl(gg,3)/curEpl(gg,1) (-curEpl(gg,3)-h*curEpl(gg,2))/curEpl(gg,1)],[0 h],'Color',bone_color(gg,:)./255);
            end                        
        end
        pause;
    end
    
    ii = ii+1;
end


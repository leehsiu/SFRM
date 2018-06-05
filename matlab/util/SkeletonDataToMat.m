WORK_DIR = '/media/posefs0c/panopticdb/a2/annot_2dskeleton/160224_haggling1';
K = zeros(3,3);
K(1,1) =1632.8;
K(2,2) = 1628.61;
K(1,3) = 943.554;
K(2,3) = 555.893;
K(3,3) = 1;

AllFold = dir(WORK_DIR);
AllFold = AllFold(3:end);

nFolder = length(AllFold);

allBody = cell(1);
for nf = 1:nFolder
    AllFold(nf).name
   AllJson = dir(fullfile(WORK_DIR,AllFold(nf).name,'*.json'));
   for nId = 1:length(AllJson)       
       jsonString = fileread(fullfile(AllJson(nId).folder,AllJson(nId).name));
       jsonData = jsondecode(jsonString);
       for jj=1:length(jsonData)
           cId = jsonData(jj).id;
           c2d = jsonData(jj).pose2d;
           cc =  ones(19,1);                      
           ckps = K\[c2d';cc'];
           if(cId<0)
               continue;
           end           
           if(length(allBody)>=cId)                              
               cAllKps = allBody{cId};
               cAllKps = [cAllKps;ckps];
               allBody{cId} = cAllKps;
           else
               allBody{cId} = ckps;
           end           
       end       
   end   
end



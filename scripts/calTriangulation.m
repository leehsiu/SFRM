function [p4d] = calTriangulation(triPose,triKps,triK)
global MAX_REPROJ_ERR;
MAX_REPROJ_ERR = -1;
triPose = triPose(triKps(3,:)>1e-2,:);
[nFrames,~]=size(triPose);
triKps = triKps(1:2,triKps(3,:)>1e-2);

if(nFrames<=1)
    p4d = [0 0 0 MAX_REPROJ_ERR];
else
    A = zeros(nFrames * 2, 4);
    for i=1:nFrames
        Pc = reshape(triPose(i,:),[4,4]);
        Pc = inv(Pc);
        CamP = triK*Pc(1:3,:);
        idx = 2*i;
        A(idx-1:idx,:) = triKps(:,i)*CamP(3,:) - CamP(1:2,:);
    end
    
%     if nFrames==2
%         S = diag(1./max(max(abs(A),2)));
%         AA = S*A;
%         
%         [~,~,V] = svd(AA);
%         X = V(:,end);
%         X = S*X;
%         p4d = X;
%     else
        [~,~,V] = svd(A);
        X = V(:,end);
        p4d = X;
%     end
    
    
    p4d = p4d./p4d(end);
    p4d(4) = calc_reprojection_err(p4d(1:3),triPose,triKps,triK);
    
end


end

function err_reproj = calc_reprojection_err_once(p3d,pose,kps,K)
p3dc = inv(pose)*[p3d;1];
p3dcProj = K*p3dc(1:3);
p3dcProj = p3dcProj(1:2)./p3dcProj(3);
err_reproj = norm(p3dcProj'-kps);
end


function err_reproj = calc_reprojection_err(p3d,triPose,triKps,triK)
[nFrames,~]=size(triPose);
err_reproj = 0;
for i=1:nFrames
    curPose = triPose(i,:);
    curPose = reshape(curPose,[4,4]);
    curKps = triKps(:,i)';
    err_reproj = err_reproj+calc_reprojection_err_once(p3d,curPose,curKps,triK);
end

end

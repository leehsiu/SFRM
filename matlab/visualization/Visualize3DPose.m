function [ output_args ] = Visualize3DPose( poseData)

BoneJointOrder = { [2 1 3] ...   %{headtop, neck, bodyCenter}
                    , [1 4 5 6] ... %{neck, leftShoulder, leftArm, leftWrist}
                    , [3 7 8 9] ...  %{neck, leftHip, leftKnee, leftAnkle}
                    , [1 10 11 12]  ... %{neck, rightShoulder, rightArm, rightWrist}
                    , [3 13 14 15]};    %{neck, rightHip, rightKnee, rightAnkle}
nDt = length(BoneJointOrder);
hold on;
plot3(poseData(1,:),poseData(2,:),poseData(3,:),'ro')
for i=1:nDt
    pts1 = poseData(:,BoneJointOrder{i});
    plot3(pts1(1,:),pts1(2,:),pts1(3,:),'b-','LineWidth',5);
end

end


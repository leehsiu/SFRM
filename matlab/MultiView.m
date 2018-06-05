%% Read the Input Image Sequence
% Read and display the image sequence.
WORK_DIR = '~/databag/flag2';
load(fullfile(WORK_DIR,'allKps.mat'));
load(fullfile(WORK_DIR,'n_cut_FiveSample.mat'));
%load(fullfile(WORK_DIR,'simMatrix_EightSample.mat'));

[nFrames,nKps] = size(allKps);
allKps3D = zeros(nFrames,nKps);
nCluster = length(finalId);


% K = eye(3);
% K(1,1) = 329.271;
% K(2,2) = 336.735;
% K(1,3) = 356.072;
% K(2,3) = 176.232;
%% Load Camera Parameters
K = diag([700 700 1]);
% Load the |cameraParameters| object created using the
% <matlab:helpview(fullfile(docroot,'toolbox','vision','vision.map'),'visionCameraCalibrator'); Camera Calibrator app>.
cameraParams = cameraParameters('IntrinsicMatrix',K');
%% For all Frames

for blkId = 1:nCluster
    matchId = finalId{blkId};
    nView = length(matchId);
    reRand = randperm(nView);
    matchId = matchId(reRand);
    if(nView<=3)
        continue;
    end
    tic;
    % creat viewset and try to do this
    vSet = viewSet;
    % Add the first view. Place the camera associated with the first view
    viewId = 1;
    
    cloc = allKps(matchId(1)*3-2:matchId(1)*3,:);
    clocI = K*cloc;
    clocP = clocI(1:2,:)';
    vSet = addView(vSet, viewId, 'Points',clocI(1:2,:)', 'Orientation', ...
        eye(3, 'like', clocI(1:2,:)'), 'Location', ...
        zeros(1, 3, 'like', clocI(1:2,:)'));
    %% Add the Rest of the Views
    % Go through the rest of the images. For each image
    iPre = 1;
    for i = 2:nView
        % Undistort the current image.
        cloc = allKps(matchId(i)*3-2:matchId(i)*3,:);
        clocI = K*cloc;
        clocC = clocI(1:2,:)';
        % Estimate the camera pose of current view relative to the previous view.
        % The pose is computed up to scale, meaning that the distance between
        % the cameras in the previous view and the current view is set to 1.
        try
            [relativeOrient, relativeLoc, inlierIdx] = helperEstimateRelativePose(...
                clocP, clocC, cameraParams);
        catch ME
            continue;
        end
        % Add the current view to the view set.
        vSet = addView(vSet, i, 'Points', clocC);
        idPair = 1:nKps;
        idPair = idPair';
        gPair = [idPair idPair];
        % Store the point matches between the previous and the current views.
        vSet = addConnection(vSet, iPre, i, 'Matches', gPair(inlierIdx,:));
        %vSet = addConnection(vSet, iPre, i, 'Matches', gPair);
        % Get the table containing the previous camera pose.
        prevPose = poses(vSet, iPre);
        prevOrientation = prevPose.Orientation{1};
        prevLocation    = prevPose.Location{1};
        
        % Compute the current camera pose in the global coordinate system
        % relative to the first view.
        orientation = relativeOrient * prevOrientation;
        location    = prevLocation + relativeLoc * prevOrientation;
        vSet = updateView(vSet, i, 'Orientation', orientation, ...
            'Location', location);
        
        % Find point tracks across all views.
        tracks = findTracks(vSet);
        
        % Get the table containing camera poses for all views.
        camPoses = poses(vSet);
        
        % Triangulate initial locations for the 3-D world points.
        xyzPoints = triangulateMultiview(tracks, camPoses, cameraParams);
        
        % Refine the 3-D world points and camera poses.
        %     [xyzPoints, camPoses, reprojectionErrors] = bundleAdjustment(xyzPoints, ...
        %         tracks, camPoses, cameraParams, 'FixedViewId', 1, ...
        %         'PointsUndistorted', true);
        
        [xyzPoints, camPoses, reprojectionErrors] = bundleAdjustment(xyzPoints, ...
            tracks, camPoses, cameraParams, ...
            'PointsUndistorted', true);
        % Store the refined camera poses.
        vSet = updateView(vSet, camPoses);
    end
    
    allKps3D(matchId(1)*3-2:matchId(1)*3,:) = xyzPoints';
    for i = 2:nView
        cPose = poses(vSet, i);
        if(~isempty(cPose))
            rot = cPose.Orientation{1};
            tras = cPose.Location{1};
            c3D = rot*(xyzPoints' - repmat(tras',[1 nKps]));
        else
            c3D = zeros(3,nKps);
        end
        allKps3D(matchId(i)*3-2:matchId(i)*3,:) = c3D;
    end
    toc;
    figure(1);
    plotCamera(camPoses, 'Size', 0.2);
    hold on
    
    % Exclude noisy 3-D world points.
    
    
    % Display the dense 3-D world points.
    pcshow(xyzPoints, 'VerticalAxis', 'y', 'VerticalAxisDir', 'down', ...
        'MarkerSize', 45);
    grid on
    hold off
    pause;
    blkId
end
save(fullfile(WORK_DIR,'allKps3D_tmp.mat'),'allKps3D');



#ifndef _VSLAP_GROUP_VIEWER_H
#define _VSLAP_GROUP_VIEWER_H

#include <pangolin/pangolin.h>
#include <boost/thread.hpp>
#include <opencv2/opencv.hpp>
#include <string>
#include <vector>
#include "HumanPose/SkeletonFrame.h"
#include<Eigen/Core>


namespace vslap{

class BlockViewer{
public:
    BlockViewer(std::string _fold,int partNum_);
    ~BlockViewer();
    int run();
    void render3DSkeleton();    
    void render3DFace(); 
     void render3DHand(); 
    void RenderGroundPlane();
    void close();    
    void join();
    std::vector<HumanPose3D> allPoses;            
    Eigen::Vector3d oriloc;
    
private:
    int curId;    
    int nFrames;
    bool running;
    int width;
    int height;
    boost::thread mainThread_;                
    double boneL;
    double boneW;
    double worldHeight;
    int  partNum;
    
    //Render Pose Structure
};

}

#endif
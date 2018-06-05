#ifndef _SKELETON_FRAME_H
#define _SKELETON_FRAME_H

#include"Global/settings.h"

#include<string>
#include<vector>
#include<Eigen/Core>



namespace vslap{


struct HumanPose3D{    
    Eigen::Vector3d jointsPos[BODY_JOINTS_NUM];
    Eigen::Vector3d jointRotation[BODY_JOINTS_NUM];
    double jointLength[BODY_JOINTS_NUM];        
};

struct HumanPose2D{
    Eigen::Vector3d joints[BODY_JOINTS_NUM];    
};

class SkeletonFrame
{
public:
    SkeletonFrame(){;}
    SkeletonFrame(int id_,int w_,int h_,Eigen::Matrix3d K_);
    HumanPose2D getSkeleton(int id_){return m_skeleton2ds[id_];}
    ~SkeletonFrame();
    int loadFile(std::string filename_);
private:
    int frameId;
    std::vector<HumanPose2D> m_skeleton2ds;
    Eigen::Matrix3d K;
    int w;
    int h;    
};


}
#endif


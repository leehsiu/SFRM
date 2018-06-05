#ifndef _KEYPOSE_GROUP_H
#define _KEYPOSE_GROUP_H

#include"SkeletonFrame.h"
#include<iostream>
#include<vector>
#include<Eigen/Core>

namespace vslap
{


struct skeletonId{
    int frameId;
    int Id;    
};
class KeyPoseGroup
{
  public:
    KeyPoseGroup();
    ~KeyPoseGroup();
    double testFrame(HumanPose2D & sTest_);    

  private:
    HumanPose3D mean_pose;
    std::vector<skeletonId> idx2Frame;
    std::vector<HumanPose2D> skels;
    std::vector<HumanPose3D> poses;
    std::vector<Eigen::Matrix4d> cams;    
};
}
#endif
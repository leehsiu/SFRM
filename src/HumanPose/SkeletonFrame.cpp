#include"SkeletonFrame.h"

#include<fstream>
#include<sstream>

namespace vslap{



SkeletonFrame::SkeletonFrame(int id_,int w_,int h_,Eigen::Matrix3d K_){
    w = w_;
    h = h_;
    K = K_;
    frameId = id_;
    m_skeleton2ds.clear();        
}
SkeletonFrame::~SkeletonFrame(){
    m_skeleton2ds.clear();    
}
int SkeletonFrame::loadFile(std::string filename_){
    std::ifstream infile;
    infile.open(filename_);
    std::string curLine;

    while(std::getline(infile,curLine)){
        HumanPose2D tmp_pose2d;                
        double tmpDouble[3];
        sscanf(curLine.c_str(),"%lf %lf %lf",&tmpDouble[0],&tmpDouble[1],&tmpDouble[2]);
        tmp_pose2d.joints[0] = Eigen::Map<Eigen::Vector3d>(tmpDouble);        
        for(int lineCount=1;lineCount<18;lineCount++){
            std::getline(infile,curLine);
            sscanf(curLine.c_str(),"%lf %lf %lf",&tmpDouble[0],&tmpDouble[1],&tmpDouble[2]);
            tmp_pose2d.joints[lineCount] = Eigen::Map<Eigen::Vector3d>(tmpDouble);
        }
        m_skeleton2ds.push_back(tmp_pose2d);        
    }
    infile.close();    
}

}
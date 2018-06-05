#ifndef _VSLAP_MAIN_UI
#define _VSLAP_MAIN_UI

#include <pangolin/pangolin.h>
#include <boost/thread.hpp>
#include <opencv2/opencv.hpp>
#include "HumanPose/SkeletonFrame.h"

namespace vslap{

class VSLAPMainUI{
public:
    VSLAPMainUI(int width_,int height_,int nFrames_);
    ~VSLAPMainUI();

    int run();
    void render3DSkeleton();

    void addImageDisplay(cv::Mat img_);
    void RenderGroundPlane();
    void close();    
    void join();
    void addImageADisplay(cv::Mat img_);
    void addImageBDisplay(cv::Mat img_);
    void showEssential();
    int testA;
    int testB;
    Eigen::Matrix3d R1;
    Eigen::Matrix3d R2;
    Eigen::Vector3d t;
    HumanPose3D m_pose;
private:
    bool running;
    int width;
    int height;
    boost::thread mainThread_;
    
    unsigned char * internalImgData;
    unsigned char * internalImgDataA;
    unsigned char * internalImgDataB;
    cv::Mat internalImg;
    boost::mutex imgMutex;
    bool imgUpdated;
    int nFrames;
    //Render Pose Structure
    
    
};

}

#endif


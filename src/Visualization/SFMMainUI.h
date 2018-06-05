#ifndef _VSLAP_SFMMAIN_UI
#define _VSLAP_SFMMAIN_UI

#include <pangolin/pangolin.h>
#include <boost/thread.hpp>
#include <opencv2/opencv.hpp>
#include "HumanPose/SkeletonFrame.h"

namespace vslap{

class VSFMMainUI{
public:
    VSFMMainUI(int width_,int height_,int nFrames_);
    ~VSFMMainUI();    
    int run();
    void RenderGroundPlane();
    void close();    
    void join();
    void addImageDisplay(cv::Mat img_);
  
    bool imageLoaded;
private:    
    bool running;
    int width;
    int height;
    //pangolin::GlTexture texImgB(width, height, GL_RGB, false, 0, GL_RGB, GL_UNSIGNED_BYTE);
    boost::thread mainThread_;
    //  ctex->Upload((unsigned char *)internalImg.data, GL_BGR, GL_UNSIGNED_BYTE);
    boost::mutex imgMutex;
   
    //Render Pose Structure        
};

}

#endif


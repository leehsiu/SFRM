#ifndef _MAIN_SYSTEM_
#define _MAIN_SYSTEM_

#include<vector>
#include<Eigen/Core>
#include<Eigen/Dense>
#include<string>
#include"HumanPose/SkeletonFrame.h"
#include"Visualization/MainUI.h"
#include"Visualization/SFMMainUI.h"
#include"boost/thread.hpp"
#include<deque>

namespace vslap
{

class VSLAPMainUI;
class VSFMMainUI;
class SkeletonFrame;
class GeometrySolver;
class MainSystem
{
public:
    MainSystem();
    ~MainSystem();
    int InitalCalib(std::string filename_);
    int LoadFrames(std::string folder_);
    void testEssentialMatrix(int id1,int id2);        
    void testEssentialMatrixLoop();
    
    void letsGo();
    void letsTest();
    void runningThread();
    void setupUI();
    void joinAll();
    void calcSimilarityMatrix();//with Direct Essential Matrix
    
    void liveHandleFrame();
private:
    bool shouldExit;
    std::vector<SkeletonFrame> mFrames;
    std::vector<std::string> mImageName;
    std::deque<int> allFrameId;

    Eigen::Matrix3d K;
    Eigen::Matrix3d invK;
    int nFrames;
    int width;
    int height; 
    boost::thread mainThread_;       
    VSLAPMainUI *m_ui;
    VSFMMainUI * m_uiSFM;
    GeometrySolver * m_geoSolver;
};
}
#endif
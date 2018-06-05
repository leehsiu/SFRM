#include "MainSystem.h"
#include <fstream>
#include <boost/filesystem.hpp>
#include <vector>
#include <iostream>
#include "Geometry/Geometry.h"
#include "Global/settings.h"

namespace vslap
{

class VSLAPMainUI;

MainSystem::MainSystem()
{
    mFrames.clear();
    mImageName.clear();
    shouldExit = false;
}
MainSystem::~MainSystem()
{
}
int MainSystem::InitalCalib(std::string filename_)
{
    std::ifstream infile;
    infile.open(filename_);
    double fx, fy, cx, cy, gma;
    infile >> fx >> fy >> cx >> cy >> gma;
    K.setIdentity();

    K(0, 0) = fx;
    K(1, 1) = fy;
    K(0, 2) = cx;
    K(1, 2) = cy;
    invK = K.inverse();

    infile >> width >> height;
    infile.close();

    m_geoSolver = new GeometrySolver(K);    
    return 1;
}
int MainSystem::LoadFrames(std::string folder_)
{

    std::vector<std::string> allFiles;
    allFrameId.clear();
    boost::filesystem::path pose_dir(folder_);
    boost::filesystem::directory_iterator end_itr;
    for (boost::filesystem::directory_iterator itr(pose_dir); itr != end_itr; ++itr)
    {
        if (boost::filesystem::is_regular_file(itr->status()) && itr->path().extension() == ".p2d")
        {
            std::string cur_file = itr->path().string();
            allFiles.push_back(cur_file);
        }
        if (boost::filesystem::is_regular_file(itr->status()) && itr->path().extension() == ".jpg")
        {
            std::string cur_file = itr->path().string();
            mImageName.push_back(cur_file);
        }
    }
    std::sort(allFiles.begin(), allFiles.end());
    std::sort(mImageName.begin(), mImageName.end());

    for (int i = 0; i < allFiles.size(); i++)
    {
        SkeletonFrame tmpFrame(i, width, height, K);
        tmpFrame.loadFile(allFiles[i]);
        mFrames.push_back(tmpFrame);
        allFrameId.push_back(i);
    }
    nFrames = allFiles.size();
    return allFiles.size();
}
void MainSystem::calcSimilarityMatrix()
{
    std::cout<<"Let go test"<<std::endl;
    int nFrames = mFrames.size();
    Eigen::MatrixXd simMatrix(nFrames, nFrames);
    for (int i = 0; i < nFrames; i++)
    {
        for (int j = 0; j < nFrames; j++)
        {
            std::cout<<"Frame: "<<j<<std::endl;
            HumanPose2D skel1 = mFrames[i].getSkeleton(0);
            HumanPose2D skel2 = mFrames[j].getSkeleton(0);
            simMatrix(i, j) = m_geoSolver->HumanPoseResidual(skel1, skel2,1);
        }
       
    }
    std::ofstream matOut("/home/xiul/databag/cTxt.txt");
    matOut<<simMatrix;
    matOut.close();    
}
void MainSystem::letsTest()
{
    std::cout << "START Test Thread" << std::endl;
    mainThread_ = boost::thread(&MainSystem::testEssentialMatrixLoop, this);
}
void MainSystem::letsGo()
{
    std::cout << "START Main Thread" << std::endl;
    mainThread_ = boost::thread(&MainSystem::runningThread, this);
}
void MainSystem::setupUI()
{        
    std::cout<<"Start UI"<<std::endl;    
    m_ui = new VSLAPMainUI(width,height,nFrames);
    std::cout<<"UI started"<<std::endl;    
}
void MainSystem::joinAll()
{
    mainThread_.join();    
    m_ui ->join();
}

void MainSystem::runningThread()
{
    while (!shouldExit)
    {
        if (!allFrameId.empty())
        {
            int curFrameId = allFrameId.front();
            allFrameId.pop_front();
            std::string curImageName = mImageName[curFrameId];

            cv::Mat img = cv::imread(curImageName.c_str());
            m_ui->addImageDisplay(img);
        }
        else
        {
            //frame currently empty, waiting
            //m_uiSFM->imageLoaded = true;
        }
    }
}
void MainSystem::testEssentialMatrix(int id1, int id2)
{
    cv::Mat img1 = cv::imread(mImageName[id1].c_str());
    cv::Mat img2 = cv::imread(mImageName[id2].c_str());
    cv::imshow("img", img1);
    cv::imshow("img2", img2);
    cv::waitKey(-1);
    HumanPose2D skel1 = mFrames[id1].getSkeleton(0);
    HumanPose2D skel2 = mFrames[id2].getSkeleton(0);
    int nGoodPair = 0;
    Eigen::MatrixXd kps1;
    Eigen::MatrixXd kps2;
    for (int jId = 0; jId < BODY_JOINTS_NUM - 4; jId++)
    {

        if (skel1.joints[jId](2) * skel2.joints[jId](2) > GOOD_PAIR_TH)
        {
            kps1.conservativeResize(3, kps1.cols() + 1);
            kps1.col(kps1.cols() - 1) = skel1.joints[jId];

            kps2.conservativeResize(3, kps2.cols() + 1);
            kps2.col(kps2.cols() - 1) = skel2.joints[jId];
            nGoodPair++;
        }
    }
    Eigen::Matrix3d E = m_geoSolver->EssentialMatrix(kps1, kps2, nGoodPair);
    std::cout << E << std::endl;
    std::cout << m_geoSolver->m_R1 << std::endl;
    Eigen::Vector3d ea = m_geoSolver->m_R1.eulerAngles(2, 1, 0);
    std::cout << ea << std::endl;
    std::cout << m_geoSolver->m_t << std::endl;
}

void MainSystem::testEssentialMatrixLoop()
{
    while (!shouldExit)
    {
        int id1 = m_ui->testA;
        int id2 = m_ui->testB;
        cv::Mat img1 = cv::imread(mImageName[id1].c_str());
        cv::Mat img2 = cv::imread(mImageName[id2].c_str());
        m_ui->addImageADisplay(img1);
        m_ui->addImageBDisplay(img2);
        
        HumanPose2D skel1 = mFrames[id1].getSkeleton(0);
        HumanPose2D skel2 = mFrames[id2].getSkeleton(0);
        int nGoodPair = 0;
        Eigen::MatrixXd kps1;
        Eigen::MatrixXd kps2;
        HumanPose3D m_pose;
        m_geoSolver->DirectPoseLift(skel1,m_pose);
        m_ui->m_pose = m_pose;
        for (int jId = 0; jId < 5; jId++)
        {
            if (skel1.joints[TORSO_PART[jId]](2) > GOOD_PAIR_TH && skel2.joints[TORSO_PART[jId]](2) > GOOD_PAIR_TH)
            {
                kps1.conservativeResize(3, kps1.cols() + 1);
                kps1.col(kps1.cols() - 1) = skel1.joints[TORSO_PART[jId]];

                kps2.conservativeResize(3, kps2.cols() + 1);
                kps2.col(kps2.cols() - 1) = skel2.joints[TORSO_PART[jId]];
                nGoodPair++;
            }
        }
        int nearPair = 0;
        for (int jId = 0; jId < 4; jId++)
        {

            if (skel1.joints[NEAR_PART[jId]](2) > GOOD_PAIR_TH && skel2.joints[NEAR_PART[jId]](2) > GOOD_PAIR_TH)
            {
                kps1.conservativeResize(3, kps1.cols() + 1);
                kps1.col(kps1.cols() - 1) = skel1.joints[NEAR_PART[jId]];

                kps2.conservativeResize(3, kps2.cols() + 1);
                kps2.col(kps2.cols() - 1) = skel2.joints[NEAR_PART[jId]];
                nearPair++;
            }
        }
        Eigen::MatrixXd kps1All;
        Eigen::MatrixXd kps2All;
        for(int jId=0;jId<14;jId++){
            kps1All.conservativeResize(3, kps1All.cols() + 1);
            kps1All.col(kps1All.cols() - 1) = skel1.joints[jId];

            kps2All.conservativeResize(3, kps2All.cols() + 1);
            kps2All.col(kps2All.cols() - 1) = skel2.joints[jId];
        }

        if (nGoodPair == 5)
        {
            Eigen::Matrix3d E = m_geoSolver->EssentialMatrix(kps1, kps2, 5 + nearPair);
            double err = m_geoSolver->calcAlgebraicError(kps1All,kps2All,E);
            std::cout<<"Err:"<<err<<std::endl;
            m_ui->R1 = m_geoSolver->m_R1;
            m_ui->R2 = m_geoSolver->m_R2;
            m_ui->t =m_geoSolver->m_t;
        }
        else
        {
            m_ui->R1.setIdentity();
            m_ui->R2.setIdentity();
            m_ui->t.setZero();
        }
    }
}
}
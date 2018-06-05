#ifndef _VSLAP_GEOMETRY_H
#define _VSLAP_GEOMTRTY_H


#include <Eigen/Core>
#include <Eigen/Dense>
#include <Eigen/SVD>
#include <Eigen/Geometry>
#include<opencv2/opencv.hpp>
#include"Global/settings.h"
#include"HumanPose/SkeletonFrame.h"


namespace vslap
{
#define RESI_TOTAL 1



#define SLAP_E_NONE 1
#define SLAP_E_DEG 2
#define SLAP_E_OK 3

class GeometrySolver
{
  public:
    GeometrySolver();
    GeometrySolver(Eigen::Matrix3d K_);
    ~GeometrySolver();

    //Calculate   
    double ForceSolveEssentialMatrix(Eigen::MatrixXd pts1_, Eigen::MatrixXd pts2_);
    double ForceSolveHomographyMatrix(Eigen::MatrixXd pts1_, Eigen::MatrixXd pts2_);
    double CoreSolveResidual(Eigen::MatrixXd pts1_, Eigen::MatrixXd pts2_,Eigen::Matrix3d K);
    


    //
    void DirectPoseLift(HumanPose2D &pose2d_,HumanPose3D &pose3d_);
    Eigen::Matrix3d EssentialMatrix(Eigen::MatrixXd pts1_,Eigen::MatrixXd pts2_,int pairNum);    
    double calcAlgebraicError(Eigen::MatrixXd pts1_,Eigen::MatrixXd pts2_,Eigen::Matrix3d Emat);
    double calcAlgebraicErrorDirect(Eigen::MatrixXd pts1_,Eigen::MatrixXd pts2_,Eigen::Matrix3d Emat);
    double HumanPoseResidual(HumanPose2D &pose2d1_,HumanPose2D &pose2d2_,int method);


    Eigen::Matrix3d ForceEssential() { return m_forceEssential; }
    Eigen::Matrix3d ForceHomography() { return m_forceHomography; }    
    

    Eigen::Matrix3d m_R1;
    Eigen::Matrix3d m_R2;
    Eigen::Vector3d m_t;   
    
    //some basic function
    Eigen::Matrix3d skew_symmetric(Eigen::Vector3d vec);
  private:
    Eigen::Matrix3d m_forceEssential;    
    Eigen::Matrix3d m_forceHomography;
    Eigen::Matrix3d m_coreEssential;    
    Eigen::Matrix3d K;
    Eigen::Matrix3d invK;
    

    int m_coreType;

 
};
}
#endif
#include "Geometry.h"

#include <iostream>
#include <cmath>
#include <algorithm>
#include <vector>

namespace vslap
{

using namespace Eigen;
using namespace cv;
using namespace std;

GeometrySolver::GeometrySolver()
{
}
GeometrySolver::GeometrySolver(Eigen::Matrix3d K_)
{
    K = K_;
    invK = K.inverse();
}
GeometrySolver::~GeometrySolver()
{
}
double GeometrySolver::ForceSolveHomographyMatrix(Eigen::MatrixXd pts1_, Eigen::MatrixXd pts2_)
{
    int nPoints = pts1_.cols();
    if (nPoints < 4)
    {
        std::cout << "[Err]: Homography under-determined" << std::endl;
        return -1;
    }
    else
    {
        Eigen::MatrixXd A(nPoints, 9);
        A.setZero();
        for (int i = 0; i < nPoints; i++)
        {
            A.row(2 * i).head(3) = -pts1_.col(i).transpose();
            A.row(2 * i).tail(3) = pts2_(0, i) * pts1_.col(i).transpose();
            A.row(2 * i + 1).segment(3, 3) = -pts1_.col(i).transpose();
            A.row(2 * i + 1).tail(3) = pts2_(1, i) * pts1_.col(i).transpose();
        }
        JacobiSVD<MatrixXd> svdSolver(A, ComputeThinU | ComputeThinV);
        Eigen::VectorXd fVec = svdSolver.matrixV().col(8);
        m_forceHomography = Eigen::Map<Eigen::Matrix3d>(fVec.data());
        m_forceHomography.transposeInPlace();
        return svdSolver.singularValues()(8);
    }
}
double GeometrySolver::ForceSolveEssentialMatrix(Eigen::MatrixXd pts1_, Eigen::MatrixXd pts2_)
{
    //Input is on film plane
    int nPoints = pts1_.cols();
    if (nPoints <= 8)
    {
        m_forceEssential.setIdentity();
        return 1;
    }
    Eigen::MatrixXd A(nPoints * 2, 9);
    for (int i = 0; i < nPoints; i++)
    {
        Vector3d pts1_i = pts1_.col(i);
        Vector3d pts2_i = pts2_.col(i);
        Matrix3d p1xp2 = pts1_i * pts2_i.transpose();
        A.row(i) = Eigen::Map<VectorXd>(p1xp2.data(), p1xp2.size());
    }

    JacobiSVD<MatrixXd> svdSolver(A, ComputeThinU | ComputeThinV);

    Eigen::VectorXd fVec = svdSolver.matrixV().col(8);
    m_forceEssential = Eigen::Map<Eigen::Matrix3d>(fVec.data());

    return svdSolver.singularValues()(8);
}
double GeometrySolver::CoreSolveResidual(Eigen::MatrixXd pts1_, Eigen::MatrixXd pts2_, Eigen::Matrix3d K)
{
    //input is on pixel plane
    int nHomoPair = 0;
    MatrixXd homot1(5, 3);
    MatrixXd homot2(5, 3);
    for (int i = 0; i < HomoPartNum; i++)
    {
        if (pts1_(2, HomoPart[i]) > 0.5 && pts2_(2, HomoPart[i]) > 0.5)
        {
            nHomoPair++;
            homot1.col(i) = pts1_.col(HomoPart[i]);
            homot1(2, i) = 1;
            homot2.col(i) = pts2_.col(HomoPart[i]);
            homot2(2, i) = 1;
        }
    }

    if (nHomoPair < 5)
    {
        m_coreEssential.setIdentity();
        m_coreType = SLAP_E_NONE;
        return 0;
    }
    //First transfrom the points from pixel plane to film plane
    Eigen::Matrix3d invK = K.inverse();
    homot1 = invK * homot1;
    homot2 = invK * homot2;
    //solve the Homography
    ForceSolveHomographyMatrix(homot1, homot2);
    Eigen::Matrix3d MatHomo1x2 = m_forceHomography;
    ForceSolveHomographyMatrix(homot2, homot1);
    Eigen::Matrix3d MatHomo2x1 = m_forceHomography;

    //we get m_forceHomography

    //Transform other features
    MatrixXd nhomot1(9, 3);
    MatrixXd nhomot2(9, 3);

    int pairMask[9];
    for (int i = 0; i < nonHomoPartNum; i++)
    {
        nhomot1.col(i) = pts1_.col(nonHomoPart[i]);
        nhomot2.col(i) = pts2_.col(nonHomoPart[i]);
        if (pts1_(2, nonHomoPart[i]) > 0.5 && pts2_(2, nonHomoPart[i]) > 0.5)
        {
            nhomot1(2, i) = 1;
            nhomot2(2, i) = 1;
            pairMask[i] = 1;
        }
        else
        {
            nhomot1(2, i) = 0;
            nhomot2(2, i) = 0;
            pairMask[i] = 0;
        }
    }

    nhomot1 = invK * nhomot1;
    nhomot2 = invK * nhomot2;

    //Features Now in Film Plane
    Eigen::MatrixXd nhomor2(9, 3);
    Eigen::MatrixXd nhomor1(9, 3);
    nhomor2 = MatHomo1x2 * nhomot1;
    nhomor1 = MatHomo2x1 * nhomot1;

    int ngoodPair = 0;
    std::vector<int> goodPairId;
    goodPairId.clear();
    double homoResiTH = 3.0 / K(0, 0);
    for (int i = 0; i < 9; i++)
    {
        if (pairMask[i])
        {
            double nhomor1_3 = (nhomor1.col(i))(2);
            double nhomor2_3 = (nhomor2.col(i))(2);
            nhomor1.col(i) = nhomor1.col(i) / nhomor1_3;
            nhomor2.col(i) = nhomor2.col(i) / nhomor2_3;
            double homoResi1 = (nhomot1.col(i) - nhomor1.col(i)).norm();
            double homoResi2 = (nhomot2.col(i) - nhomor2.col(i)).norm();
            if (homoResi1 < homoResiTH && homoResi2 < homoResiTH)
            {
                pairMask[i] = 2;
            }
            else
            {
                goodPairId.push_back(i);
                ngoodPair++;
            }
        }
    }

    if (ngoodPair < 2)
    {
        //Not enough
        m_coreEssential = MatHomo1x2;
        m_coreType = SLAP_E_DEG;
        return 0;
    }
    std::vector<double> allResidual;
    allResidual.clear();
    for (int pi = 0; pi < ngoodPair; pi++)
    {
        for (int pj = pi + 1; pj < ngoodPair; pj++)
        {
            int pairId1 = goodPairId[pi];
            int pairId2 = goodPairId[pj];
            Eigen::Vector3d nhomor1_1 = nhomor1.col(pairId1);
            Eigen::Vector3d nhomot1_1 = nhomot1.col(pairId1);
            Eigen::Vector3d nhomor1_2 = nhomor1.col(pairId2);
            Eigen::Vector3d nhomot1_2 = nhomot1.col(pairId2);
            Eigen::Vector3d ll11 = nhomor1_1.cross(nhomot1_1);
            Eigen::Vector3d ll12 = nhomor1_2.cross(nhomot1_2);
            Eigen::Vector3d epp1 = ll11.cross(ll12);

            Eigen::Vector3d nhomor2_1 = nhomor2.col(pairId1);
            Eigen::Vector3d nhomot2_1 = nhomot2.col(pairId1);
            Eigen::Vector3d nhomor2_2 = nhomor2.col(pairId2);
            Eigen::Vector3d nhomot2_2 = nhomot2.col(pairId2);
            Eigen::Vector3d ll21 = nhomor2_1.cross(nhomot2_1);
            Eigen::Vector3d ll22 = nhomor2_2.cross(nhomot2_2);
            Eigen::Vector3d epp2 = ll21.cross(ll22);

            std::vector<double> testDist;
            testDist.clear();
            for (int testId = 0; testId < 9; testId++)
            {
                if (testId != pairId1 && testId != pairId2 && pairMask[testId])
                {
                    Eigen::Vector3d nhomor1_test = nhomor1.col(testId);
                    Eigen::Vector3d epl1 = epp1.cross(nhomor1_test);
                    epl1 = epl1 / epl1.head(2).norm();
                    double dist1 = std::fabs(epl1.dot(nhomot1.col(testId)));

                    Eigen::Vector3d nhomor2_test = nhomor2.col(testId);
                    Eigen::Vector3d epl2 = epp2.cross(nhomor2_test);
                    epl2 = epl2 / epl2.head(2).norm();
                    double dist2 = std::fabs(epl2.dot(nhomot2.col(testId)));
                    testDist.push_back(std::max(dist1, dist2));
                }
            }
            double curResidual = *std::max_element(testDist.begin(), testDist.end());
            allResidual.push_back(curResidual);
        }
    }
    std::vector<double>::iterator max_iter = std::max_element(allResidual.begin(), allResidual.end());

    double maxResidual = *max_iter;
    int maxIndex = (max_iter - allResidual.begin());

    int pimax;
    int pjmax;
    int pixpj = 0;
    bool findmax = false;
    for (int pi = 0; pi < ngoodPair; pi++)
    {
        for (int pj = pi + 1; pj < ngoodPair; pj++)
        {
            if (pixpj == maxIndex)
            {
                pimax = pi;
                pjmax = pj;
                findmax = true;
                break;
            }
            else
            {
                pixpj++;
            }
        }
        if (findmax)
        {
            break;
        }
    }
    int pairId1 = goodPairId[pimax];
    int pairId2 = goodPairId[pjmax];

    Eigen::Vector3d nhomor1_1 = nhomor1.col(pairId1);
    Eigen::Vector3d nhomot1_1 = nhomot1.col(pairId1);
    Eigen::Vector3d nhomor1_2 = nhomor1.col(pairId2);
    Eigen::Vector3d nhomot1_2 = nhomot1.col(pairId2);
    Eigen::Vector3d ll11 = nhomor1_1.cross(nhomot1_1);
    Eigen::Vector3d ll12 = nhomor1_2.cross(nhomot1_2);
    Eigen::Vector3d epp1 = ll11.cross(ll12);
    Eigen::Matrix3d epp1_cross = skew_symmetric(epp1);
    m_coreEssential = epp1_cross * MatHomo1x2;
    m_coreType = SLAP_E_OK;
    return maxResidual;
}
Eigen::Matrix3d GeometrySolver::skew_symmetric(Eigen::Vector3d vec)
{
    Eigen::Matrix3d ret;
    ret.setZero();
    ret(0, 1) = -vec(2);
    ret(0, 2) = vec(1);
    ret(1, 0) = vec(2);
    ret(1, 2) = -vec(0);
    ret(2, 0) = -vec(1);
    ret(2, 1) = vec(0);
    return ret;
}
Eigen::Matrix3d GeometrySolver::EssentialMatrix(Eigen::MatrixXd pts1_, Eigen::MatrixXd pts2_, int pairNum)
{
    vector<Point2d> pts1vec(pairNum);
    vector<Point2d> pts2vec(pairNum);
    for (int i = 0; i < pairNum; i++)
    {
        pts1vec[i] = Point2d(pts1_(0, i), pts1_(1, i));
        pts2vec[i] = Point2d(pts2_(0, i), pts2_(1, i));
    }

    Mat E, R1, R2, t;
    E = findEssentialMat(pts1vec, pts2vec, K(0, 0), Point2d(K(0, 2), K(1, 2)), RANSAC, 0.999, 1);

    decomposeEssentialMat(E, R1, R2, t);
    //recoverPose(E, pts1vec, pts2vec, R, t, K(0, 0), Point2d(K(0, 2), K(1, 2)));
    m_R1 = Eigen::Map<Matrix3d>((double *)R1.data);
    m_R2 = Eigen::Map<Matrix3d>((double *)R2.data);
    m_t = Eigen::Map<Vector3d>((double *)t.data);
    return Eigen::Map<Matrix3d>((double *)E.data);
}
void GeometrySolver::DirectPoseLift(HumanPose2D &pose2d_, HumanPose3D &pose3d_)
{

    //1. Init with depth==1
    for (int jId = 0; jId < 14; jId++)
    {
        Eigen::Vector3d tmpPose = pose2d_.joints[jId];
        tmpPose(2) = 1;
        pose3d_.jointsPos[jId] = invK * tmpPose;
        if (pose2d_.joints[jId](2) > GOOD_PAIR_TH)
            pose3d_.jointLength[jId] = 1;
        else
            pose3d_.jointLength[jId] = -1;
    }

    //{1,8},
    //{1,11},
    if (pose3d_.jointLength[1] > 0 && pose3d_.jointLength[8] > 0 && pose3d_.jointLength[11] > 0)
    {
        Eigen::Vector3d vec1 = pose3d_.jointsPos[1] - pose3d_.jointsPos[8];
        Eigen::Vector3d vec2 = pose3d_.jointsPos[1] - pose3d_.jointsPos[11];
        double max_torso = vec1.norm() + vec2.norm();
        max_torso = max_torso / 2;
        for (int jId = 0; jId < 14; jId++)
        {
            pose3d_.jointsPos[jId] = pose3d_.jointsPos[jId] * 1 / (max_torso);
        }
    }
}
double GeometrySolver::calcAlgebraicError(Eigen::MatrixXd pts1_, Eigen::MatrixXd pts2_, Eigen::Matrix3d Emat){
    double epiError[14];
    pts1_.row(2).setConstant(1);
    pts2_.row(2).setConstant(1);
    Eigen::MatrixXd pts1_norm = invK * pts1_;
    Eigen::MatrixXd pts2_norm = invK * pts2_;
    MatrixXd epl2_ = Emat * pts1_norm;
    MatrixXd epl1_ = Emat.transpose() * pts2_norm;
    double finalError = 0;
    for (int i = 0; i < 14; i++)
    {
        epiError[i] = std::fabs((epl2_.col(i)).dot(pts2_norm.col(i))) / (epl2_.col(i).head(2).norm()) + std::fabs((epl1_.col(i)).dot(pts1_norm.col(i))) / (epl1_.col(i).head(2).norm());
        finalError = finalError + epiError[i];
    }
    return finalError;
}
double GeometrySolver::calcAlgebraicErrorDirect(Eigen::MatrixXd pts1_, Eigen::MatrixXd pts2_, Eigen::Matrix3d Emat)
{
    int numPoint = pts1_.cols();    
    pts1_.row(2).setConstant(1);
    pts2_.row(2).setConstant(1);
    Eigen::MatrixXd pts1_norm = invK * pts1_;
    Eigen::MatrixXd pts2_norm = invK * pts2_;
    MatrixXd epl2_ = Emat * pts1_norm;
    MatrixXd epl1_ = Emat.transpose() * pts2_norm;
    double maxError = 0;
    for (int i = 0; i < numPoint; i++)
    {
        double errC = std::fabs((epl2_.col(i)).dot(pts2_norm.col(i))) / (epl2_.col(i).head(2).norm()) + std::fabs((epl1_.col(i)).dot(pts1_norm.col(i))) / (epl1_.col(i).head(2).norm());
        if(errC<maxError){
            maxError = errC;
        }
    }
    return maxError*K(0,0);
}
double GeometrySolver::HumanPoseResidual(HumanPose2D &pose2d1_, HumanPose2D &pose2d2_, int method)
{
    double res;
    bool useMask[14];
    int  useNum = 0;
    vector<Point2d> pts1vec;
    vector<Point2d> pts2vec;        
    Eigen::MatrixXd pts1mat;
    Eigen::MatrixXd pts2mat;
    if (method == RESI_TOTAL)
    {

        for (int i = 0; i < 14; i++)
        {
            if (pose2d1_.joints[i](2) > GOOD_PAIR_TH || pose2d2_.joints[i](2) > GOOD_PAIR_TH)
            {
                pts1mat.conservativeResize(3, pts1mat.cols() + 1);
                pts1mat.col(pts1mat.cols() - 1) = pose2d1_.joints[i];                  
                pts2mat.conservativeResize(3, pts2mat.cols() + 1);
                pts2mat.col(pts2mat.cols() - 1) = pose2d2_.joints[i];                  
                pts1vec.push_back(Point2d(pose2d1_.joints[i](0), pose2d1_.joints[i](1)));
                pts2vec.push_back(Point2d(pose2d2_.joints[i](0), pose2d2_.joints[i](1)));                              
                useMask[i] = true;
                useNum++;
            }else{
                useMask[i] = false;
            }            
        }
        if(useNum>7){    
            Mat E = findEssentialMat(pts1vec, pts2vec, K(0, 0), Point2d(K(0, 2), K(1, 2)), RANSAC, 0.999, 1);
            Matrix3d E_mat = Eigen::Map<Matrix3d>((double *)E.data);
            res = calcAlgebraicErrorDirect(pts1mat,pts2mat,E_mat);            
        }else{
            res = 700;
        }    
    }    
    return res;    
}
}
#include "BlockViewer.h"
#include <iostream>
#include <sstream>
#include <fstream>
#include <Eigen/Core>
#include <Eigen/Dense>
namespace vslap
{

BlockViewer::BlockViewer(std::string _fod, int partNum_)
{

    running = true;
    curId = 0;
    boneL = 1;
    boneW = 0.5;
    allPoses.clear();
    //load all poses
    std::ifstream _ifile;
    _ifile.open(_fod);
    std::string curLine;
    std::stringstream ss;

    partNum = partNum_;
    int numJoint = partNum_;
    std::cout << numJoint << std::endl;
    while (std::getline(_ifile, curLine))
    {
        ss.str(std::string());
        ss.clear();
        ss << curLine;
        int tmpInt;
        ss >> tmpInt;
        HumanPose3D m_pose;
        for (int i = 0; i < numJoint; i++)
        {
            double tmpDouble[3];
            std::getline(_ifile, curLine);
            ss.str(std::string());
            ss.clear();
            ss << curLine;
            ss >> tmpDouble[0] >> tmpDouble[1] >> tmpDouble[2];
            m_pose.jointsPos[i] = Eigen::Map<Eigen::Vector3d>(tmpDouble);
        }
        allPoses.push_back(m_pose);
    }
    nFrames = allPoses.size();

    oriloc = allPoses[0].jointsPos[1];
    mainThread_ = boost::thread(&BlockViewer::run, this);
}
BlockViewer::~BlockViewer()
{
}

int BlockViewer::run()
{
    std::cout << "START Main UI" << std::endl;
    pangolin::CreateWindowAndBind("MainUI", 1280, 720);
    const int UI_WIDTH = 180;
    glEnable(GL_DEPTH_TEST);
    //glEnable(GL_BLEND);
    pangolin::OpenGlMatrix proj = pangolin::ProjectionMatrix(1280, 720, 700, 700, 640, 360, 0.1, 1000);
    pangolin::OpenGlRenderState display_cam(proj, pangolin::ModelViewLookAt(-0, -5, -10, 0, 0, 0, pangolin::AxisNegY));

    // Add named OpenGL viewport to window and provide 3D Handler
    pangolin::View &display_3d = pangolin::CreateDisplay()
                                     .SetBounds(0.0, 1.0, pangolin::Attach::Pix(UI_WIDTH), 1.0, -1280 / (float)720)
                                     .SetHandler(new pangolin::Handler3D(display_cam));
    std::cout << width << height << std::endl;
    // LayoutEqual is an EXPERIMENTAL feature - it requires that all sub-displays
    // share the same aspect ratio, placing them in a raster fasion in the
    // viewport so as to maximise display size.
    pangolin::CreateDisplay()
        .SetBounds(0.0, 0.3, pangolin::Attach::Pix(UI_WIDTH), 1.0)
        .SetLayout(pangolin::LayoutEqual);

    pangolin::CreatePanel("ui").SetBounds(0.0, 1.0, 0.0, pangolin::Attach::Pix(UI_WIDTH));
    pangolin::Var<int> settings_curId("ui.imageId", curId, 0, nFrames - 1, false);
    pangolin::Var<double> settings_BoneWidth("ui.boneWidth", boneW, 0.1, 1, false);
    pangolin::Var<double> settings_BoneScale("ui.boneScale", boneL, 1, 50, false);
    pangolin::Var<double> settings_worldHeight("ui.worldHeight", worldHeight, -50, 50, false);

    // Default hooks for exiting (Esc) and fullscreen (tab).
    while (!pangolin::ShouldQuit())
    {

        //glClearColor(1.0, 1.0, 1.0, 0);
        glClearColor(0.55, 0.55, 0.55, 0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // Generate random image and place in texture memory for display
        display_3d.Activate(display_cam);
        //Draw the ground plane
        RenderGroundPlane();
        if (partNum == 14 || partNum == 15)
            render3DSkeleton();
        if (partNum == 70)
            render3DFace();
        if(partNum==21)
            render3DHand();
        curId = settings_curId.Get();
        boneL = settings_BoneScale.Get();
        boneW = settings_BoneWidth.Get();
        worldHeight = settings_worldHeight.Get();
        pangolin::FinishFrame();
    }
    return 0;
}
void BlockViewer::close()
{
}
void BlockViewer::join()
{
    mainThread_.join();
}
// void VSLAPMainUI::showEssential()
// {
//     glPushMatrix();

//     int lineWidth = 5;
//     float fx = 400;
//     float fy = 400;
//     float cx = 320;
//     float cy = 240;
//     float sz = 2;

//     glColor3f(1, 0, 0);
//     glLineWidth(lineWidth);
//     glBegin(GL_LINES);
//     glVertex3f(0, 0, 0);
//     glVertex3f(sz * (0 - cx) / fx, sz * (0 - cy) / fy, sz);
//     glVertex3f(0, 0, 0);
//     glVertex3f(sz * (0 - cx) / fx, sz * (height - 1 - cy) / fy, sz);
//     glVertex3f(0, 0, 0);
//     glVertex3f(sz * (width - 1 - cx) / fx, sz * (height - 1 - cy) / fy, sz);
//     glVertex3f(0, 0, 0);
//     glVertex3f(sz * (width - 1 - cx) / fx, sz * (0 - cy) / fy, sz);

//     glVertex3f(sz * (width - 1 - cx) / fx, sz * (0 - cy) / fy, sz);
//     glVertex3f(sz * (width - 1 - cx) / fx, sz * (height - 1 - cy) / fy, sz);

//     glVertex3f(sz * (width - 1 - cx) / fx, sz * (height - 1 - cy) / fy, sz);
//     glVertex3f(sz * (0 - cx) / fx, sz * (height - 1 - cy) / fy, sz);

//     glVertex3f(sz * (0 - cx) / fx, sz * (height - 1 - cy) / fy, sz);
//     glVertex3f(sz * (0 - cx) / fx, sz * (0 - cy) / fy, sz);

//     glVertex3f(sz * (0 - cx) / fx, sz * (0 - cy) / fy, sz);
//     glVertex3f(sz * (width - 1 - cx) / fx, sz * (0 - cy) / fy, sz);

//     glEnd();

//     for (int i = 0; i < 4; i++)
//     {
//         glPushMatrix();
//         glMultMatrixf((GLfloat *)mm[i].data());
//         glColor3f(0, 1, 0);
//         glLineWidth(lineWidth);
//         glBegin(GL_LINES);
//         glVertex3f(0, 0, 0);
//         glVertex3f(sz * (0 - cx) / fx, sz * (0 - cy) / fy, sz);
//         glVertex3f(0, 0, 0);
//         glVertex3f(sz * (0 - cx) / fx, sz * (height - 1 - cy) / fy, sz);
//         glVertex3f(0, 0, 0);
//         glVertex3f(sz * (width - 1 - cx) / fx, sz * (height - 1 - cy) / fy, sz);
//         glVertex3f(0, 0, 0);
//         glVertex3f(sz * (width - 1 - cx) / fx, sz * (0 - cy) / fy, sz);

//         glVertex3f(sz * (width - 1 - cx) / fx, sz * (0 - cy) / fy, sz);
//         glVertex3f(sz * (width - 1 - cx) / fx, sz * (height - 1 - cy) / fy, sz);

//         glVertex3f(sz * (width - 1 - cx) / fx, sz * (height - 1 - cy) / fy, sz);
//         glVertex3f(sz * (0 - cx) / fx, sz * (height - 1 - cy) / fy, sz);

//         glVertex3f(sz * (0 - cx) / fx, sz * (height - 1 - cy) / fy, sz);
//         glVertex3f(sz * (0 - cx) / fx, sz * (0 - cy) / fy, sz);

//         glVertex3f(sz * (0 - cx) / fx, sz * (0 - cy) / fy, sz);
//         glVertex3f(sz * (width - 1 - cx) / fx, sz * (0 - cy) / fy, sz);
//         glEnd();
//         glPopMatrix();
//     }
//     glPopMatrix();
// }

void BlockViewer::RenderGroundPlane()
{

    glPushMatrix();
    double groundPlaneHeight = worldHeight;
    double groundPlaneSize = 50.0;
    const int planeResolution = 10;
    double planeIncrement = groundPlaneSize / planeResolution;
    for (int i = 0; i < planeResolution; i++)
    {

        for (int j = 0; j < planeResolution; j++)
        {
            if ((i % 2) ^ (j % 2))
                glColor3f(0.15, 0.15, 0.15);
            else
                glColor3f(0.85, 0.85, 0.85);

            glBegin(GL_QUADS);
            glVertex3f((float)(-groundPlaneSize / 2 + i * planeIncrement), (float)groundPlaneHeight, (float)(-groundPlaneSize / 2 + j * planeIncrement));
            glVertex3f((float)(-groundPlaneSize / 2 + i * planeIncrement), (float)groundPlaneHeight, (float)(-groundPlaneSize / 2 + (j + 1) * planeIncrement));
            glVertex3f((float)(-groundPlaneSize / 2 + (i + 1) * planeIncrement), (float)groundPlaneHeight, (float)(-groundPlaneSize / 2 + (j + 1) * planeIncrement));
            glVertex3f((float)(-groundPlaneSize / 2 + (i + 1) * planeIncrement), (float)groundPlaneHeight, (float)(-groundPlaneSize / 2 + j * planeIncrement));
            glEnd();
        }
    }
    glPopMatrix();
}
void BlockViewer::render3DSkeleton()
{

    //bone structure

    static Eigen::Vector3d z_dir = Eigen::Vector3d(0, 0, 1.0);
    glPushMatrix();
    GLUquadric *quad = gluNewQuadric();
    gluQuadricDrawStyle(quad, GLU_FILL);
    HumanPose3D m_pose = allPoses[curId];

    int showBone = partNum - 1;
    bool COCO = partNum == 14;

    for (int bid = 0; bid < showBone; bid++)
    {
        //move to bone pose
        int idStart = COCO ? BODY_TREE[bid][0] : BODY_TREE_MPI[bid][0];
        int idEnd = COCO ? BODY_TREE[bid][1] : BODY_TREE_MPI[bid][1];
        Eigen::Vector3d iPose = COCO ? m_pose.jointsPos[1] : m_pose.jointsPos[2];
        Eigen::Vector3d bPose = m_pose.jointsPos[idStart] - iPose;
        Eigen::Vector3d ePose = m_pose.jointsPos[idEnd] - iPose;
        Eigen::Vector3d bVec = ePose - bPose;
        double bLength = bVec.norm() * boneL;
        Eigen::Vector3d r_axis = z_dir.cross(bVec);
        double dot_prod = z_dir.adjoint() * bVec;
        double r_axis_len = r_axis.norm();
        double theta = atan2(r_axis_len, dot_prod);

        glPushMatrix();
        glTranslatef(bPose(0) * boneL, bPose(1) * boneL, bPose(2) * boneL);

        glColor3f(1, 0, 0);
        gluSphere(quad, boneW, 30, 30);
        glColor3f(BODY_PART_COLOR[idEnd][0] / 255.0, BODY_PART_COLOR[idEnd][1] / 255.0, BODY_PART_COLOR[idEnd][2] / 255.0);
        glRotatef(float(theta * 180. / 3.1415926), float(r_axis[0]), float(r_axis[1]), float(r_axis[2]));
        gluCylinder(quad, boneW, 0.3 * boneW, bLength, 30, 30);
        glPopMatrix();
    }
    glPopMatrix();
}
void BlockViewer::render3DFace()
{

    //bone structure
    static Eigen::Vector3d z_dir = Eigen::Vector3d(0, 0, 1.0);
    glPushMatrix();
    GLUquadric *quad = gluNewQuadric();
    gluQuadricDrawStyle(quad, GLU_FILL);
    HumanPose3D m_pose = allPoses[curId];

    //Face sequence
    //Sequence 1.
    //color1:
    int bbNum = 9;
    int FACE_T[][3] =
        {
            {6, 10, 0},
            {17, 21, 0},
            {22, 26, 0},
            {27, 30, 0},
            {31, 35, 0},
            {36, 41, 1},
            {42, 47, 1},
            {48, 59, 1},
            {60, 67, 1},
        };
    int FACE_COLOR[][3]=
    {
        {255,255,0},
        {0 ,255,0},
        {0 ,255,0},
        {0,255,0},
        {0,255,0},
        {0,0,255},
        {0,0,255},
        {255,255,0},
        {255,255,0}
    };
    Eigen::Vector3d iPose = m_pose.jointsPos[30];
    for (int bb = 0; bb < bbNum; bb++)
    {
        int bbs = FACE_T[bb][0];
        int bbe = FACE_T[bb][1];
        int isLoop = FACE_T[bb][2];
        for (int i = bbs; i < bbe; i++)
        {
            int idStart = i;
            int idEnd = i + 1;
            Eigen::Vector3d bPose = m_pose.jointsPos[idStart] - iPose;
            Eigen::Vector3d ePose = m_pose.jointsPos[idEnd] - iPose;
            Eigen::Vector3d bVec = ePose - bPose;
            double bLength = bVec.norm() * boneL;
            Eigen::Vector3d r_axis = z_dir.cross(bVec);
            double dot_prod = z_dir.adjoint() * bVec;
            double r_axis_len = r_axis.norm();
            double theta = atan2(r_axis_len, dot_prod);
            glPushMatrix();
            glTranslatef(bPose(0) * boneL, bPose(1) * boneL, bPose(2) * boneL);
            glColor3f(1, 0, 0);
            gluSphere(quad, boneW, 30, 30);
            glColor3f(FACE_COLOR[bb][0] / 255.0, FACE_COLOR[bb][1] / 255.0, FACE_COLOR[bb][2] / 255.0);
            glRotatef(float(theta * 180. / 3.1415926), float(r_axis[0]), float(r_axis[1]), float(r_axis[2]));
            gluCylinder(quad, boneW, boneW, bLength, 30, 30);
            glPopMatrix();
        }
        if (isLoop)
        {
            int idStart = bbe;
            int idEnd = bbs;
            Eigen::Vector3d bPose = m_pose.jointsPos[idStart] - iPose;
            Eigen::Vector3d ePose = m_pose.jointsPos[idEnd] - iPose;
            Eigen::Vector3d bVec = ePose - bPose;
            double bLength = bVec.norm() * boneL;
            Eigen::Vector3d r_axis = z_dir.cross(bVec);
            double dot_prod = z_dir.adjoint() * bVec;
            double r_axis_len = r_axis.norm();
            double theta = atan2(r_axis_len, dot_prod);
            glPushMatrix();
            glTranslatef(bPose(0) * boneL, bPose(1) * boneL, bPose(2) * boneL);
            glColor3f(1, 0, 0);
            gluSphere(quad, boneW, 30, 30);
            glColor3f(FACE_COLOR[bb][0] / 255.0, FACE_COLOR[bb][1] / 255.0, FACE_COLOR[bb][2] / 255.0);
            glRotatef(float(theta * 180. / 3.1415926), float(r_axis[0]), float(r_axis[1]), float(r_axis[2]));
            gluCylinder(quad, boneW, boneW, bLength, 30, 30);
            glPopMatrix();
        }
    }
    glPopMatrix();
}

void BlockViewer::render3DHand()
{

    //bone structure
    static Eigen::Vector3d z_dir = Eigen::Vector3d(0, 0, 1.0);
    glPushMatrix();
    GLUquadric *quad = gluNewQuadric();
    gluQuadricDrawStyle(quad, GLU_FILL);
    HumanPose3D m_pose = allPoses[curId];

    //Face sequence
    //Sequence 1.
    //color1:
    int bbNum = 5;
    int FACE_T[][3] =
        {
            {1, 4, 0},
            {5, 8, 0},
            {9, 12, 0},
            {13, 16, 0},
            {17, 20, 0},
        };

    Eigen::Vector3d iPose = m_pose.jointsPos[0];
    for (int bb = 0; bb < bbNum; bb++)
    {
        int bbs = FACE_T[bb][0];
        int bbe = FACE_T[bb][1];
        int isLoop = FACE_T[bb][2];
        for (int i = bbs; i < bbe; i++)
        {
            int idStart = i;
            int idEnd = i + 1;
            Eigen::Vector3d bPose = m_pose.jointsPos[idStart] - iPose;
            Eigen::Vector3d ePose = m_pose.jointsPos[idEnd] - iPose;
            Eigen::Vector3d bVec = ePose - bPose;
            double bLength = bVec.norm() * boneL;
            Eigen::Vector3d r_axis = z_dir.cross(bVec);
            double dot_prod = z_dir.adjoint() * bVec;
            double r_axis_len = r_axis.norm();
            double theta = atan2(r_axis_len, dot_prod);
            glPushMatrix();
            glTranslatef(bPose(0) * boneL, bPose(1) * boneL, bPose(2) * boneL);
            glColor3f(1, 0, 0);
            gluSphere(quad, boneW, 30, 30);
            glColor3f(HAND_PART_COLOR[bb+1][0] / 255.0, HAND_PART_COLOR[bb+1][1] / 255.0, HAND_PART_COLOR[bb+1][2] / 255.0);
            glRotatef(float(theta * 180. / 3.1415926), float(r_axis[0]), float(r_axis[1]), float(r_axis[2]));
            gluCylinder(quad, boneW, boneW, bLength, 30, 30);
            glPopMatrix();
        }

        int idStart = 0;
        int idEnd = FACE_T[bb][0];
        Eigen::Vector3d bPose = m_pose.jointsPos[idStart] - iPose;
        Eigen::Vector3d ePose = m_pose.jointsPos[idEnd] - iPose;
        Eigen::Vector3d bVec = ePose - bPose;
        double bLength = bVec.norm() * boneL;
        Eigen::Vector3d r_axis = z_dir.cross(bVec);
        double dot_prod = z_dir.adjoint() * bVec;
        double r_axis_len = r_axis.norm();
        double theta = atan2(r_axis_len, dot_prod);
        glPushMatrix();
        glTranslatef(bPose(0) * boneL, bPose(1) * boneL, bPose(2) * boneL);
        glColor3f(1, 0, 0);
        gluSphere(quad, boneW*1.2, 30, 30);
        glColor3f(HAND_PART_COLOR[bb+1][0] / 255.0, HAND_PART_COLOR[bb+1][1] / 255.0, HAND_PART_COLOR[bb+1][2] / 255.0);
        glRotatef(float(theta * 180. / 3.1415926), float(r_axis[0]), float(r_axis[1]), float(r_axis[2]));
        gluCylinder(quad, boneW, boneW, bLength, 30, 30);
        glPopMatrix();
    }
    glPopMatrix();
}
}

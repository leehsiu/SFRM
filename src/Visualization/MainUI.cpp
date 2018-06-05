#include "MainUI.h"
#include <iostream>
#include <Eigen/Geometry>
#include <Eigen/Dense>
namespace vslap
{

VSLAPMainUI::VSLAPMainUI(int width_, int height_,int nFrames_)
{

    width = width_ / 2;
    height = height_ / 2;
    width = 720;
    height = 360;
    internalImgData = new unsigned char[3 * width * height];

    internalImgDataA = new unsigned char[3 * width * height];
    internalImgDataB = new unsigned char[3 * width * height];
    boost::unique_lock<boost::mutex> lk(imgMutex);
    internalImg = cv::Mat(height, width, CV_8UC3);

    imgUpdated = false;
    running = true;
    R1.setIdentity();
    R2.setIdentity();
    testA = 1;
    testB = 1;
    nFrames = nFrames_;

    mainThread_ = boost::thread(&VSLAPMainUI::run, this);
}
VSLAPMainUI::~VSLAPMainUI()
{
}

int VSLAPMainUI::run()
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
                                     .SetBounds(0.0, 1.0, pangolin::Attach::Pix(UI_WIDTH), 1.0, -width / (float)height)
                                     .SetHandler(new pangolin::Handler3D(display_cam));
    std::cout << width << height << std::endl;
    pangolin::View &d_imgA = pangolin::Display("imgA")
                                 .SetAspect(width / height);

    pangolin::View &d_imgB = pangolin::Display("imgB")
                                 .SetAspect(width / height);
    // LayoutEqual is an EXPERIMENTAL feature - it requires that all sub-displays
    // share the same aspect ratio, placing them in a raster fasion in the
    // viewport so as to maximise display size.
    pangolin::CreateDisplay()
        .SetBounds(0.0, 0.3, pangolin::Attach::Pix(UI_WIDTH), 1.0)
        .SetLayout(pangolin::LayoutEqual)
        .AddDisplay(d_imgA)
        .AddDisplay(d_imgB);

    pangolin::CreatePanel("ui").SetBounds(0.0, 1.0, 0.0, pangolin::Attach::Pix(UI_WIDTH));
    pangolin::Var<int> settings_imgA("ui.imageA", testA, 0, nFrames-1, false);
    pangolin::Var<int> settings_imgB("ui.imageB", testB, 0, nFrames-1, false);

    pangolin::GlTexture texImgA(width, height, GL_RGB, false, 0, GL_RGB, GL_UNSIGNED_BYTE);
    pangolin::GlTexture texImgB(width, height, GL_RGB, false, 0, GL_RGB, GL_UNSIGNED_BYTE);

    // Default hooks for exiting (Esc) and fullscreen (tab).
    while (!pangolin::ShouldQuit())
    {

        //glClearColor(1.0, 1.0, 1.0, 0);
        glClearColor(0.55, 0.55, 0.55, 0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // Generate random image and place in texture memory for display

        imgMutex.lock();
        if (imgUpdated)
        {
            texImgA.Upload(internalImgDataA, GL_BGR, GL_UNSIGNED_BYTE);
            texImgB.Upload(internalImgDataB, GL_BGR, GL_UNSIGNED_BYTE);
        }
        imgUpdated = false;
        imgMutex.unlock();

        glColor3f(1.0, 1.0, 1.0);
        display_3d.Activate(display_cam);
        //Draw the ground plane
        RenderGroundPlane();
        showEssential();
        render3DSkeleton();
 

        d_imgA.Activate();
        glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
        texImgA.RenderToViewportFlipY();

        d_imgB.Activate();
        glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
        texImgB.RenderToViewportFlipY();
        // Swap frames and Process Events

        testA = settings_imgA.Get();
        testB = settings_imgB.Get();
        pangolin::FinishFrame();
    }
    internalImg.release();
    delete internalImgData;

    return 0;
}
void VSLAPMainUI::close()
{
}
void VSLAPMainUI::join()
{
    mainThread_.join();
}
void VSLAPMainUI::addImageDisplay(cv::Mat img_)
{
    boost::unique_lock<boost::mutex> lk(imgMutex);
    cv::resize(img_, internalImg, internalImg.size());
    memcpy(internalImgData, (unsigned char *)internalImg.data, width * height * 3 * sizeof(unsigned char));
    imgUpdated = true;
}
void VSLAPMainUI::addImageADisplay(cv::Mat img_)
{
    boost::unique_lock<boost::mutex> lk(imgMutex);
    cv::resize(img_, internalImg, internalImg.size());
    memcpy(internalImgDataA, (unsigned char *)internalImg.data, width * height * 3 * sizeof(unsigned char));
    imgUpdated = true;
}
void VSLAPMainUI::addImageBDisplay(cv::Mat img_)
{
    boost::unique_lock<boost::mutex> lk(imgMutex);
    cv::resize(img_, internalImg, internalImg.size());
    memcpy(internalImgDataB, (unsigned char *)internalImg.data, width * height * 3 * sizeof(unsigned char));
    imgUpdated = true;
}
void VSLAPMainUI::showEssential()
{
    glPushMatrix();
    Eigen::Matrix4d m;

    Eigen::Matrix4f mm[4];

    m.setIdentity();
    m.topLeftCorner(3, 3) = R1;
    m.col(3).head(3) = t * 2;
    mm[0] = m.cast<float>();

    m.setIdentity();
    m.topLeftCorner(3, 3) = R1;
    m.col(3).head(3) = -t * 2;
    mm[1] = m.cast<float>();

    m.setIdentity();
    m.topLeftCorner(3, 3) = R2;
    m.col(3).head(3) = t * 2;
    mm[2] = m.cast<float>();

    m.setIdentity();
    m.topLeftCorner(3, 3) = R2;
    m.col(3).head(3) = -t * 2;
    mm[3] = m.cast<float>();

    int lineWidth = 5;
    float fx = 400;
    float fy = 400;
    float cx = 320;
    float cy = 240;
    float sz = 2;

    glColor3f(1, 0, 0);
    glLineWidth(lineWidth);
    glBegin(GL_LINES);
    glVertex3f(0, 0, 0);
    glVertex3f(sz * (0 - cx) / fx, sz * (0 - cy) / fy, sz);
    glVertex3f(0, 0, 0);
    glVertex3f(sz * (0 - cx) / fx, sz * (height - 1 - cy) / fy, sz);
    glVertex3f(0, 0, 0);
    glVertex3f(sz * (width - 1 - cx) / fx, sz * (height - 1 - cy) / fy, sz);
    glVertex3f(0, 0, 0);
    glVertex3f(sz * (width - 1 - cx) / fx, sz * (0 - cy) / fy, sz);

    glVertex3f(sz * (width - 1 - cx) / fx, sz * (0 - cy) / fy, sz);
    glVertex3f(sz * (width - 1 - cx) / fx, sz * (height - 1 - cy) / fy, sz);

    glVertex3f(sz * (width - 1 - cx) / fx, sz * (height - 1 - cy) / fy, sz);
    glVertex3f(sz * (0 - cx) / fx, sz * (height - 1 - cy) / fy, sz);

    glVertex3f(sz * (0 - cx) / fx, sz * (height - 1 - cy) / fy, sz);
    glVertex3f(sz * (0 - cx) / fx, sz * (0 - cy) / fy, sz);

    glVertex3f(sz * (0 - cx) / fx, sz * (0 - cy) / fy, sz);
    glVertex3f(sz * (width - 1 - cx) / fx, sz * (0 - cy) / fy, sz);

    glEnd();

    for (int i = 0; i < 4; i++)
    {
        glPushMatrix();
        glMultMatrixf((GLfloat *)mm[i].data());
        glColor3f(0, 1, 0);
        glLineWidth(lineWidth);
        glBegin(GL_LINES);
        glVertex3f(0, 0, 0);
        glVertex3f(sz * (0 - cx) / fx, sz * (0 - cy) / fy, sz);
        glVertex3f(0, 0, 0);
        glVertex3f(sz * (0 - cx) / fx, sz * (height - 1 - cy) / fy, sz);
        glVertex3f(0, 0, 0);
        glVertex3f(sz * (width - 1 - cx) / fx, sz * (height - 1 - cy) / fy, sz);
        glVertex3f(0, 0, 0);
        glVertex3f(sz * (width - 1 - cx) / fx, sz * (0 - cy) / fy, sz);

        glVertex3f(sz * (width - 1 - cx) / fx, sz * (0 - cy) / fy, sz);
        glVertex3f(sz * (width - 1 - cx) / fx, sz * (height - 1 - cy) / fy, sz);

        glVertex3f(sz * (width - 1 - cx) / fx, sz * (height - 1 - cy) / fy, sz);
        glVertex3f(sz * (0 - cx) / fx, sz * (height - 1 - cy) / fy, sz);

        glVertex3f(sz * (0 - cx) / fx, sz * (height - 1 - cy) / fy, sz);
        glVertex3f(sz * (0 - cx) / fx, sz * (0 - cy) / fy, sz);

        glVertex3f(sz * (0 - cx) / fx, sz * (0 - cy) / fy, sz);
        glVertex3f(sz * (width - 1 - cx) / fx, sz * (0 - cy) / fy, sz);
        glEnd();
        glPopMatrix();
    }
    glPopMatrix();
}

void VSLAPMainUI::RenderGroundPlane()
{

    glPushMatrix();
    double groundPlaneHeight = 5.0;
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
void VSLAPMainUI::render3DSkeleton()
{
    //bone structure
    static Eigen::Vector3d z_dir = Eigen::Vector3d(0, 0, 1.0);
    glPushMatrix();
    GLUquadric *quad = gluNewQuadric();
    gluQuadricDrawStyle(quad, GLU_FILL);

    int showBone = 13;
    int ss = 5;
    for (int bid = 0; bid < showBone; bid++)
    {
        //move to bone pose
        int idStart = BODY_TREE[bid][0];
        int idEnd = BODY_TREE[bid][1];
        if (m_pose.jointLength[idEnd] < 0)
            continue;
        Eigen::Vector3d bPose = m_pose.jointsPos[idStart];
        Eigen::Vector3d ePose = m_pose.jointsPos[idEnd];
        Eigen::Vector3d bVec = ePose - bPose;
        double bLength = bVec.norm() * ss;
        Eigen::Vector3d r_axis = z_dir.cross(bVec);
        double dot_prod = z_dir.adjoint() * bVec;
        double r_axis_len = r_axis.norm();
        double theta = atan2(r_axis_len, dot_prod);

        glPushMatrix();
        glTranslatef(bPose(0) * ss, bPose(1) * ss, bPose(2) * ss);

        glColor3f(1, 0, 0);
        gluSphere(quad, 0.2, 30, 30);
        glColor3f(BODY_PART_COLOR[idEnd][0] / 255.0, BODY_PART_COLOR[idEnd][1] / 255.0, BODY_PART_COLOR[idEnd][2] / 255.0);
        glRotatef(float(theta * 180. / 3.1415926), float(r_axis[0]), float(r_axis[1]), float(r_axis[2]));
        gluCylinder(quad, 0.2, 0.1, bLength, 30, 30);
        glPopMatrix();
    }
    glPopMatrix();
}
}

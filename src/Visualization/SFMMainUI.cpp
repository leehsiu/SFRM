#include "SFMMainUI.h"
#include <iostream>
#include <Eigen/Geometry>
#include <Eigen/Dense>
#include <cmath>
namespace vslap
{

VSFMMainUI::VSFMMainUI(int width_, int height_, int nFrames_)
{
    width = 720;
    height = 360;

    boost::unique_lock<boost::mutex> lk(imgMutex);
    running = true;
    imageLoaded = false;
    mainThread_ = boost::thread(&VSFMMainUI::run, this);
}
VSFMMainUI::~VSFMMainUI()
{
}

int VSFMMainUI::run()
{
    std::cout << "START Main UI" << std::endl;
    pangolin::CreateWindowAndBind("MainUI", 1280, 720);
    std::cout << "Main UI started" << std::endl;
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
    // LayoutEqual is an EXPERIMENTAL feature - it requires that all sub-displays
    // share the same aspect ratio, placing them in a raster fasion in the
    // viewport so as to maximise display size.
    pangolin::CreateDisplay()
        .SetBounds(0.0, 0.3, pangolin::Attach::Pix(UI_WIDTH), 1.0)
        .SetLayout(pangolin::LayoutEqual);

    pangolin::CreatePanel("ui").SetBounds(0.0, 1.0, 0.0, pangolin::Attach::Pix(UI_WIDTH));
        

    // Default hooks for exiting (Esc) and fullscreen (tab).
    while (!pangolin::ShouldQuit())
    {

        //glClearColor(1.0, 1.0, 1.0, 0);
        glClearColor(0.55, 0.55, 0.55, 0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        // Generate random image and place in texture memory for display        
        if (imageLoaded)
        {          
            glColor3f(1.0, 1.0, 1.0);
            display_3d.Activate(display_cam);
        }
        // Swap frames and Process Events

        pangolin::FinishFrame();
    }

    return 0;
}
void VSFMMainUI::close()
{
}
void VSFMMainUI::join()
{
    mainThread_.join();
}

// void VSFMMainUI::RenderDistanceVector(Eigen::MatrixXd vec_)
// {    
//     int nWidth = int(std::sqrt(nFrames)) + 1;
//     double imageWidth = 36;
//     double imageHeight = 18;
//     double imageDepth = 10;
//     double allWidth = imageWidth * nWidth;
//     double allHeight = imageHeight * nWidth;
//     pangolin::GlTexture cTexture(width, height, GL_RGB, false, 0, GL_RGB, GL_UNSIGNED_BYTE);   
//     //  ctex->Upload((unsigned char *)internalImg.data, GL_BGR, GL_UNSIGNED_BYTE);
//     glPushMatrix();
//     for (int i = 0; i < nFrames; i++)
//     {
//         std::cout<<"Draw Images"<<std::endl;
//         cTexture.Upload((unsigned char *)texImages[i].data, GL_BGR, GL_UNSIGNED_BYTE);
//         glEnable(GL_TEXTURE_2D);  
//         cTexture.Bind();      
//         glBegin(GL_QUADS);
       
//         int idx = i % nWidth;
//         int idy = i / nWidth;
//         glTexCoord2f(0.0f, 0.0f);         
//         glVertex3f((float)(-allWidth / 2 + idx * imageHeight), (float)imageDepth, (float)(-allWidth / 2 + idy * imageWidth));
//         glTexCoord2f(1.0f, 0.0f); 
//         glVertex3f((float)(-allWidth / 2 + idx * imageHeight), (float)imageDepth, (float)(-allWidth / 2 + (idy + 1) * imageWidth));
//         glTexCoord2f(1.0f, 1.0f); 
//         glVertex3f((float)(-allWidth / 2 + (idx + 1) * imageHeight), (float)imageDepth, (float)(-allWidth / 2 + (idy + 1) * imageWidth));
//         glTexCoord2f(0.0f, 1.0f);
//         glVertex3f((float)(-allWidth / 2 + (idx + 1) * imageHeight), (float)imageDepth, (float)(-allWidth / 2 + idy * imageWidth));
//         glEnd();
//         glDisable(GL_TEXTURE_2D);
//     }
//     glPopMatrix();
// }
}

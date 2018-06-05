#include<iostream>
#include"HumanPose/SkeletonFrame.h"
#include"MainSystem/MainSystem.h"
#include<iostream>
#include<vector>
#include"Visualization/MainUI.h"


using namespace vslap;
int main(int argc,char *argv[]){
    
    MainSystem mSystem;
    mSystem.InitalCalib("/home/xiul/databag/10-14-4/camera.txt");
    //mSystem.LoadFrames(argv[1]);
    mSystem.LoadFrames("/home/xiul/databag/chinese_dancing/image_skeleton_origin");   
    mSystem.calcSimilarityMatrix();   
   // mSystem.setupUI();
   // mSystem.letsTest();
   // mSystem.joinAll();
    //mSystem.testEssentialMatrix(atoi(argv[1]),atoi(argv[2]));
    return 1;
    
}
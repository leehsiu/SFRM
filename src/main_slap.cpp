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
    mSystem.LoadFrames("/home/xiul/databag/girl_dancing/image_skeleton_origin");
    mSystem.setupUI();
    mSystem.letsGo();
    mSystem.joinAll();      
    return 1;    
}
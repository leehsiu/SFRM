#include<iostream>
#include<iostream>
#include<vector>
#include"Visualization/BlockViewer.h"


using namespace vslap;
int main(int argc,char *argv[]){    
    BlockViewer mViewer(argv[1],atoi(argv[2]));
    mViewer.join();
   
    return 1;
    
}
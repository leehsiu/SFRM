#ifndef _VSLAP_SETTINGS_H
#define _VSLAP_SETTINGS_H

#define BODY_JOINTS_NUM 100
#define GOOD_PAIR_TH 0.3
const int TORSO_PART[] = {1,2,5,8,11};
const int NEAR_PART[] = {3,6,9,12};
const int FAR_PART[] = {4,7,10,13};
const int BODY_TREE[][2] = {
    {1,0},
    {1,2},
    {1,5},
    {1,8},
    {1,11},
    {2,3},
    {3,4},
    {5,6},
    {6,7},
    {8,9},
    {9,10},
    {11,12},
    {12,13}
};
const int BODY_TREE_MPI[][2] = {
    {1,0},
    {0,2},
    {0,3},
    {3,4},
    {4,5},
    {2,6},
    {6,7},
    {7,8},
    {0,9},
    {9,10},
    {10,11},
    {2,12},
    {12,13},
    {13,14}
};



const int BODY_SYM_PAIR[][2] = {
    {1,2},
    {3,4},
    {5,7},
    {6,8},
    {9,11},
    {10,12}
};
const int BODY_PART_COLOR[][3] ={
    {255,0,85},
    {255,0,0},
    {255,85,0},
    {255,170,0},
    {255,255,0},
    {170,255,0},
    {85,255,0},
    {0,255,0},
    {0,255,85},
    {0,255,170},
    {0,255,255},
    {0,170,255},
    {0,85,255},
    {0,0,255},
    {255,0,170},
    {170,0,255},
    {255,0,255},
    {85,0,255}
};

const int HAND_PART_COLOR[][3] ={
    {255,0,85},    
    {255,85,0},    
    {255,255,0},    
    {85,255,0},    
    {0,255,85},    
    {0,255,255},    
    {0,85,255},    
    {255,0,170},    
    {255,0,255},    
};


const int HomoPart[] = {1, 2, 5, 8, 11};
const int nonHomoPart[] = {0, 3, 4, 6, 7, 9, 10, 12, 13};
const int HomoPartNum = 5;
const int nonHomoPartNum = 9;

#endif

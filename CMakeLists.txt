SET(PROJECT_NAME VSLAP)
PROJECT(${PROJECT_NAME})

CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
#set(CMAKE_VERBOSE_MAKEFILE ON)

set(BUILD_TYPE Release)
#set(BUILD_TYPE RelWithDebInfo)

set(EXECUTABLE_OUTPUT_PATH bin)
set(LIBRARY_OUTPUT_PATH lib)
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)


# required libraries

find_package(OpenGL REQUIRED)
find_package(Eigen3 REQUIRED)
find_package(OpenCV 3.1.0 REQUIRED)
find_package(Boost COMPONENTS system thread filesystem) 
find_package(Pangolin 0.2 REQUIRED)
find_package(Gflags)

if (GFLAGS_FOUND)
message("-- Found Google Flags header in: ${GFLAGS_INCLUDE_DIRS}, "
  "in namespace: ${GFLAGS_NAMESPACE}")
add_definitions(-DCERES_GFLAGS_NAMESPACE=${GFLAGS_NAMESPACE})
else (GFLAGS_FOUND)
message("-- Did not find Google Flags (gflags), Building without gflags "
  "- no tests or tools will be built!")
update_cache_variable(GFLAGS OFF)
endif (GFLAGS_FOUND)


find_package(Glog)
find_package(Ceres)


include_directories(${PROJECT_SOURCE_DIR}/src)
include_directories(${OpenGL_INCLUDE_DIR})
include_directories(${EIGEN3_INCLUDE_DIR}) 
include_directories(${Pangolin_INCLUDE_DIRS}) 
include_directories(${CERES_INCLUDE_DIRS})


set(CMAKE_CXX_FLAGS
   "-O2 -g -std=c++0x"
#   "${SSE_FLAGS} -O3 -g -std=c++0x -fno-omit-frame-pointer"
)

add_subdirectory(src)
# Sources files

#set_property( TARGET dso APPEND_STRING PROPERTY COMPILE_FLAGS -Wall )
add_executable(main_slap ${PROJECT_SOURCE_DIR}/src/main_slap.cpp)


target_link_libraries(
    main_slap     
    vslapmainsystem 
    vslaphumanpose 
    vslapgeometry 
    vslapUI
    boost_system 
    boost_thread 
    boost_filesystem
    ${Pangolin_LIBRARIES}
    ${OpenCV_LIBRARIES}
    )


add_executable(slap_test ${PROJECT_SOURCE_DIR}/src/slap_test.cpp)        
target_link_libraries(
    slap_test     
        vslapmainsystem 
        vslaphumanpose 
        vslapgeometry 
        vslapUI
        boost_system 
        boost_thread 
        boost_filesystem
        ${Pangolin_LIBRARIES}
        ${OpenCV_LIBRARIES}        
        )




add_executable(ba_test ${PROJECT_SOURCE_DIR}/src/ba_main.cpp)
target_link_libraries(
    ba_test 
    vslapgeometry     
    ceres           
    )



add_executable(pose_viewer ${PROJECT_SOURCE_DIR}/src/view_skeleton.cpp)            
target_link_libraries(        
pose_viewer     
vslapmainsystem 
vslaphumanpose 
vslapUI
boost_system 
boost_thread 
boost_filesystem
${Pangolin_LIBRARIES}
${OpenCV_LIBRARIES}        
)
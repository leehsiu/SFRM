WORK_DIR="/home/xiul/databag/walk3/"
~/workspace/openpose/build/examples/openpose/openpose.bin -model_folder "/home/xiul/workspace/openpose/models"\
														  -image_dir ${WORK_DIR}"image_0" \
														  -write_keypoint_json ${WORK_DIR}"image_skeleton_origin/" \
														  -write_images ${WORK_DIR}"image_skeleton_origin/"
														  #-image_dir ${WORK_DIR}"image_0/" \
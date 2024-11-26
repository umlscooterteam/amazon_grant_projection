# FROM ubuntu:focal
FROM ros:noetic-ros-core

SHELL ["/bin/bash", "-c"]

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

# # setup timezone
# RUN echo 'Etc/UTC' > /etc/timezone && \
#     ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
#     apt-get update && \
#     apt-get install -q -y --no-install-recommends tzdata && \
#     rm -rf /var/lib/apt/lists/*

# # install packages
# RUN apt-get update && apt-get install -q -y --no-install-recommends \
#     dirmngr \
#     gnupg2 \
#     && rm -rf /var/lib/apt/lists/*

# # setup keys
# RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# # setup sources.list
# RUN echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros1-latest.list

# # setup environment
# ENV LANG C.UTF-8
# ENV LC_ALL C.UTF-8

# ENV ROS_DISTRO noetic

# install ros packages
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     build-essential \
#     ros-noetic-ros-core=1.5.0-1* \
#     python3-catkin-tools \
#     && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-rosdep \
    python3-catkin-tools \
    build-essential \
    qtbase5-dev \
    qt5-qmake \
    && rm -rf /var/lib/apt/lists/*

# setup entrypoint
COPY ./ros_entrypoint.sh /
RUN chmod +x /ros_entrypoint.sh

# copy package.xml first for rosdep (so this doesn't run every time)
WORKDIR /catkin_ws
COPY ./src/amazon_grant_projection/package.xml ./src/amazon_grant_projection/package.xml
COPY ./src/projector_image_view/package.xml ./src/projector_image_view/package.xml
COPY ./src/rviz_camera_stream/package.xml ./src/rviz_camera_stream/package.xml

# this should probably merged back into the previous apt-get stuff
# I was just looking for a way to speed up the container build
RUN apt-get update && rosdep init && rosdep update \
    && rosdep install --from-paths src --ignore-src -r -y \
    && rm -rf /var/lib/apt/lists/*

# build pioneer stuff
COPY ./src ./src

RUN source /opt/ros/noetic/setup.bash \
    && catkin init && catkin build

ENTRYPOINT ["/ros_entrypoint.sh"]
# CMD ["bash"]
CMD ["roslaunch", "amazon_grant_projection", "projection.launch"]

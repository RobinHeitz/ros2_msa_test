ARG WORKSPACE=ros2_msa_test
ARG ROS_WS=ws
ARG ROS_DISTRO=humble

FROM ros:${ROS_DISTRO}


#install binary dependencies
RUN apt-get -qq update && apt-get -qq upgrade -y && apt-get install -y \
    nano \
    ros-${ROS_DISTRO}-rqt* \
    python3-pip \
    software-properties-common \
    python3-colcon-common-extensions \
    python3-rosdep \
    ros-${ROS_DISTRO}-moveit \
    ros-${ROS_DISTRO}-ros2-control \
    ros-${ROS_DISTRO}-joint-state-publisher \
    ros-${ROS_DISTRO}-joint-state-publisher-gui \
    ros-${ROS_DISTRO}-ur


RUN rm -rf /var/lib/apt/lists/*

COPY ws/src /${WORKSPACE}/src

ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics
ENV QT_X11_NO_MITSHM=1
ENV EDITOR=nano
ENV XDG_RUNTIME_DIR=/tmp


ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create a non-root user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support for the non-root user
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    # Cleanup
    && rm -rf /var/lib/apt/lists/* \
    && echo "source /usr/share/bash-completion/completions/git" >> /home/$USERNAME/.bashrc \
    && echo "if [ -f /opt/ros/${ROS_DISTRO}/setup.bash ]; then source /opt/ros/${ROS_DISTRO}/setup.bash; fi" >> /home/$USERNAME/.bashrc


RUN echo "export DISABLE_AUTO_TITLE=true" >> /home/$USERNAME/.bashrc
RUN echo 'LC_NUMERIC="en_US.UTF-8"' >> /home/$USERNAME/.bashrc
RUN echo "source /opt/ros/humble/setup.bash" >> /home/$USERNAME/.bashrc
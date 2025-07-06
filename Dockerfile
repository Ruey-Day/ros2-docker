FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install dependencies
RUN apt update && apt install -y \
    curl wget git gnupg2 lsb-release sudo locales nano \
    dbus-x11 x11-utils net-tools \
    python3 python3-pip \
    libgl1-mesa-glx libglu1-mesa libgl1-mesa-dri \
    libxrender1 libxrandr2 libxcursor1 libxi6 libxcomposite1 libxtst6 \
    && locale-gen en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    apt clean

# Set up ROS 2 Humble
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | \
    gpg --dearmor -o /etc/apt/trusted.gpg.d/ros.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/ros.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/ros2.list && \
    apt update && apt install -y ros-humble-desktop && \
    apt clean

# Install colcon
RUN pip3 install -U colcon-common-extensions

# Install PyBullet and useful packages
RUN pip3 install pybullet numpy opencv-python

# Source ROS setup on shell startup
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc

# Default command
CMD ["bash"]
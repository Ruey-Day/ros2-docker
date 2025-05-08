FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install base tools, GUI, and Python
RUN apt update && apt install -y \
    curl wget git gnupg2 lsb-release sudo locales nano \
    xfce4 xfce4-goodies tightvncserver xterm \
    dbus-x11 x11-utils net-tools \
    python3 python3-pip \
    && locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    apt clean

# Setup colcon
RUN pip3 install -U colcon-common-extensions

# Add ROS 2 Humble repo and GPG key
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | \
    gpg --dearmor -o /etc/apt/trusted.gpg.d/ros.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/ros.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/ros2.list

# Install ROS 2 Humble Desktop + Gazebo (ROS version)
RUN apt update && apt install -y \
    ros-humble-desktop \
    ros-humble-gazebo-ros-pkgs \
    ros-humble-gazebo-ros2-control \
    && apt clean

# Install noVNC and websockify for browser-based VNC
RUN apt update && apt install -y novnc websockify && \
    mkdir -p /root/.vnc

# Source ROS 2 on shell startup
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc

# Copy and set VNC startup script
COPY vnc-startup.sh /vnc-startup.sh
RUN chmod +x /vnc-startup.sh

CMD ["/vnc-startup.sh"]

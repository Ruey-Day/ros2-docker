FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install desktop environment, VNC server, and noVNC
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-terminal \
    tightvncserver \
    novnc \
    websockify \
    firefox \
    nano \
    vim \
    wget \
    curl \
    dbus-x11 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a user for VNC
RUN useradd -m -s /bin/bash ubuntu
RUN echo 'ubuntu:ubuntu' | chpasswd

# Set up VNC as ubuntu user
USER ubuntu
WORKDIR /home/ubuntu

# Create VNC directory and set password
RUN mkdir -p ~/.vnc
RUN echo 'ubuntu' | vncpasswd -f > ~/.vnc/passwd
RUN chmod 600 ~/.vnc/passwd

# Create a proper xstartup file
RUN echo '#!/bin/bash' > ~/.vnc/xstartup \
    && echo 'unset SESSION_MANAGER' >> ~/.vnc/xstartup \
    && echo 'unset DBUS_SESSION_BUS_ADDRESS' >> ~/.vnc/xstartup \
    && echo 'export XKL_XMODMAP_DISABLE=1' >> ~/.vnc/xstartup \
    && echo 'export XDG_CURRENT_DESKTOP="XFCE"' >> ~/.vnc/xstartup \
    && echo 'export XDG_SESSION_DESKTOP="xfce"' >> ~/.vnc/xstartup \
    && echo 'dbus-launch --exit-with-session startxfce4 &' >> ~/.vnc/xstartup \
    && chmod +x ~/.vnc/xstartup

# Switch back to root
USER root

# Create startup script that ensures desktop starts
RUN echo '#!/bin/bash' > /start-services.sh \
    && echo 'echo "Cleaning up any existing VNC sessions..."' >> /start-services.sh \
    && echo 'su - ubuntu -c "vncserver -kill :1 &> /dev/null || true"' >> /start-services.sh \
    && echo 'echo "Starting VNC server..."' >> /start-services.sh \
    && echo 'su - ubuntu -c "vncserver :1 -geometry 1920x1080 -depth 24"' >> /start-services.sh \
    && echo 'echo "Waiting for VNC to fully start..."' >> /start-services.sh \
    && echo 'sleep 5' >> /start-services.sh \
    && echo 'echo "Starting desktop environment manually if needed..."' >> /start-services.sh \
    && echo 'su - ubuntu -c "DISPLAY=:1 dbus-launch --exit-with-session startxfce4 &" || true' >> /start-services.sh \
    && echo 'echo "Starting noVNC..."' >> /start-services.sh \
    && echo 'cd /usr/share/novnc' >> /start-services.sh \
    && echo './utils/launch.sh --vnc localhost:5901 --listen 6080 &' >> /start-services.sh \
    && echo 'echo "Services started. Connect to http://localhost:6080"' >> /start-services.sh \
    && echo 'echo "VNC password: ubuntu"' >> /start-services.sh \
    && echo 'tail -f /dev/null' >> /start-services.sh \
    && chmod +x /start-services.sh

# Expose ports
EXPOSE 6080 5901

# Start services
CMD ["/start-services.sh"]
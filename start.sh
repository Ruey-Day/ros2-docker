#!/bin/bash
docker build -t ros2-vnc .
docker run -it --rm \
  -p 5901:5901 -p 6080:6080 \
  --name ros2-vnc-container \
  ros2-vnc

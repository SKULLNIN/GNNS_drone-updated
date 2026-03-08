#!/bin/bash
# ============================================================
# gNNS Drone — Install ROS 2 Foxy + Depth Camera Repo (Ubuntu 20.04)
# ============================================================
# This script installs ROS 2 Foxy (which works on Ubuntu 20.04)
# and Gazebo Ignition Fortress, required for the aaqibmahamood repo.
# ============================================================

set -e

echo "============================================================"
echo "Installing ROS 2 Foxy & Gazebo Ignition for Depth Camera"
echo "============================================================"

# 1. Setup Locale and Sources for ROS 2
echo "[1/4] Setting up ROS 2 Foxy sources..."
sudo apt update && sudo apt install -y locales curl gnupg2 lsb-release
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# 2. Add Gazebo Ignition Fortress Source
echo "[2/4] Setting up Gazebo Ignition sources..."
sudo wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null

# 3. Install Packages
echo "[3/4] Installing ROS 2, colcon, and Ignition Fortress (this will take a while)..."
sudo apt update
sudo apt install -y ros-foxy-desktop \
                    python3-colcon-common-extensions \
                    ignition-fortress \
                    ros-foxy-ros-ign-bridge

# 4. Clone and Build the Repo
echo "[4/4] Cloning Depth_Camera_Simulation repo and building..."
cd ~
rm -rf Depth_Camera_Simulation ~/d435_ws
git clone https://github.com/aaqibmahamood/Depth_Camera_Simulation.git

# Apply Foxy patches to the repo's CMakeLists and packages
sed -i 's/ros_gz_bridge/ros_ign_bridge/g' Depth_Camera_Simulation/d435_ws/src/depth_d435/package.xml 2>/dev/null || true
sed -i 's/ros_gz_interfaces/ros_ign_interfaces/g' Depth_Camera_Simulation/d435_ws/src/depth_d435/package.xml 2>/dev/null || true

cp -r Depth_Camera_Simulation/d435_ws ~/d435_ws
cd ~/d435_ws

# Setup ROS 2 env and build
source /opt/ros/foxy/setup.bash
colcon build

echo "============================================================"
echo "INSTALLATION COMPLETE!"
echo "To run the depth camera repo simulation:"
echo "1. source /opt/ros/foxy/setup.bash"
echo "2. source ~/d435_ws/install/setup.bash"
echo "3. ros2 launch depth_d435 one_robot_ign_launch.py"
echo "============================================================"

#!/bin/bash

# Configured for ros-kinetic

#=======================================================================
# verify that PC configuration matches requirements for training class
#=======================================================================

function print_result() {
  if [ $? -eq 0 ]; then   # check command result
    echo -e "\e[00;32m[OK]\e[00m"
  else
    echo -e "\e[00;31m[FAIL]\e[00m"
  fi
}

function check_internet() {
  echo "Checking internet connection... "
  printf "  - %-30s" "google.com:"
  print_result $(ping -q -c1 google.com &> /dev/null)
  printf "  - %-30s" "training wiki:"
  print_result $(/usr/bin/wget -q -O /dev/null https://github.com/ros-industrial/industrial_training/wiki)
 
} #end check_internet()

function fix_repo_version(){
  printf "      remote: %s   local: %s\n" "$REMOTE_GIT" "$LOCAL_GIT"
  cd $HOME/industrial_training
  git fetch -q https://github.com/ros-industrial/industrial_training.git
  git checkout -q -f origin/kinetic-devel
  git checkout -q -b kinetic-devel-origin
  REMOTE_GIT=$(git ls-remote -q https://github.com/ros-industrial/industrial_training.git kinetic-devel 2> /dev/null | cut -c1-6)
  LOCAL_GIT=$(cd $DIR &&  git rev-parse HEAD | cut -c1-6)
  printf "      remote: %s   local: %s\n" "$REMOTE_GIT" "$LOCAL_GIT"
  printf "  - %-30s" "re-check repo version:"
  print_result $([ "$REMOTE_GIT" == "$LOCAL_GIT" ])
}

function check_repo() {
  echo "Checking git repo status... "
  DIR=$(dirname "${BASH_SOURCE[0]}")
  printf "  - %-30s" "git repo exists:"
  print_result $(cd $DIR && git status &> /dev/null)
  printf "  - %-30s" "active branch:"
  ACTIVE_BRANCH=$(cd $DIR && git rev-parse --abbrev-ref HEAD)
  print_result [ $ACTIVE_BRANCH  == "kinetic-devel" ]
  printf "  - %-30s" "repo version:"
  REMOTE_GIT=$(git ls-remote -q https://github.com/ros-industrial/industrial_training.git kinetic-devel 2> /dev/null | cut -c1-6)
  LOCAL_GIT=$(cd $DIR && git rev-parse HEAD | cut -c1-6)
  print_result $([ "$REMOTE_GIT" == "$LOCAL_GIT" ])
  [ "$REMOTE_GIT" != "$LOCAL_GIT" ] && fix_repo_version

} #end check_repo()

function check_deb() {
  printf "  - %-30s" "$1:"
  print_result $(dpkg-query -s $1 &> /dev/null)
}

function check_debs() {
  echo "Checking debian packages... "
  check_deb meld
  check_deb ros-kinetic-desktop-full
  check_deb ros-kinetic-moveit
}

function check_bashrc() {
  echo "Checking .bashrc... "
  printf "  - %-30s" "\$ROS_ROOT:"
  if [ -z ${ROS_ROOT+x} ]; then
	print_result $(false)
  else
	print_result $([ $ROS_ROOT == "/opt/ros/kinetic/share/ros" ])
  fi  
}

function check_qt() {
  echo "Checking IDE... "
  printf "  - %-30s" "QT 5.7.0:"
  if [ -x $HOME/Qt5.7.0/Tools/QtCreator/bin/qtcreator ]; then
	print_result $(true)
  else 
	print_result $(false)
  fi
}

#---------------------------------------
# run the actual tests
#---------------------------------------

check_internet
check_repo
check_debs
check_bashrc
check_qt

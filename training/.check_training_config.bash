#!/bin/bash

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
  print_result $(/usr/bin/wget -q -O /dev/null http://aeswiki.datasys.swri.edu/rositraining/indigo/Exercises/)
 
} #end check_internet()

function check_repo() {
  echo "Checking git repo status... "
  DIR=$(dirname "${BASH_SOURCE[0]}")
  printf "  - %-30s" "git repo exists:"
  print_result $(cd $DIR && git status &> /dev/null)
  printf "  - %-30s" "active branch:"
  ACTIVE_BRANCH=$(cd $DIR && git rev-parse --abbrev-ref HEAD)
  print_result [ $ACTIVE_BRANCH  == "indigo-devel" ]
  printf "  - %-30s" "repo version:"
  REMOTE_GIT=$(git ls-remote -q http://github.com/ros-industrial/industrial_training.git indigo-devel 2> /dev/null | cut -c1-6)
  LOCAL_GIT=$(cd $DIR && git rev-parse HEAD | cut -c1-6)
  print_result $([ "$REMOTE_GIT" == "$LOCAL_GIT" ])
  [ "$REMOTE_GIT" != "$LOCAL_GIT" ] && printf "      remote: %s   local: %s\n" "$REMOTE_GIT" "$LOCAL_GIT"
} #end check_repo()

function check_deb() {
  printf "  - %-30s" "$1:"
  print_result $(dpkg-query -s $1 &> /dev/null)
}

function check_debs() {
  echo "Checking debian packages... "
  check_deb eclipse-cdt
  check_deb doxygen
  check_deb meld
  check_deb ros-indigo-desktop-full
  check_deb ros-indigo-industrial-core
  check_deb ros-indigo-moveit-full
  check_deb ros-indigo-universal-robot
  check_deb ros-indigo-rosdoc-lite
}

function check_bashrc() {
  echo "Checking .bashrc... "
  printf "  - %-30s" "\$ROS_DISTRO:"
  print_result $([ $ROS_DISTRO == "indigo" ])
  printf "  - %-30s" "\$ROSI_TRAINING:"
  print_result $([ -v ROSI_TRAINING ])
}

#---------------------------------------
# run the actual tests
#---------------------------------------

check_internet
check_repo
check_debs
check_bashrc


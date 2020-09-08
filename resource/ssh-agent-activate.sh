#!/bin/bash

# Purpose of this script:
# Allows re-use of the ssh-agent between different shell sessions/

# This script should be appended to your .bashrc; 

# Append the following:
# source ~/scripts/ssh-agent-activate.sh

# The logic of this script is as follows:
# 1. try to execute ssh-add -l, and redirect output to the /dev/null
# 2. check returned code of the previous command:
#   if it is == 2 (error connect to an agent):
#     check if ~/.ssh-agent-env is present and available for reading,  read it and pass its output to the bash
#     retry ssh-add -l
#     if code still 2:
#       create the ~/.ssh-agent-env file with the 660 permissions (read-write for an owner only)
#       start ssh-agent and redirects its output into the .ssh-agent-env file
#       read the .ssh-agent-env content and pass it via a pipe to the bash

ssh-add -l &>/dev/null
if [ $? -gt 0 ]; then
  test -r ~/.ssh-agent-env && \
    eval "$(<~/.ssh-agent-env)" >/dev/null
  ssh-add -l &>/dev/null
  if [ $? -gt 0 ]; then
    (umask 066; ssh-agent > ~/.ssh-agent-env)
    eval "$(<~/.ssh-agent-env)" >/dev/null
  fi
fi

# Add github as known host
mkdir -p ~/.ssh
touch ~/.ssh/known_hosts
ssh-keyscan github.com >> ~/.ssh/known_hosts

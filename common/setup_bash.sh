#!/bin/bash
source "utils.sh"

echo "export PS1='\\[\\033[1;36m\\]\\u\\[\\033[1;31m\\]@\\[\\033[1;32m\\]\\h:\\[\\033[1;35m\\]\\w\\[\\033[1;31m\\]\\\\$\\[\\033[0m\\] '" >> ~/.bashrc
source ~/.bashrc
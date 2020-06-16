#!/bin/bash

DEPENDENCIES_DIR="./10-dependencies"

if [[ -f "./tmp/install_env_dependencies" ]]; then
  echo
  echo "의존성을 이미 설치했습니다."
  echo

else

 . $DEPENDENCIES_DIR/$OS/00-dependency.sh

  while true; do
    yn=
    read -p "Do you wish to install this ? [y/n]" yn
    case $yn in
      [Yy]* ) break;;
      [Nn]* ) exit;;
      * ) echo "Please answer yes or no.";;
    esac
  done

  . $DEPENDENCIES_DIR/$OS/01-install.sh


  echo
  echo "설치를 완료 했습니다."
  echo 

  touch ./tmp/install_env_dependencies

fi



#!/bin/bash

echo
echo "[Check Root] root 권한 확인"

if [ "$EUID" -ne 0 ]; then
  echo -e "$Red"
  echo "[오류] root 권한으로 실행해주세요."
  echo -e "$Color_Off"
  exit 1
fi

echo "[Check Root] root 권한 확인 종료"
echo


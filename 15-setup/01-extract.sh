#!/bin/bash
SEVPN_LOCAL_EXTRACT_TMP="./tmp/sevpn_files"

if [[ -s $SEVPN_LOCAL_BIN_TEMP ]]; then

  echo
  echo "압축해제"
  echo

  mkdir -p $SEVPN_LOCAL_EXTRACT_TMP

  tar xzvf $SEVPN_LOCAL_BIN_TEMP --strip 1 -C $SEVPN_LOCAL_EXTRACT_TMP/

  echo "압축을 해제했습니다."

else
  echo "파일이 존재하지 않습니다."
  exit 1
fi

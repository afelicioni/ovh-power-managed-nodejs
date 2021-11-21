#!/usr/bin/env bash

PUBLICROOT="www"

CURRENTSCRIPT="$0"

rm -rf "${HOME:?}"/"${PUBLICROOT}"
mkdir -p "${HOME}"/"${PUBLICROOT}"
mv "${HOME}"/.workflow/.source/src/* "${HOME}"/"${PUBLICROOT}"

cat << EOF
==============================================================
OVH_APP_ENGINE=${OVH_APP_ENGINE}
OVH_APP_ENGINE_VERSION=${OVH_APP_ENGINE_VERSION}
OVH_ENVIRONMENT=${OVH_ENVIRONMENT}
PATH=${PATH}
==============================================================
EOF

# INFO https://docs.ovh.com/gb/en/web-power/getting-started-with-power-web-hosting/#restart-your-instance

mkdir -p "${HOME}"/"${PUBLICROOT}"/tmp
touch "${HOME}"/"${PUBLICROOT}"/tmp/restart.txt
sleep 30

echo "SETUP DONE"

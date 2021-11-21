#!/usr/bin/env bash

# default values for options
port=22
knownhosts=$HOME/.ssh/known_hosts

function scriptusage
{
cat << EOF
Usage: $0 --host <host> --fingerprint <fingerprint> [--port <port>] [--knownhosts <knownhosts>]
Example: $0 --host github.com --fingerprint nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8
Default port value is 22
Default knownhosts value is ~/.ssh/known_hosts
The script will download the ssh keys from <host>, check if any match
the <fingerprint>, and add that one to $knownhosts.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --host*)
      if [[ "$1" != *=* ]]; then shift; fi
      host="${1#*=}"
      ;;
    --fingerprint*|-f*)
      if [[ "$1" != *=* ]]; then shift; fi
      fingerprint="${1#*=}"
      ;;
    --port*|-p*)
      if [[ "$1" != *=* ]]; then shift; fi
      port="${1#*=}"
      ;;
    --knownhosts*|-k*)
      if [[ "$1" != *=* ]]; then shift; fi
      knownhosts="${1#*=}"
      ;;
    --help|-h)
      scriptusage
      exit 0
      ;;
    *)
      >&2 printf "Error: Invalid argument\n"
      scriptusage
      exit 1
      ;;
  esac
  shift
done

# Download the actual key (you cannot convert a fingerprint to the original key)
keys="$(ssh-keyscan -p $port $host |& grep -v ^\#)";
echo "$keys" | grep -v "^$host" # Show any errors
keys="$(echo "$keys" | grep "^$host")"; # Remove errors from the variable
if [ ${#keys} -lt 20 ]; then echo Error downloading keys; exit 2; fi

# Find which line contains the key matching this fingerprint
line=$(ssh-keygen -lf <(echo "$keys") | grep -n "$fingerprint" | cut -b 1-1)

if [ ${#line} -gt 0 ]; then  # If there was a matching fingerprint
    # Take that line
    key=$(head -$line <(echo "$keys") | tail -1)
    # Check if the key part (column 3) of that line is already in $knownhosts
    if [ -n "$(grep "$(echo "$key" | awk '{print $3}')" $knownhosts)" ]; then
        echo "Key already in $knownhosts."
    else
        # Add it to known hosts
        echo "$key" >> $knownhosts
        # And tell the user what kind of key they just added
        keytype=$(echo "$key" | awk '{print $2}')
        echo Fingerprint verified and $keytype key added to $knownhosts
    fi
else  # If there was no matching fingerprint
    echo NOT MATCHING! These are the received fingerprints:
    ssh-keygen -lf <(echo "$keys")
    echo Generated from these received keys:
    echo "$keys"
    exit 1
fi
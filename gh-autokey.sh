#!/bin/bash
set -e

# Generate SSH Key and Deploy to Github

# Access token must have admin:public_key for DELETE
TOKEN=$1  # For cli provided access token
# TOKEN=$(<.env) # Read from file access token

echo "Genrating ed25519 ssh key"
ssh-keygen -q -b 4096 -t ed25519 -N "" -f ~/.ssh/id_ed25519

# -q : quiet mode
# -b : bit strength
# -t : key type
# -N : no passphrase
# -f : filename

PUBKEY=`cat ~/.ssh/id_ed25519.pub`
TITLE="${USER}@${HOSTNAME}"

RESPONSE=`curl -s -H "Authorization: token ${TOKEN}" \
  -X POST --data-binary "{\"title\":\"${TITLE}\",\"key\":\"${PUBKEY}\"}" \
  https://api.github.com/user/keys`

KEYID=`echo $RESPONSE \
  | grep -o '\"id.*' \
  | grep -o "[0-9]*" \
  | grep -m 1 "[0-9]*"`

echo "Public key deployed to remote service"


echo "Starting ssh-agent"
eval "$(ssh-agent -s)"

echo "Adding generated SSH key to ssh-agent"
ssh-add ~/.ssh/id_ed25519

echo "Added SSH key to the ssh-agent"

# Test the SSH connection

echo "Testing SSH connection to Github"
ssh -T git@github.com
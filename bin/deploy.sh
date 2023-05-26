#!/usr/bin/env bash
#
# deploy.sh - part of ahnlak/cecil-website
#
# This script will check for a copy of Cecil (downloading the latest if not
# available), build the site and then rsync it. 
#
# It expects to be run from the root of the repository, but will move into
# that directory if necessary!
#
# It is assumed that ssh keys have been suitably set up in advance :-)


# These settings define where/how your site will be rsync'd to your host
# They should be the only things you need to edit to allow deployments to flow
RSYNC_DEST='user@hosting.co:public_html/'
RSYNC_OPTS=(-e "ssh -p 12345")


# Code begins...

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
REPO_DIR=`dirname ${SCRIPT_DIR}`

cd ${REPO_DIR}

# Step one, check that we have a copy of Cecil - firstly, is it in the path?
command -v cecil.phar >> /dev/null
if [[ $? -ne 0 ]]
then
  # Then do we have a local copy in our bin?
  if [[ ! -x ${SCRIPT_DIR}/cecil.phar ]]
  then
    cd ${SCRIPT_DIR}
    curl -LO https://cecil.app/cecil.phar -o ${SCRIPT_DIR}/cecil.phar
    chmod a+x cecil.phar
    cd -
  fi

  # Ensure that the bin is in our execute path too
  PATH=$PATH:${SCRIPT_DIR}
fi

# Step two, build the site
cecil.phar build
if [[ $? -ne 0 ]]
then
  echo "Cecil failed to build!"
  exit 1
fi

# Step three, upload that to the destination
echo "Deploying website..."
rsync -a --info=stats1 "${RSYNC_OPTS[@]}" _site/ ${RSYNC_DEST}

#!/bin/sh

# CONFIGURATION
DIRECTORY_ROOT="/var/www/PROJECT_NAME"
DIRECTORY_SLUG=$(date "+%Y%m%d-%s")
TMP_DIRECTORY_SLUG=$(date "+%s")
GIT_REPO_OWNER="REPO_OWNER"
GIT_REPO_NAME="REPO_NAME"
APACHE_USER="www-data"
APACHE_GROUP="www-data"

# Bitbucket/github repos. You can use your own repos.
# git@bitbucket.org
# git@github.com
GIT_REPO="git@bitbucket.org:"${GIT_REPO_OWNER}/${GIT_REPO_NAME}".git"

# DO NOT CHANGE ANYTHING BELOW THIS LINE

set -e
clear

# ASK INFO
echo "-----------------------------------------------"
echo "                RELEASE BUILDER                "
echo "                     BETA 1                    "
echo "Created by Sharapov A. (alexander@sharapov.biz)"
echo "-----------------------------------------------"
echo ""
read -p "TAG AND RELEASE VERSION: " VERSION
echo "-----------------------------------------------"
echo ""
#echo "Before continuing, confirm that you have done the following :)"
#echo ""
#read -p " - Added a changelog for "${VERSION}"?"
#read -p " - Set version in the readme.txt and main file to "${VERSION}"?"
#read -p " - Set stable tag in the readme.txt file to "${VERSION}"?"
#read -p " - Updated the POT file?"
#read -p " - Committed all changes up to GITHUB?"
#echo ""
read -p "PRESS [ENTER] TO BEGIN RELEASING "${VERSION}
clear

# VARS
ROOT_PATH=$(pwd)"/"
TARGET_RELEASE_DIR="release/"${DIRECTORY_SLUG}"-git"
TARGET_TMP_DIR="release/"${TMP_DIRECTORY_SLUG}

# CLONE GIT DIR
echo "Cloning GIT repository to the temp directory"
git clone --progress $GIT_REPO $TARGET_TMP_DIR || { echo "Unable to clone repo"; exit 1; }

# MOVE INTO GIT DIR
cd $ROOT_PATH$TARGET_TMP_DIR

#echo ""
#read -p "PRESS [ENTER] TO DEPLOY TAG "${VERSION}

# CHECKOUT RELEASE
echo "Checkout "${VERSION}
git checkout ${VERSION} || { echo "Unable to checkout "${VERSION}; exit 1; }

# REMOVE UNWANTED FILES & DIRECTORIES
echo "Delete unwanted files"
rm -Rf .git
rm -f .gitignore
rm -f composer.*
rm -f *.bat
rm -f README.md

# RENAME TO RELEASE DIR
mv $ROOT_PATH$TARGET_TMP_DIR $ROOT_PATH$TARGET_RELEASE_DIR

# MOVE INTO GIT DIR
cd $ROOT_PATH$TARGET_RELEASE_DIR

# SAVE VERSION ID
echo ${VERSION} >> version.md

echo "Creating symlinks"
ln -s $DIRECTORY_ROOT/vendor vendor
ln -s $DIRECTORY_ROOT/shared/data data
ln -s $DIRECTORY_ROOT/shared/uploads public_html/uploads
ln -s $DIRECTORY_ROOT/shared/data/logs log
ln -s $DIRECTORY_ROOT/shared/config/local.php config/autoload/local.php

#read -p "PRESS [ENTER] TO CHANGE WEB-ROOT AND RUN TAG"

echo "Changing web root"
ln -sfnv $ROOT_PATH$TARGET_RELEASE_DIR $ROOT_PATH"current"

echo "Changing permissions"
chown -h $APACHE_USER.$APACHE_USER public_html/uploads

echo "Version "${VERSION}" has been released"

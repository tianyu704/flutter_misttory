BUILD_NUMBER=16
VERSION_NAME=1.0.0

GIT_BRANCH=`git symbolic-ref HEAD 2>/dev/null | cut -d"/" -f 3`
if [ "$GIT_BRANCH" = "master" ]; then 
    GIT_BRANCH=""
else
    GIT_BRANCH="-$GIT_BRANCH"
fi;

export VERSION_NUMBER=$((BUILD_NUMBER+1))
export VERSION_NAME="$VERSION_NAME$GIT_BRANCH"

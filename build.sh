#!/bin/bash -e
# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Builds the Google Cloud DataLab base docker image. Usage:
#   build.sh [path_of_pydatalab_dir]
# If [path_of_pydatalab_dir] is provided, it will copy the content of that dir into image.
# Otherwise, it will get the pydatalab by "git clone" from pydatalab repo.

pushd $(pwd) >> /dev/null
HERE=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

# Build the docker image
if [ -n "$1" ]; then
  src_pydatalab=$(realpath "$1")
  rsync -avp "$src_pydatalab"/ pydatalab
else
  # Create empty dir to make docker build happy.
  mkdir -p pydatalab
fi

trap 'rm -rf pydatalab' exit

docker pull ubuntu:16.04
# Docker tag flags changed in an incompatible way between versions.
# The Datalab Jenkins build still uses the old one, so try it both ways.
if ! $(docker tag -f ubuntu:16.04 datalab-external-base-image); then
  docker tag ubuntu:16.04 datalab-external-base-image
fi
docker build ${DOCKER_BUILD_ARGS} -t datalab-base .

popd >> /dev/null

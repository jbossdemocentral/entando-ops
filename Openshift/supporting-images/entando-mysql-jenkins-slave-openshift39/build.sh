#!/usr/bin/env bash
export VERSION=${1:-5.2.0-SNAPSHOT}
export ENTANDO_IMAGE="entando-mysql-jenkins-slave-openshift39"
source ../../../common/build-common.sh


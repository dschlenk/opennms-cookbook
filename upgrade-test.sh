#!/bin/bash
set -e
BASE_VERSION=26
TEST_VERSIONS=(26 27 28)
CENTOS_REL=7
PREV=26
chef exec kitchen destroy templates-${BASE_VERSION}-centos-${CENTOS_REL}
chef exec kitchen verify templates-${BASE_VERSION}-centos-${CENTOS_REL}
for v in ${TEST_VERSIONS[@]}; do
  mv .kitchen/templates-${PREV}-centos-${CENTOS_REL}.yml .kitchen/templates-${v}-centos-${CENTOS_REL}.yml
  chef exec kitchen converge templates-${v}-centos-${CENTOS_REL}
  chef exec kitchen verify templates-${v}-centos-${CENTOS_REL}
  PREV=$v
done
mv .kitchen/templates-${PREV}-centos-${CENTOS_REL}.yml .kitchen/templates-${BASE_VERSION}-centos-${CENTOS_REL}.yml
chef exec kitchen destroy templates-${BASE_VERSION}-centos-${CENTOS_REL}

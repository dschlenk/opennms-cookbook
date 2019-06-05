#!/bin/bash
set -e
BASE_VERSION=16
TEST_VERSIONS=(17 18 19 20 21 22 23 24)
CENTOS_REL=69
PREV=16
chef exec kitchen destroy default-${BASE_VERSION}-centos-${CENTOS_REL}
chef exec kitchen verify default-${BASE_VERSION}-centos-${CENTOS_REL}
for v in ${TEST_VERSIONS[@]}; do
  mv .kitchen/default-${PREV}-centos-${CENTOS_REL}.yml .kitchen/default-${v}-centos-${CENTOS_REL}.yml
  chef exec kitchen converge default-${v}-centos-${CENTOS_REL}
  chef exec kitchen verify default-${v}-centos-${CENTOS_REL}
  PREV=$v
done
mv .kitchen/default-${PREV}-centos-${CENTOS_REL}.yml .kitchen/default-${BASE_VERSION}-centos-${CENTOS_REL}.yml
chef exec kitchen destroy default-${BASE_VERSION}-centos-${CENTOS_REL}

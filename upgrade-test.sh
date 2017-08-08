#!/bin/bash
set -e
BASE_VERSION=16
TEST_VERSIONS=(17 18 19)
CENTOS_REL=68
PREV=16
chef exec kitchen destroy default-${BASE_VERSION}
chef exec kitchen verify default-${BASE_VERSION}
for v in ${TEST_VERSIONS[@]}; do
  mv .kitchen/default-${PREV}-centos-${CENTOS_REL}.yml .kitchen/default-${v}-centos-${CENTOS_REL}.yml
  chef exec kitchen converge default-${v}
  chef exec kitchen verify default-${v}
  PREV=$v
done
mv .kitchen/default-${PREV}-centos-${CENTOS_REL}.yml .kitchen/default-${BASE_VERSION}-centos-${CENTOS_REL}.yml
chef exec kitchen destroy default-${BASE_VERSION}

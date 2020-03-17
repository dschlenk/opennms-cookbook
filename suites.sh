#!/bin/bash
echo "---"
echo "verifier:"
echo "  name: inspec"
echo ""
echo "driver:"
echo "  name: vagrant"
echo "  network:"
echo "    - [\"forwarded_port\", {guest: 8980, host: 8980, auto_correct: true}]"
echo "    - [\"forwarded_port\", {guest: 3000, host: 3000, auto_correct: false}]"
echo "    - [\"forwarded_port\", {guest: 9200, host: 9200, auto_correct: false}]"
echo "  customize:"
echo "    memory: 1024"
echo ""
echo "provisioner:"
echo "  name: chef_zero"
echo "  product_version: 14.13.11"
echo "  require_chef_omnibus: 14.13.11"
echo ""
echo "platforms:"
echo "  - name: centos-6.9"
echo "    attributes:"
echo "      opennms:"
echo "        templates: false"
echo "        conf:"
echo "          start_timeout: 50"
echo "        stable: true"
echo "        plugin:"
echo "          xml: true"
echo "          nsclient: true"
echo "  - name: centos-7"
echo "    attributes:"
echo "      opennms:"
echo "        templates: false"
echo "        conf:"
echo "          start_timeout: 50"
echo "        stable: true"
echo "        plugin:"
echo "          xml: true"
echo "          nsclient: true"
echo "suites:"
VERSIONS=(16.0.4-1 17.1.1-1 18.0.4-1 19.1.0-1 20.1.0-1 21.1.0-1 22.0.4-1 23.0.4-1 24.1.3-1 25.2.0-1)
STABLE_VERSION=(25.2.0-1)
SUITES=$(ls test/fixtures/cookbooks/onms_lwrp_test/recipes/)
SUITES+=('default')
SUITES+=('templates')
SUITES+=('flows')
for f in ${SUITES[@]}; do
  recipe=${f%.rb}
  for v in ${VERSIONS[@]}; do
    if [ "${recipe}" == "flows" ] && [ "${v%%.*-1}" -lt "22" ]; then
      continue
    fi
    if [ "${recipe}" != "flows" ]; then
      PROF_DIR="test/integration/${recipe}"
      INSPEC_YML="${PROF_DIR}/inspec.yml"
      if [ -d ${PROF_DIR}/inspec ]; then
        mv ${PROF_DIR}/inspec/* ${PROF_DIR}/
        rmdir ${PROF_DIR}/inspec
      fi
      if [ ! -d ${PROF_DIR}/controls ]; then
        mkdir -p ${PROF_DIR}/controls
      fi
      if [ -f ${PROF_DIR}/${recipe}_spec.rb ]; then
        mv ${PROF_DIR}/${recipe}_spec.rb ${PROF_DIR}/controls/
      fi
      if [ ! -f ${INSPEC_YML} ]; then
        echo "${INSPEC_YML} didn't exist for ${recipe}, making it now" >&2
        echo "name: opennms_${recipe}" > ${INSPEC_YML}
        echo "title: OpenNMS ${recipe}" >> ${INSPEC_YML}
        echo "maintainer: David Schlenk" >> ${INSPEC_YML}
        echo "copyright: ConvergeOne" >> ${INSPEC_YML}
        echo "copyright_email: dschlenk@convergeone.com" >> ${INSPEC_YML}
        echo "license: Apache 2.0" >> ${INSPEC_YML}
        echo "summary: Verify OpenNMS LWRP ${recipe} works." >> ${INSPEC_YML}
        echo "version: 1.0.0" >> ${INSPEC_YML}
        echo "supports:" >> ${INSPEC_YML}
        echo "  - os-family: redhat" >> ${INSPEC_YML}
        echo "depends:" >> ${INSPEC_YML}
        echo "  - name: opennms" >> ${INSPEC_YML}
        echo "    path: test/integration/default" >> ${INSPEC_YML}
      fi
      if [ ! -f ${PROF_DIR}/controls/${recipe}_spec.rb ]; then
        echo "adding blank spec for ${recipe}" >&2
        echo "control '${recipe}' do" > ${PROF_DIR}/controls/${recipe}_spec.rb
        echo "end" >> ${PROF_DIR}/controls/${recipe}_spec.rb
      fi
      fgrep -q "describe 'opennms::" ${PROF_DIR}/controls/${recipe}_spec.rb
      if  [ "$?" = "0" ] && [ "${recipe}" != "default" ]; then
        echo "populating spec for ${recipe}" >&2
        echo "control '${recipe}' do" > ${PROF_DIR}/controls/${recipe}_spec.rb
        echo "end" >> ${PROF_DIR}/controls/${recipe}_spec.rb
      fi
    fi
    $(fgrep -q "  - name: ${recipe}_${v%%.*-1}" .kitchen.yml)
    if [ "$?" != "0" ]; then
      echo "  - name: ${recipe}_${v%%.*-1}"
      echo "    run_list:"
      echo "      - recipe[opennms::postgres_upgrate]"
      echo "      - recipe[oracle_java8::default]"
      if [ "$recipe" == "flows" ]; then
        echo "      - recipe[opennms-elasticsearch::default]"
        echo "      - recipe[snmp::default]"
        echo "      - recipe[hsflowd::default]"
      fi
      echo "      - recipe[opennms::default]"
      if [ "$recipe" == "flows" ]; then
        echo "      - recipe[opennms::telemetryd]"
        echo "      - recipe[onms_lwrp_test::webopts]"
        echo "      - recipe[onms_lwrp_test::localhost]"
        echo "      - recipe[opennms_helm::default]"
      fi
      if [ "$recipe" != "default" ] && [ "$recipe" != "templates" ] && [ "$recipe" != "flows" ]; then
        echo "      - recipe[onms_lwrp_test::${recipe}]"
      else
        if [ "$recipe" != "flows" ]; then
          echo "      - recipe[onms_lwrp_test::webopts]"
        fi
      fi
      echo "    attributes:"
      echo "      opennms:"
      echo "        version: ${v}"
      if [ "$recipe" == "templates" ]; then
        echo "        templates: true"
      else
        if [ "$recipe" == "flows" ]; then
          echo "        templates: false"
          echo "        telemetryd:"
          echo "          managed: true"
          echo "          jti:"
          echo "            enabled: true"
          echo "          netflow5:"
          echo "            enabled: true"
          echo "          netflow9:"
          echo "            enabled: true"
          echo "          ipfix:"
          echo "            enabled: true"
          echo "          sflow:"
          echo "            enabled: true"
          echo "          nxos:"
          echo "            enabled: true"
          echo "    excludes:"
          echo "      - centos-6.9"
        fi
      fi
      if [ "$recipe" = "default" ]; then
        echo "        upgrade: true"
      fi
      echo "    verifier:"
      echo "      inspec_tests:"
      if [ "$recipe" != "default" ]; then
        echo "        - path: test/integration/default"
      fi
      if [ "$recipe" != "templates" ] && [ "$recipe" != "flows" ]; then
        echo "        - path: test/integration/${recipe}"
      fi
    else
      echo "already have suite for ${recipe}"
    fi
  done
done

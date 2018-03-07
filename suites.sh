#!/bin/bash
VERSIONS=(16.0.4-1 17.1.1-1 18.0.4-1 19.1.0-1)
STABLE_VERSION=(20.0.1-1)
SUITES=$(ls test/fixtures/cookbooks/onms_lwrp_test/recipes/)
SUITES+=('default')
for f in ${SUITES[@]}; do
  recipe=${f%.rb}
  for v in ${VERSIONS[@]}; do
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
      echo "control '${recipe}' do" > ${PROF_DIR}/controls/${recipe}_spec.rb
      echo "end" >> ${PROF_DIR}/controls/${recipe}_spec.rb
    fi
    fgrep -q "describe 'opennms::" ${PROF_DIR}/controls/${recipe}_spec.rb
    if  [ "$?" = "0" ] && [ "${recipe}" != "default" ]; then
      echo "control '${recipe}' do" > ${PROF_DIR}/controls/${recipe}_spec.rb
      echo "end" >> ${PROF_DIR}/controls/${recipe}_spec.rb
    fi
    $(fgrep -q "  - name: ${recipe}_${v%%.*-1}" .kitchen.yml)
    if [ "$?" != "0" ]; then
      echo "  - name: ${recipe}_${v%%.*-1}"
      echo "    run_list:"
      echo "      - recipe[opennms::postgres]"
      echo "      - recipe[oracle_java8::default]"
      echo "      - recipe[opennms::default]"
      if [ "$recipe" != "default" ]; then
        echo "      - recipe[onms_lwrp_test::${recipe}]"
      else
        echo "      - recipe[onms_lwrp_test::webopts]"
      fi
      echo "    attributes:"
      echo "      opennms:"
      echo "        version: ${v}"
      if [ "$recipe" = "default" ]; then
        echo "      upgrade: true"
      fi
      echo "    verifier:"
      echo "      inspec_tests:"
      if [ "$recipe" != "default" ]; then
        echo "        - path: test/integration/default"
      fi
      echo "        - path: test/integration/${recipe}"
    fi
  done
done

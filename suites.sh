#!/bin/bash
VERSIONS=(16.0.4-1 17.1.1-1 18.0.4-1 19.1.0-1)
STABLE_VERSION=(20.0.1-1)
SUITES=$(ls test/fixtures/cookbooks/onms_lwrp_test/recipes/)
SUITES+=('default')
for f in ${SUITES[@]}; do
  recipe=${f%.rb}
  for v in ${VERSIONS[@]}; do
    if [ ! -d test/integration/${recipe}_${v%%.*-1}/inspec ]; then
      mkdir -p test/integration/${recipe}_${v%%.*-1}/inspec
    fi
    if [ ! -f test/integration/${recipe}_${v%%.*-1}/inspec/${recipe}_spec.rb ]; then
      echo "describe 'opennms::${recipe}' do" > test/integration/${recipe}_${v%%.*-1}/inspec/${recipe}_spec.rb
      echo "end" >> test/integration/${recipe}_${v%%.*-1}/inspec/${recipe}_spec.rb
    fi
    $(fgrep -q "  - name: ${recipe}_${v%%.*-1}" .kitchen.yml)
    if [ "$?" != "0" ]; then
      echo "  - name: ${recipe}_${v%%.*-1}"
      echo "    run_list:"
      echo "      - recipe[opennms::postgres]"
      echo "      - recipe[oracle_java8::default]"
      echo "      - recipe[opennms::default]"
      if [ "$recipe" != "default" ]; then
        echo "      - recipe[opennms::${recipe}]"
      fi
      echo "    attributes:"
      echo "      opennms:"
      echo "        version: ${v}"
      if [ "$recipe" == "default" ]; then
        echo "      upgrade: true"
      fi
    fi
  done
done

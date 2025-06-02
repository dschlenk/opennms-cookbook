# Scriptd Resources

## opennms\_scriptd\_engine

Manages the BSF engines available for use by scriptd scripts.

### Actions for opennms\_scriptd\_engine

* `:create` - Default. Adds an `engine` element to `$OPENNMS_HOME/etc/scriptd-configuration.xml` or updates an existing element with matching `language` attribute if one exists.
* `:create_if_missing` - Adds an `engine` element to the config file if not present. Does not update.
* `:update` - Updates an existing `engine` element if it exists. Raises an error if it does not.

### Properties for opennms\_scriptd\_engine

| Name | Name? | Type | Required | Description |
| ---- | ----- | ---- | -------- | ----------- |
| `language` | ✓ | String | ✓ | A name for this engine, typically the common name of the language e.g. `beanshell`, `groovy`, etc. |
| `class_name` | | String | ✓ | Full Java package and class name of the engine implementation |
| `extensions` | | String | | file extensions commonly associated with scripts written in this language\* |

The `extensions` property has no real utility since all scripts are stored embedded in the XML config file and not in separate script files.
It is included mostly to preserve the engine defined in the default config file which includes a `beanshell` engine with extensions `bsh`.

### Examples for opennms\_scriptd\_engine

See [scriptd\_engine.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/scriptd_engine.rb)

## opennms\_scriptd\_script

Manages scriptd scripts. Since multiple scripts of the same type and language are allowed, no implicit or explicit `:update` actions are available.

### Actions for opennms\_scriptd\_script

* `:add` - Default. Adds the script to the Scriptd config file if not already present.
* `:delete` - Remove the script from the Scriptd config file if present.

### Properties for opennms\_scriptd\_script

| Name | Name? | Type | Required | Description |
| ---- | ----- | ---- | -------- | ----------- |
| `script_name` | ✓ | String | ✓ | A name for this resource. Not stored in the file nor is it part of desired state. |
| `language` | | String | ✓ | Must match the `language` of an existing script engine. |
| `script` | | String | | The script content. |
| `type` | | String | | One of `start`, `stop`, `reload`, `event`. Default is `event`. |
| `uei` | | String, Array | | Ignored unless `type` is `event`. The UEI or list of UEIs that, upon receipt, should result in this script executing. |

### Examples for opennms\_scriptd\_script

See [scriptd\_script.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/scriptd_script.rb)

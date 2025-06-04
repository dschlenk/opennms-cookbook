# opennms\_translation\_specs

Resource that manages `event-traslation-spec` elements in `translator-configuration.xml`.

## Actions for opennms\_translation\_specs

* `:add` - Default. Adds `TranslationSpec` items in `specs` that are not present.
* `:delete` - Removes `TranslationSpec` items in `specs` that are present.

## Properties for opennms\_translation\_specs

| Name | Name? | Type | Required? |
| ---- | ----- | ---- | --------- |
| `specs` | | Array of `Opennms::Cookbook::Translations:TranslationSpec` objects | x |

## Examples

Recipe [translation_specs.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/translation_specs.rb) demonstrates use, including construction of `TranslationSpec` objects.

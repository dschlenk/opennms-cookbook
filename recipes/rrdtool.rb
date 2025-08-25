#
# Cookbook:: opennms-cookbook
# Recipe:: rrdtool
#
# Copyright:: (c) 2016-2025 ConvergeOne Holding Corp
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# As of 34.0.0, RRDTool is now the default time series engine so we don't need to explicitly turn it on or install it.
# As such, those parts of this recipe have been removed, and the management of the rrd-configuration.properties template has been moved to the `base_templates` recipe.
# However, this recipe also enabled storeByGroup and will continue to do so.
node.default['opennms']['properties']['files']['store_by_group'] = { 'org.opennms.rrd.storeByGroup' => true }

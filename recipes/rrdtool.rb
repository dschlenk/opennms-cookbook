#
# Cookbook:: opennms-cookbook
# Recipe:: rrdtool
#
# Copyright:: (c) 2016-2024 ConvergeOne Holding Corp
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

# Packages rrdtool and jrrd2 are dependencies of the OpenNMS RPMs in Horizon 34+ and no longer need explicit installation.
# rrd-configuration.properties is now managed by the base_templates recipe.
node.default['opennms']['properties']['files']['store_by_group']['org.opennms.rrd.storeByGroup'] = true

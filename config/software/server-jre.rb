#
# Copyright 2013-2014 Chef Software, Inc.
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

name "server-jre"
default_version "7u67"

whitelist_file "jre/bin/javaws"
whitelist_file "jre/bin/policytool"
whitelist_file "jre/lib"
whitelist_file "jre/plugin"
whitelist_file "jre/bin/appletviewer"

if _64_bit?
  # TODO: download x86 version on x86 machines
  source url:     "http://download.oracle.com/otn-pub/java/jdk/7u67-b01/server-jre-7u67-linux-x64.tar.gz",
         md5:     "f6e81b9be4c1e15d59eb21e564a8973d",
         cookie:  "gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie",
         warning: "By including the JRE, you accept the terms of the Oracle Binary Code License Agreement for the Java SE Platform Products and JavaFX, which can be found at http://www.oracle.com/technetwork/java/javase/terms/license/index.html"
else
  raise "Server-jre can only be installed on x86_64 systems."
end

relative_path "jdk1.7.0_67"

build do
  mkdir "#{install_dir}/embedded/jre"
  sync  "#{project_dir}/", "#{install_dir}/embedded/jre"
end

name "graylog-web"
default_version project.build_version

dependency "server-jre"
dependency "runit"

if version.include? '-beta' or version.include? '-rc'
  #source url: "http://packages.graylog2.org/releases/graylog2-web-interface/graylog-web-interface-#{version}.tgz",
  source url: "https://packages.graylog2.org/nightly-builds/graylog-web-interface-1.3.0-SNAPSHOT-20151103144707.tgz",
         md5: "cd2ae650e3c37589671f21123fd121ac"
else
  source url: "http://packages.graylog2.org/releases/graylog2-web-interface/graylog-web-interface-#{version}.tgz",
         md5: "ffde989ec88cf41097a7083454d2d894"
end

relative_path "graylog-web-interface-#{version}"

build do
  mkdir "#{install_dir}/web"
  sync  "#{project_dir}/", "#{install_dir}/web"
end
